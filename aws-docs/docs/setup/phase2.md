# Phase 2: Base Tool Installation (Ansible)

This phase covers the initial deployment of Docker, Jenkins, SonarQube, and Nexus. The design philosophy here is **“Configuration as Code” (CaC)** — every tool is deployed via Ansible, with environment variables and specific file permissions set to prevent the common crashes associated with Java applications and Docker volumes.

## 1. Docker Engine Installation

**File:** `ansible/roles/docker/tasks/main.yml`

**Purpose:** Installs the Docker Engine and Docker Compose on all 6 EC2 instances, serving as the universal container runtime for the platform.

**What We Did:**
- Installed prerequisite packages (`apt-transport-https`, `ca-certificates`, `curl`, `gnupg`).
- Added Docker’s official GPG key and apt repository to ensure we pull the latest stable versions.
- Installed the `docker-ce` package.
- Added the `ubuntu` user to the `docker` group. This is critical because it allows Ansible to run `docker` commands on the remote servers without requiring `sudo` for every task, making the automation seamless.

## 2. Jenkins Base Deployment

**File:** `ansible/roles/jenkins/tasks/install.yml`

**Purpose:** Deploys Jenkins as a Docker container with the setup wizard permanently disabled.

**What We Did:**
- Created the `/opt/jenkins` and `/opt/jenkins/casc` directories. Crucially, we set `owner: 1000` and `group: 1000`. The Jenkins Docker container runs as the user ID `1000`; if the host directory is owned by `root`, Jenkins crashes with a **“Permission Denied”** error when trying to write its config files.
- Ran the `jenkins/jenkins:lts-jdk21` container, mapping ports `8080` and `50000`.
- Injected the `JAVA_OPTS: "-Djenkins.install.runSetupWizard=false"` environment variable. This completely disables the initial setup wizard, ensuring the server is ready for automated configuration via JCasC without asking for a one-time admin password.

## 3. SonarQube Deployment

**File:** `ansible/roles/sonarqube/tasks/main.yml`

**Purpose:** Deploys SonarQube Community Edition for static code analysis.

**What We Did:**
- Set the `vm.max_map_count` kernel parameter to `262144`. This is a strict requirement for SonarQube’s embedded Elasticsearch database; without it, Elasticsearch crashes immediately on boot.
- Ran the `sonarqube:9.9-community` container, mapping port `9000`.
- Injected strict memory limits via `SONAR_ES_JAVA_OPTS` and `SONAR_WEB_JAVA_OPTS` (`-Xms512m -Xmx512m`). Because SonarQube is deployed on the same `t3.large` EC2 instance as Jenkins, these limits prevent SonarQube from consuming all available RAM, which previously caused Out-Of-Memory (OOM) crashes on the server.

## 4. Nexus Repository Deployment

**File:** `ansible/roles/nexus/tasks/main.yml`

**Purpose:** Deploys Sonatype Nexus to act as the private Docker registry and artifact repository.

**What We Did:**
- Ran the `sonatype/nexus3:3.79.0` container. We mapped port `8081` for the Web UI and port `8082` specifically for the Docker Registry API.
- Injected the `NEXUS_SECURITY_RANDOM_PASSWORD=false` environment variable. By default, Nexus generates a random UUID password on first boot, which requires complex Ansible logic to fetch and change. Forcing a static, known password (`admin123`) on boot drastically simplified the downstream automation, allowing Ansible to immediately hit the Nexus REST API to configure repositories and users.



# Phase 3: Enterprise Integration & Security (CaC & APIs)

This phase transitions the platform from isolated tools into a unified, secure CI/CD engine. The design philosophy here is **zero manual UI configuration**. Users, service accounts, and tool-to-tool credentials are automated via Jenkins Configuration as Code (JCasC) and Ansible REST API calls.

## 1. Master Integration Playbook

**File:** `ansible/playbooks/integrate-tools.yml`

**Purpose:** Automates the creation of RBAC users, service accounts, and tool configurations using REST APIs.

**What We Did:**
- **Nexus API Automation:** Used the Ansible `uri` module to authenticate with Nexus. We automated the creation of the `docker-hosted` repository (listening on port `8082`) and provisioned a `jenkins-ci` Service Account with the `nx-admin` role. This ensures Jenkins can push Docker images to Nexus without exposing the main admin account in pipeline scripts.
- **SonarQube API Automation:** Used the `uri` module to hit the SonarQube REST API, automatically creating `dev` and `tester` accounts with standard `sonar-users` permissions.
- **Dynamic Inventory Handling:** Configured the playbook to run against `hosts: control_plane` and `hosts: monitoring_ops` separately, eliminating the complex `delegate_to` and `hostvars` cross-server variable bugs we faced earlier.

## 2. Jenkins Configuration as Code (JCasC)

**File:** `ansible/roles/jenkins/templates/jenkins.yml.j2`

**Purpose:** Acts as the single source of truth for Jenkins configuration. It automates user creation, RBAC, and credential injection.

**What We Did:**
- **RBAC Matrix:** Automated the creation of 4 users (`admin`, `dev`, `tester`, `jrdevops`). We configured a strict Global Matrix Authorization. For example, `jrdevops` is granted `Job/Configure` and `Job/Build` permissions, but explicitly denied `Job/Delete` and `Overall/Administer`. This enforces the Principle of Least Privilege.
- **Credential Injection:** Injected the `sonarqube-token` (String credential) and `nexus-creds` (Username/Password credential) directly into Jenkins. Because this is a Jinja2 template, Ansible dynamically injects the Nexus password at runtime, meaning zero hardcoded secrets exist in the Git repository.

