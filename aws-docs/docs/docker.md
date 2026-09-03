# 🐳 Docker

> Container runtime powering the services in this DevOps platform. Jenkins, SonarQube, Nexus, Prometheus, Grafana, Loki, Promtail, Node Exporter, and the MERN application run as Docker containers.

## 📌 What is it?

Docker provides the common container runtime across the **5 EC2 instances** in this platform. It isolates services and gives the Ansible automation a consistent way to install and run the required tools.

## 📦 Version

| Component | Version / Source |
|---|---|
| Docker Engine | Latest stable Docker CE from the official Docker APT repository |
| Docker CLI | Matches Docker Engine |
| containerd | Bundled with Docker Engine |

> Docker CE from Docker's official APT repository is used instead of Ubuntu's default `docker.io` package for version consistency and timely updates.

## 🖥️ Where it runs

Docker is installed on every server:

| Server | Role | Containers |
|---|---|---|
| `control-plane` | CI/CD + artifact management | Jenkins, SonarQube, Nexus |
| `monitoring` | Observability | Prometheus, Grafana, Loki, Promtail |
| `k8s-master` | Kubernetes container runtime | None currently active |
| `k8s-worker-1` | Kubernetes runtime + application host | MERN application when deployed |
| `k8s-worker-2` | Kubernetes container runtime | None currently active |

## ⚙️ Installation & Automation

Docker is installed automatically by the Ansible Docker role. Manual installation is not required when deploying the platform.

**Main role:** `ansible/roles/docker/`

Run the Docker configuration:

```bash
cd ansible
ansible-playbook -i inventory/aws.ini playbooks/site.yml --tags docker
```

The role installs Docker CE, containerd, Buildx, Compose plugin, enables the Docker service, configures user access, and deploys the Docker daemon configuration.

## 🔧 Platform-Specific Configuration

**File:** `/etc/docker/daemon.json`

The configuration includes:

```json
{
  "insecure-registries": ["<control-plane-private-ip>:8082"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "3"
  },
  "live-restore": true
}
```

### Why these settings matter

| Setting | Purpose |
|---|---|
| `insecure-registries` | Allows Docker to push/pull from the Nexus Docker registry on HTTP port `8082`. |
| `json-file` + log limits | Keeps container logs available for Promtail while preventing unlimited disk growth. |
| `live-restore` | Keeps containers running during Docker daemon restarts. |

After changing the daemon configuration:

```bash
sudo systemctl restart docker
```

## 📦 Container Layout

### Control Plane

| Container | Image | Port | Purpose |
|---|---|---:|---|
| Jenkins | `jenkins/jenkins:lts-jdk21` | 8080 | CI/CD |
| SonarQube | `sonarqube:9.9-community` | 9000 | Static analysis |
| Nexus | `sonatype/nexus3:3.79.0` | 8081, 8082 | Artifacts + Docker registry |

### Monitoring Server

| Container | Image | Port | Purpose |
|---|---|---:|---|
| Prometheus | `prom/prometheus:latest` | 9090 | Metrics |
| Grafana | `grafana/grafana:latest` | 3000 | Dashboards |
| Loki | `grafana/loki:latest` | 3100 | Log aggregation |
| Promtail | `grafana/promtail:latest` | — | Log shipping |

### All Servers

| Container | Image | Port | Purpose |
|---|---|---:|---|
| Node Exporter | `prom/node-exporter:latest` | 9100 | Host metrics |

## 🔁 How Docker Fits in the Platform

### CI/CD

```text
GitHub
  ↓
Jenkins
  ↓
docker build
  ↓
Nexus Docker Registry (:8082)
  ↓
docker pull
  ↓
Application Host / Kubernetes Workers
```

Jenkins uses Docker to build application images and pushes them to the Nexus Docker registry. The application image can then be pulled for deployment.

### Observability

```text
Container logs
    ↓
Docker json-file logs
    ↓
Promtail
    ↓
Loki
    ↓
Grafana
```

## ✅ Verification

Check the Docker service:

```bash
sudo systemctl status docker
```

Check the version:

```bash
docker --version
```

Check running containers:

```bash
docker ps
```

Check the configured registry:

```bash
docker info | grep -A2 "Insecure Registries"
```

Check Docker disk usage:

```bash
docker system df
```

Test the Nexus registry from the Jenkins host:

```bash
docker pull <control-plane-private-ip>:8082/mern-app:latest
```

## 🧯 Troubleshooting

| Problem | Likely Cause | Action |
|---|---|---|
| Permission denied on Docker socket | User is not in the Docker group | Add the user to the `docker` group and reconnect. |
| HTTPS error when pushing to Nexus | Nexus HTTP registry is not configured as insecure | Check `daemon.json` and restart Docker. |
| Cannot connect to Docker daemon | Docker service is stopped | `sudo systemctl start docker` |
| Disk usage is growing | Container logs or unused Docker data | Check `docker system df` and review log rotation. |
| Image not found in Nexus | Image/tag mismatch | Verify the repository and tag in Nexus. |

## 🔒 Security Notes

| Current State | Production Consideration |
|---|---|
| Nexus Docker registry uses HTTP | Use TLS and a reverse proxy in production. |
| Docker socket is not exposed to containers | Keep `/var/run/docker.sock` protected. |
| Users may belong to the `docker` group | Treat Docker-group membership as privileged access. |
| Images may use floating tags | Pin trusted images and, where practical, use image digests. |

## 🧹 Maintenance

Check Docker disk usage regularly:

```bash
docker system df
```

Manual cleanup of unused Docker resources:

```bash
docker system prune -af
```

> Volume cleanup is intentionally not included in the normal command because removing volumes can delete persistent data.

## 🗂️ Related Files

| File | Purpose |
|---|---|
| `ansible/roles/docker/tasks/main.yml` | Docker installation and configuration tasks |
| `ansible/roles/docker/templates/daemon.json.j2` | Docker daemon configuration template |
| `ansible/roles/docker/handlers/main.yml` | Docker service restart handler |
| `apps/mern-app/Dockerfile` | MERN application container build definition |

## 🔗 References

- [Docker Documentation](https://docs.docker.com/)
- [Docker daemon configuration](https://docs.docker.com/reference/cli/dockerd/)
- [Nexus Docker Registry](https://help.sonatype.com/en/docker-registry.html)
