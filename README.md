# 🏗️ Enterprise DevOps Platform Infrastructure

[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/)
[![Loki](https://img.shields.io/badge/Loki-2C3E50?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/oss/loki/)
[![Nexus](https://img.shields.io/badge/Nexus-1B1C20?style=for-the-badge&logo=sonatype&logoColor=white)](https://www.sonatype.com/nexus-repository)
[![SonarQube](https://img.shields.io/badge/SonarQube-4E9BCD?style=for-the-badge&logo=sonarqube&logoColor=white)](https://www.sonarqube.org/)

> A fully automated, production-ready DevOps platform on AWS — built with **Infrastructure as Code**, **Configuration as Code**, and a **dual-deployment Golden Path** (Docker & Kubernetes GitOps).

This project demonstrates a complete enterprise-grade DevOps ecosystem: from automated cloud provisioning and host hardening to CI/CD orchestration, security, and full-stack observability. It’s designed to deploy modern applications (like the MERN stack) with zero manual intervention and zero hardcoded secrets.

---

## 📑 Table of Contents

- [✨ Key Highlights](#-key-highlights)
- [☁️ Cloud Infrastructure (AWS)](#️-cloud-infrastructure-aws)
- [⚙️ Automation & IaC](#️-automation--iac)
- [🔒 Security & RBAC](#-security--rbac)
- [📈 Observability Stack](#-observability-stack)
- [🚀 Deployment Architecture (The "Golden Path")](#-deployment-architecture-the-golden-path)
- [📸 Infrastructure Screenshots](#-infrastructure-screenshots)
- [🔗 Connect & Explore](#-connect--explore)

---

## ✨ Key Highlights

- **One-command provisioning** with Terraform — toggles for K8s and Docker to keep costs at $0 when idle.
- **Zero-touch configuration** via Ansible, JCasC, and REST APIs — no manual SSH, no hardcoded passwords.
- **Dual deployment paths** — standard Docker or Kubernetes GitOps (ArgoCD) chosen directly from Jenkins.
- **Least-privilege networking** — Nginx reverse proxy, isolated Docker networks, UFW, Fail2ban, SSH key-only.
- **Automated RBAC** across Jenkins, SonarQube, and Nexus with matrix-based permissions.
- **Single pane of glass** observability — Prometheus, Loki, Grafana with auto-provisioned dashboards.

---

## ☁️ Cloud Infrastructure (AWS)

Provisioned in **`eu-north-1` (Stockholm)** using Terraform for optimal cost and performance. The platform runs on **6 EC2 instances** inside a custom, isolated VPC.

| Instance | Type | Role |
|----------|------|------|
| **Control Plane** | `t3.large` | CI/CD engine — Jenkins (orchestration) & SonarQube (static analysis). |
| **Monitoring & Ops** | `t3.medium` | Observability & artifact hub — Nexus, Prometheus, Grafana, Loki. |
| **Kubernetes Master** | `t3.large` | K8s control plane (ArgoCD / GitOps ready). |
| **Kubernetes Workers** | `t3.medium` ×2 | Application workload nodes for K8s deployments. |
| **Docker Target** | `t3.medium` | Hardened Docker deployment node — Nginx Reverse Proxy + isolated networks. |

---

## ⚙️ Automation & IaC

- **Terraform**
  - Provisions VPC, subnets, Security Groups, and EC2 instances.
  - **Infrastructure Toggles** (`ENABLE_K8S`, `ENABLE_DOCKER`) allow individual server on/off — AWS bill drops to $0 when idle.
  - Auto-generates SSH keys and dynamically writes the Ansible inventory.

- **Ansible**
  - Configures all 6 servers with no manual SSH.
  - Uses **JCasC** (Jenkins Configuration as Code) to automate RBAC users.
  - Hits REST APIs to automate Nexus and SonarQube user/service account creation.
  - **Zero hardcoded passwords** in the repository.

---

## 🔒 Security & RBAC

- **Least Privilege Network** — The Docker Target node runs an Nginx Reverse Proxy as the only public entry point (Ports 80/443). Backend apps live on an isolated `internal_net` Docker network.
- **Host Hardening** — UFW (Firewall), Fail2ban (Brute-force protection), and SSH key-only authentication on the deployment node.
- **RBAC** — Jenkins, SonarQube, and Nexus all feature automated Role-Based Access Control (`admin`, `dev`, `tester`, `jrdevops`) with strict matrix permissions.
- A dedicated `jenkins-ci` service account is used for tool-to-tool integration.

---

## 📈 Observability Stack

A true **“single pane of glass”** for metrics, logs, and dashboards:

- **Metrics** — Prometheus & Node Exporter/cAdvisor scrape hardware and per-container metrics from all 6 servers using AWS Private IPs (bypasses routing issues).
- **Logs** — Loki & Promtail use Docker Service Discovery to automatically tail all container logs and ship them to Loki.
- **Visualization** — Grafana is auto-provisioned with Prometheus and Loki data sources. Dashboards are downloaded and patched via Ansible — instant visibility into CPU, RAM, network traffic, and container health **without manual UI configuration**.

---

## 🚀 Deployment Architecture (The "Golden Path")

Developers choose their target via a **Jenkins choice parameter**:

- **Docker Path** — Jenkins builds the image, pushes to Nexus, and deploys behind the Nginx Reverse Proxy on the Docker Target node.
- **Kubernetes Path** — Jenkins builds the image, pushes to Nexus, and triggers ArgoCD to sync the deployment to the K8s cluster (GitOps).

---

## 📸 Infrastructure Screenshots

<details>
<summary><strong>🖧 Infra Servers</strong> — all working nodes</summary>
<br>
<img title="Servers" alt="All-Working Servers" src="devops-arch/arch-diagrams/screenshots/Screenshot from 2026-10-09 16-36-50Ss.png">
</details>

<details>
<summary><strong>🚦 Infra Status</strong> — terminal status</summary>
<br>
<img title="Terminal" alt="Status on terminal" src="devops-arch/arch-diagrams/screenshots/Screenshot from 2026-10-09 16-48-41Ss.png">
</details>

<details>
<summary><strong>📊 Infra Dashboards</strong> — Grafana dashboards</summary>
<br>
<img title="Possible Dashboards" alt="Grafana dashboards" src="devops-arch/arch-diagrams/screenshots/Screenshot from 2026-10-09 16-38-46Ss.png">
</details>

<details>
<summary><strong>📈 Infra Metrics</strong> — Grafana data usage</summary>
<br>
<img title="Graphs" alt="Grafana data usuage" src="devops-arch/arch-diagrams/screenshots/Screenshot from 2026-10-09 16-32-58Ss.png">
</details>

---

## 🔗 Connect & Explore

[![GitHub](https://img.shields.io/badge/GitHub-CodesBy--Bhuwan-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/CodesBy-Bhuwan)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/codesbybhuwan/?isSelfProfile=true)

<div align="center">
  <p>
    <b>Ready to dive deeper?</b><br>
    Explore the full implementation, including Terraform modules, Ansible playbooks, Jenkins pipelines, and Kubernetes manifests.
  </p>
  

  <img src="https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExZW9xbTVmbmJyOXpja2d6M2l2MDN6dWptdzI3NGd2d2FpNGp6NTZycSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/yC9g3FhMIdmotdtvuP/giphy.gif" alt="DevOps Architecture" width="700">
  
  <br><br>
  
  <a href="https://github.com/CodesBy-Bhuwan/DevOps-Architecture/tree/GenF1" style="display: inline-block; padding: 14px 28px; font-size: 18px; font-weight: bold; color: #ffffff; background-color: #2ea44f; border-radius: 8px; text-decoration: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); transition: background-color 0.3s ease;">
    🚀 Explore the GenF1 Branch
  </a>
  
  <br><br>
</div>
---

<p align="center">
  <em>Built with ❤️ for scalable, secure, and observable infrastructure.</em>
</p>
