# DevOps Platform Architecture

## 1. Overview

This document outlines the architecture of the automated DevOps platform hosted on AWS. The platform is designed to support both standard Docker deployments and Kubernetes (GitOps) workflows, with a strong emphasis on Infrastructure as Code (IaC), Configuration as Code (CaC), and Observability.

## 2. Problem Statement

Modern software delivery teams often face the following challenges:

- **Manual infrastructure provisioning** leads to configuration drift, slow onboarding, and inconsistent environments.
- **Tool sprawl** (Jenkins, SonarQube, Nexus, monitoring) without a unified automation approach results in repetitive, error‑prone setup and high operational overhead.
- **Lack of observability** makes it difficult to trace application logs and metrics across distributed services, increasing Mean Time To Recovery (MTTR).
- **Security vulnerabilities** arise from ad‑hoc user management and hardcoded credentials.
- **Cost unpredictability** when development and testing environments are left running unnecessarily.

This platform addresses these issues by automating the entire stack from bare AWS to a working, secure, and observable DevOps environment.

## 3. Goals & Purpose

The primary goals of building this infrastructure are:

- **Fully automated provisioning** – Every component (networking, VMs, tools) is created and configured using Terraform and Ansible, enabling repeatable, zero‑touch deployments.
- **Separation of concerns** – Distinct EC2 instances for control plane, monitoring, and Kubernetes nodes improve resource isolation and performance.
- **Security by default** – RBAC is enforced in Jenkins, Nexus, and SonarQube; no secrets are stored in Git; firewalls are tightly scoped.
- **Complete observability** – Metrics (Prometheus), logs (Loki/Promtail), and dashboards (Grafana) are provisioned automatically, giving immediate insights after deployment.
- **CI/CD readiness** – A working Jenkins pipeline for a MERN application demonstrates the end‑to‑end flow from code commit to containerised deployment.
- **Future‑proofing for Kubernetes** – K8s binaries are installed on dedicated nodes, ready to be bootstrapped for GitOps (e.g., ArgoCD) when required.
- **Cost efficiency** – Infrastructure can be torn down and recreated on demand, keeping costs near zero when not in active use.

## 4. Infrastructure Topology (5 EC2 Instances)

To balance cost, performance, and separation of concerns, the infrastructure is deployed in `eu-north-1` (Stockholm) across 5 EC2 instances. The instance types are defined as Terraform variables (see below).

### Terraform Variables for Instance Types

| Variable | Value |
|---|---|
| `control_plane_instance_type` | `t3.large` |
| `monitoring_instance_type` | `t3.medium` |
| `k8s_master_instance_type` | `t3.large` |
| `k8s_worker_instance_type` | `t3.medium` |

### Instance Configuration

| Role | Instance Type | Disk | Tools | Why |
|---|---|---|---|---|
| Control Plane | `t3.large` | 30 GB | Jenkins (8080), SonarQube (9000) | Jenkins and SonarQube are heavy Java apps. They are placed together on a high‑RAM server to avoid OOM crashes during plugin installations or scans. |
| Monitoring & Ops | `t3.medium` | 50 GB | Nexus (8081/8082), Prometheus (9090), Grafana (3000), Loki (3100) | Nexus requires large storage for Docker images; Prometheus and Grafana need moderate compute. Decoupling monitoring and artifact storage from CI/CD avoids resource contention during builds. |
| K8s Master | `t3.large` | 20 GB | Kubernetes API Server, etcd | Dedicated control plane for future K8s workloads. Requires adequate RAM for etcd and API components. |
| K8s Worker 1 | `t3.medium` | 25 GB | Docker, Kubelet, Node Exporter | Application workload node. |
| K8s Worker 2 | `t3.medium` | 25 GB | Docker, Kubelet, Node Exporter | Application workload node. |

### Container Placement (Actual)

The following containers are deployed per node as verified in the environment:

| Node | Running Containers |
|---|---|
| Control Plane | `jenkins`, `sonarqube`, `node_exporter`, `promtail` |
| Monitoring & Ops | `nexus`, `prometheus`, `grafana`, `loki`, `promtail`, `node_exporter` |
| K8s Master | `node_exporter` |
| K8s Worker 1 | `node_exporter` |
| K8s Worker 2 | `node_exporter` |

> **Note:** Promtail is currently deployed on Control Plane and Monitoring nodes only. It will be extended to Kubernetes nodes once containerised workloads are scheduled there.

## 5. Networking & Security

- **VPC & Subnets**: All servers reside in a single public subnet within a custom VPC.
- **Private IPs for Monitoring**: Prometheus scrapes targets using AWS Private IPs (`10.0.x.x`) to avoid AWS “Hairpin NAT” issues and keep internal traffic off the public internet.
- **Security Groups**: Strictly configured to allow SSH (22), web UI ports (8080, 8081, 9000, 3000), Node Exporter (9100), and Nexus Docker Registry (8082).
- **RBAC**:
  - **Jenkins**: Users (`admin`, `dev`, `tester`, `jrdevops`) are automatically provisioned via JCasC with strict matrix permissions (e.g., `jrdevops` cannot delete jobs).
  - **Nexus & SonarQube**: Users are provisioned via REST APIs. A `jenkins-ci` service account is used for Jenkins‑to‑Nexus communication, ensuring the admin account is never used in pipelines.

