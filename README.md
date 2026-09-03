*This file explains the "Why" and the structural design of our platform.*

# DevOps Platform Architecture

## 1. Overview

This document outlines the architecture of the automated DevOps platform hosted on AWS. The platform is designed to support both standard Docker deployments and Kubernetes (GitOps) workflows, with a strong emphasis on Infrastructure as Code (IaC), Configuration as Code (CaC), and Observability.

## 2. Infrastructure Topology (5 EC2 Instances)

To balance cost, performance, and separation of concerns, the infrastructure is deployed in `eu-north-1` (Stockholm) across 5 EC2 instances:

1. **Control Plane (`t3.large`, 30GB Disk)**
   - **Role:** The CI/CD engine.
   - **Tools:** Jenkins (port 8080), SonarQube (port 9000).
   - **Why:** Both are heavy Java applications. They are placed on the same high-RAM server to consolidate resources while maintaining enough memory to prevent Out-Of-Memory (OOM) crashes during plugin installations or code scans.

2. **Monitoring & Ops (`t3.medium`, 50GB Disk)**
   - **Role:** The Observability and Artifact hub.
   - **Tools:** Nexus (8081/8082), Prometheus (9090), Grafana (3000), Loki (3100).
   - **Why:** Nexus requires large storage for Docker images, and Grafana/Prometheus require moderate compute to aggregate metrics and logs.

3. **K8s Master (`t3.large`, 20GB Disk)**
   - **Role:** Kubernetes Control Plane.
   - **Tools:** K8s API Server, etcd.

4. **K8s Workers x2 (`t3.medium`, 25GB Disk)**
   - **Role:** Application workloads.
   - **Tools:** Container Runtime (Docker), Kubelet.

## 3. Networking & Security

- **VPC & Subnets:** All servers reside in a single public subnet within a custom VPC.
- **Private IPs for Monitoring:** To bypass AWS "Hairpin NAT" issues, Prometheus scrapes targets using their AWS Private IPs (`10.0.x.x`) rather than public IPs.
- **Security Groups (Firewalls):** Strictly configured to allow SSH (22), web UI ports (8080, 9000, 3000), Node Exporter (9100), and Nexus Docker Registry (8082).
- **RBAC (Role-Based Access Control):**
  - **Jenkins:** Users (`dev`, `tester`, `jrdevops`) are automatically provisioned via JCasC with strict matrix permissions (e.g., `jrdevops` cannot delete jobs).
  - **Nexus & SonarQube:** Users are provisioned via REST APIs. A `jenkins-ci` Service Account is used for Jenkins-to-Nexus communication, ensuring the `admin` account is never used in pipelines.

## 4. Observability Stack

The platform uses a decoupled observability strategy:

- **Metrics (Prometheus):** Scrapes hardware metrics (Node Exporter) and application metrics (Jenkins).
- **Logs (Loki & Promtail):** Promtail runs on all servers using Docker Service Discovery. It automatically tails all container logs and pushes them to Loki.
- **Visualization (Grafana):** Auto-provisioned via Ansible to connect to Prometheus and Loki, providing immediate dashboards without manual UI configuration.

## 5. Tool Versions (Pinned for Stability)

- **Jenkins:** `lts-jdk21`
- **SonarQube:** `9.9-community`
- **Nexus:** `sonatype/nexus3:3.79.0`
- **Prometheus:** `v3.13.1`
- **Grafana:** `11.2.0`
- **Loki & Promtail:** `2.9.0`