## 3. Jenkins Plugin Automation

**File:** `ansible/roles/jenkins/tasks/plugins.yml`

**Purpose:** Installs required Jenkins plugins without user intervention.

**What We Did:**
- Copies a `plugins.txt` file into the Jenkins container.
- Uses the `jenkins-plugin-cli` binary to install the `configuration-as-code` (JCasC), `sonar` (SonarQube integration), `docker-workflow`, and `prometheus` plugins.
- Restarts Jenkins to load the plugins and apply the JCaC template.


# Phase 4: Observability Stack (Monitoring & Logs)

This phase configures the platform's "eyes and ears." The design philosophy here is **full automation** (auto-discovery of targets and auto-provisioning of dashboards) and using **AWS Private IPs** to bypass Hairpin NAT routing issues.

## 1. Prometheus Configuration

**File:** `ansible/roles/prometheus/templates/prometheus.yml.j2`

**Purpose:** Dynamically generates the scrape configuration for Prometheus.

**What We Did:**
- Used Jinja2 `{% for host in groups['all'] %}` loops to dynamically discover all 6 EC2 instances.
- Configured Prometheus to scrape `node_exporter` (port `9100`) and `cAdvisor` (port `9101`) using the AWS `private_ip` variable. This was the critical fix for the AWS Hairpin NAT issue, as routing monitoring traffic over Public IPs caused timeouts.

**File:** `ansible/roles/prometheus/tasks/main.yml`

**Purpose:** Deploys the Prometheus container.

**What We Did:** Ran the container using `--network host`. Because Prometheus runs on the Monitoring node alongside Loki and Promtail, using the host network allows it to scrape those local services via `127.0.0.1` without needing complex Docker network bridges.

## 2. Promtail Log Shipping

**File:** `ansible/roles/promtail/templates/promtail-config.yml.j2`

**Purpose:** Configures Promtail to automatically collect and ship Docker container logs to Loki.

**What We Did:**
- Configured `docker_sd_configs` to point at the Unix socket (`/var/run/docker.sock`). This enables Docker Service Discovery: Promtail automatically finds any new container, extracts its name as a label, and tails its stdout/stderr logs without manual path configuration.
- Set the Loki push URL to use the Monitoring node's Private IP to ensure logs stay internal to the VPC.

## 3. Grafana Auto-Provisioning

**File:** `ansible/roles/grafana/templates/datasources.yml.j2`

**Purpose:** Automatically connects Grafana to Prometheus and Loki on boot.

**What We Did:**
- Mounted a `provisioning/datasources` directory into the Grafana container.
- Used a Jinja2 template to define Prometheus (`http://127.0.0.1:9090`) and Loki (`http://127.0.0.1:3100`) as data sources. This eliminates the need to manually click "Add Data Source" in the Grafana UI every time the server is rebuilt.

**File:** `ansible/playbooks/integrate-monitor.yml`

**Purpose:** Automates the download and provisioning of pre-built community dashboards.

**What We Did:** Used Ansible `get_url` to download JSON dashboards directly from Grafana.com (Node Exporter ID `1860`, cAdvisor ID `193`, Loki ID `13639`). By placing these in the `/var/lib/grafana/dashboards` volume, Grafana loads them automatically on startup.

---

# Phase 5: Deployment Architecture (CI/CD & Docker Target)

> **Note:** Copy into `docs/setup/phase5-deployment-architecture.md`

This phase defines how application code is securely routed and deployed on the platform. The design philosophy here is **Network Isolation** (Principle of Least Privilege for network traffic) and **flexible deployment paths** (Golden Paths).

## 1. Host Hardening (Secure Host)

**File:** `ansible/roles/secure_host/tasks/main.yml`

**Purpose:** Locks down the `deploy-node` EC2 instance before it hosts public-facing applications.

**What We Did:**
- Configured UFW (Uncomplicated Firewall) to enforce a strict allow-list policy: Deny all inbound, explicitly Allow `22` (SSH), `80` (HTTP), `443` (HTTPS).
- Installed and enabled `fail2ban` to dynamically ban IPs that attempt brute-force SSH attacks.
- Disabled SSH Password Authentication in `sshd_config`, enforcing SSH key-only access.

## 2. Nginx Reverse Proxy & Network Isolation

**File:** `ansible/roles/nginx_proxy/tasks/main.yml`

**Purpose:** Establishes a secure traffic routing architecture where Nginx is the only public entry point, and backend applications are hidden on an isolated Docker network.

**What We Did:**
- Created an internal Docker network (`internal_net` with `internal: true`). Containers attached to this network cannot be accessed directly from the internet.
- Deployed a `backend-app` container attached only to `internal_net`. Noticeably, it has no published ports, making it completely invisible to the public.
- Deployed an `nginx-proxy` container. We configured it to listen on ports `80`/`443` and route traffic to the backend app via the internal network.
- **Key Detail:** We attached the `nginx-proxy` to both the `internal_net` and the default `bridge` network. This bypasses Docker's rule that blocks port mapping on `internal: true` networks, allowing Nginx to receive external traffic while securely forwarding it internally.

## 3. The "Golden Path" Jenkinsfile (Concept)

**Purpose:** Provides developers with a choice of deployment targets based on their application's complexity.

**What We Did:**
- Designed a Jenkinsfile with a choice parameter (`docker` or `kubernetes`).
- If `docker` is chosen: Jenkins builds the image, pushes to Nexus, then SSHs into the `deploy-node` and runs `docker run` behind the Nginx proxy.
- If `kubernetes` is chosen: Jenkins builds the image, pushes to Nexus, and triggers ArgoCD to apply K8s manifests to the cluster (future scope).