## 6. Observability Stack

The platform uses a decoupled observability strategy:

- **Metrics (Prometheus)**: Scrapes hardware metrics (Node Exporter) and application metrics (Jenkins) via AWS Private IPs.
- **Logs (Loki & Promtail)**: Promtail runs on **Control Plane and Monitoring nodes** using Docker Service Discovery. It automatically tails container logs and pushes them to Loki. Kubernetes nodes will receive Promtail when application workloads are deployed.
- **Visualization (Grafana)**: Auto‑provisioned via Ansible to connect to Prometheus and Loki, providing immediate dashboards (e.g., Node Exporter Full) without manual UI configuration.

## 7. Tool Versions (Pinned for Stability)

| Tool | Version / Tag |
|---|---|
| Jenkins | `lts-jdk21` |
| SonarQube | `9.9-community` |
| Nexus | `sonatype/nexus3:3.79.0` |
| Prometheus | `v3.13.1` |
| Grafana | `11.2.0` |
| Loki & Promtail | `2.9.0` |

## 8. Cost Estimation

The following estimate assumes **on‑demand pricing** in `eu-north-1` (Stockholm) and does **not** include data transfer, snapshots, or load balancers (if any). All figures are in **USD per month**.

### 8.1 Compute (EC2)

| Instance | Type | vCPU | RAM | On‑Demand Hourly | Monthly (730 h) |
|---|---|---|---|---|---|
| Control Plane | `t3.large` | 2 | 8 GiB | $0.0832 | $60.74 |
| Monitoring & Ops | `t3.medium` | 2 | 4 GiB | $0.0416 | $30.37 |
| K8s Master | `t3.large` | 2 | 8 GiB | $0.0832 | $60.74 |
| K8s Worker 1 | `t3.medium` | 2 | 4 GiB | $0.0416 | $30.37 |
| K8s Worker 2 | `t3.medium` | 2 | 4 GiB | $0.0416 | $30.37 |
| **Total EC2** | | | | | **$212.59** |

### 8.2 Storage (EBS, General Purpose SSD gp3)

| Volume | Size | Cost per GB‑month | Monthly |
|---|---|---|---|
| Control Plane | 30 GB | $0.114 | $3.42 |
| Monitoring & Ops | 50 GB | $0.114 | $5.70 |
| K8s Master | 20 GB | $0.114 | $2.28 |
| K8s Worker 1 | 25 GB | $0.114 | $2.85 |
| K8s Worker 2 | 25 GB | $0.114 | $2.85 |
| **Total EBS** | | | **$17.10** |

### 8.3 Networking (Data Transfer)

Minimal for internal traffic if all instances are in the same AZ. External transfer (e.g., pulling Docker images, Git, etc.) is estimated at **~10 GB/month** → **$0.90**.

### 8.4 Total Estimated Monthly Cost

| Component | Monthly Cost |
|---|---|
| EC2 Instances | $212.59 |
| EBS Volumes | $17.10 |
| Data Transfer (est.) | $0.90 |
| **Grand Total** | **$230.59** |

> 💡 **Cost‑Saving Tip:**  
> Because the entire stack is managed by Terraform, the environment can be destroyed when not in use (`terraform destroy`) and recreated in minutes (`terraform apply`). This brings the cost to **$0.00** when idle, apart from any retained EBS snapshots or S3 storage.

## 9. Deployment Options & Portability

While the reference deployment is on AWS, the entire platform is **cloud‑agnostic** by design. The same Terraform and Ansible code can be adapted to run on:

- **Local Virtual Machines (Vagrant + VirtualBox)** – For development, testing, or learning, you can spin up the same 5‑node topology on your local machine.
- **Other Cloud Providers** – With minor provider adjustments (e.g., Azure, GCP) or even on‑premises hypervisors.

### 9.1 Local Deployment with Vagrant

A `Vagrantfile` can be provided to create identical VMs (same hostnames, IP scheme, and resources) on your laptop. This enables:

- **Zero cloud cost** – Run the entire stack offline without incurring AWS charges.
- **Fast iteration** – Test configuration changes locally before deploying to the cloud.
- **Reproducible environments** – Team members can have an identical local setup.

### 9.2 How It Works

- **Terraform** provisions cloud resources (AWS). For local, a separate lightweight `Vagrantfile` is used to create VMs; both approaches generate a consistent **Ansible inventory**.
- **Ansible** playbooks are written to be **provider‑independent**—they only require SSH access and the target OS (Ubuntu). This means the same playbooks configure both AWS EC2 instances and local Vagrant boxes.