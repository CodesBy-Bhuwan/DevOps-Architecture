#  🌟 ENd-to-ENd Hybrid InfraStructure 🌟
# 🏗️ Enterprise DevOps Platform

This project is a fully automated, production-ready DevOps platform hosted on AWS. It is designed using Infrastructure as Code (IaC) and Configuration as Code (CaC) principles to provide a scalable, secure, and observable environment for deploying modern applications (like the MERN stack).

The platform features a dual-deployment "Golden Path" (supporting both standard Docker and Kubernetes GitOps), automated Role-Based Access Control (RBAC), and a complete observability stack (Metrics, Logs, and Dashboards).

## ☁️ Cloud Infrastructure (AWS)

The platform is provisioned in the `eu-north-1` (Stockholm) region using Terraform to optimize for cost and performance. It consists of 6 EC2 instances across a custom, isolated VPC:

1.  **Control Plane (t3.large):** The CI/CD engine. Hosts Jenkins (orchestration) and SonarQube (static code analysis).
2.  **Monitoring & Ops (t3.medium):** The observability and artifact hub. Hosts Nexus (Docker registry), Prometheus, Grafana, and Loki.
3.  **Kubernetes Master (t3.large):** The K8s control plane (ready for ArgoCD/GitOps).
4.  **Kubernetes Workers (t3.medium x2):** Application workload nodes for K8s deployments.
5.  **Docker Target (t3.medium):** A hardened deployment node for standard Docker applications, featuring an Nginx Reverse Proxy and isolated internal networks.

## ⚙️ Automation & IaC

- **Terraform:** Provisions the VPC, subnets, Security Groups, and EC2 instances. It features **Infrastructure Toggles** (`ENABLE_K8S`, `ENABLE_DOCKER`) to turn servers on/off individually, dropping the AWS bill to $0 when not in use. It auto-generates SSH keys and dynamically writes the Ansible inventory file.
- **Ansible:** Configures the 6 servers without manual SSH. It uses **JCasC** (Jenkins Configuration as Code) to automate RBAC users, and hits REST APIs to automate Nexus and SonarQube user/service account creation. Zero hardcoded passwords exist in the repository.

## 🔒 Security & RBAC

- **Least Privilege Network:** The Docker Target node runs an Nginx Reverse Proxy as the only public entry point (Ports 80/443). Backend apps are hidden on an isolated `internal_net` Docker network.
- **Host Hardening:** The deployment node is secured with **UFW** (Firewall), **Fail2ban** (Brute-force protection), and SSH key-only authentication.
- **RBAC:** Jenkins, SonarQube, and Nexus all feature automated Role-Based Access Control (`admin`, `dev`, `tester`, `jrdevops`) with strict matrix permissions. A dedicated `jenkins-ci` service account is used for tool-to-tool integration.

## 📈 Observability Stack

The platform provides a "single pane of glass" view of all metrics and logs:

- **Metrics (Prometheus & Node Exporter/cAdvisor):** Scrapes hardware and per-container metrics from all 6 servers using AWS Private IPs to bypass network routing issues.
- **Logs (Loki & Promtail):** Promtail uses Docker Service Discovery to automatically tail all container logs and ship them to Loki.
- **Visualization (Grafana):** Auto-provisioned with Prometheus and Loki data sources. Dashboards are downloaded and patched via Ansible, providing instant visibility into CPU, RAM, network traffic, and container health without manual UI configuration.

## 🚀 Deployment Architecture (The "Golden Path")

Developers can choose their deployment target via a Jenkins choice parameter:

- **Docker Path:** Jenkins builds the image, pushes to Nexus, and deploys behind the Nginx Reverse Proxy on the Docker Target node.
- **Kubernetes Path:** Jenkins builds the image, pushes to Nexus, and triggers ArgoCD to sync the deployment to the K8s cluster (GitOps).



# [🚨 How this infra behave? 🚨](https://github.com/CodesBy-Bhuwan/DevOps-Architecture/tree/GenF1)


[![INFRASTRUCTURE](https://img.shields.io/badge/🏗️INFRA-STRUCTURE-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://github.com/CodesBy-Bhuwan/DevOps-Architecture/tree/GenF1)



### [🖧 Infra-Servers](https://github.com/CodesBy-Bhuwan/DevOps-Architecture/tree/GenF1)

<img title="Servers" alt="All-Working Servers" src="devops-arch/arch-diagrams/screenshots/Screenshot from 2026-10-09 16-36-50Ss.png">

### [🚦 Infra-Status](https://github.com/CodesBy-Bhuwan/DevOps-Architecture/tree/GenF1)
<img title="Terminal" alt="Status on terminal" src="devops-arch/arch-diagrams/screenshots/Screenshot from 2026-10-09 16-48-41Ss.png">

### [📊 Infra-DashBoards](https://github.com/CodesBy-Bhuwan/DevOps-Architecture/tree/GenF1) 
<img title="Possible Dashboards" alt="Grafana dashboards" src="devops-arch/arch-diagrams/screenshots/Screenshot from 2026-10-09 16-38-46Ss.png">

### [📈 Infra-Metics](https://github.com/CodesBy-Bhuwan/DevOps-Architecture/tree/GenF1) 
<img title="Graphs" alt="Grafana data usuage" src="devops-arch/arch-diagrams/screenshots/Screenshot from 2026-10-09 16-32-58Ss.png">
