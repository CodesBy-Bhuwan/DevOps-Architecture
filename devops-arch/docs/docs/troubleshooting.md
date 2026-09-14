*This file is gold for interviews. It proves you faced real problems and solved them like an engineer.*

# Troubleshooting & Lessons Learned

Throughout the build of this platform, several complex infrastructure and automation issues were encountered and resolved.

## 1. Jenkins Out-Of-Memory (OOM) on Startup

- **Symptom:** Jenkins container crashed immediately on boot (`ExitCode 137`).
- **Root Cause:** The `t3.medium` (4GB RAM) ran out of memory because Jenkins (Java), SonarQube (Java), and the Jenkins Plugin CLI were all running simultaneously.
- **Resolution:**
  1. Upgraded the Control Plane EC2 instance from `t3.medium` to `t3.large` (8GB RAM).
  2. Limited SonarQube's Java heap size using:
     ```bash
     -e "SONAR_ES_JAVA_OPTS=-Xms512m -Xmx512m"
     ```

---

## 2. Docker "Permission Denied" on EBS Volumes

- **Symptom:** Jenkins, Loki, and Prometheus containers crashed with `permission denied` when trying to write to `/opt/jenkins` or `/opt/prometheus`.
- **Root Cause:** Ansible creates host directories as the `root` user. However, Docker containers run as specific non-root users:
  - Jenkins → UID `1000`
  - Loki → UID `10001`
  - Prometheus → UID `65534`
- **Resolution:** Added `owner` and `group` parameters to the Ansible `file` module tasks to match the container's expected UID before starting the container.

---

## 3. Nexus 401 Unauthorized on REST API

- **Symptom:** Ansible failed to change the Nexus admin password via the REST API with a `401 Unauthorized` error.
- **Root Cause:** Nexus 3.79+ is strict with Basic Authentication. Ansible's `uri` module waits for a `401` challenge before sending credentials, but Nexus immediately rejects it.
- **Resolution:**
  1. Added `force_basic_auth: yes` to the Ansible `uri` task.
  2. Abandoned the dynamic UUID password fetch loop entirely.
  3. Forced Nexus to boot with a static password using:
     ```text
     NEXUS_SECURITY_RANDOM_PASSWORD=false
     ```
  4. This significantly simplified the Nexus automation.

---

## 4. AWS "Hairpin NAT" Blocking Prometheus

- **Symptom:** Prometheus targets for `node_exporter` showed `context deadline exceeded`.
- **Root Cause:** AWS EC2 instances cannot route traffic to their own Public IP addresses (Hairpin NAT). When Prometheus looped through the inventory to scrape targets, it timed out trying to reach itself or local peers via Public IP.
- **Resolution:**
  1. Updated the Terraform `local_file` inventory generator to include both:
     - `ansible_host` → Public IP
     - `private_ip` → VPC internal IP
  2. Updated the `prometheus.yml.j2` Jinja2 template to use the private IP:
     ```jinja2
     {{ hostvars[host]['private_ip'] }}
     ```

---

## 5. Docker Daemon Rejecting HTTP for Nexus Registry

- **Symptom:** `docker push` from Jenkins to Nexus failed with:
  ```text
  net/http: request canceled while waiting for connection