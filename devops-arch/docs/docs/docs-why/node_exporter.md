# Node Exporter

## Description
Prometheus Node Exporter is a machine-level metrics exporter. It exposes a wide variety of hardware and OS metrics (CPU, memory, disk, network) from Linux systems in a format Prometheus can scrape.

## Why We Chose It
- **Standard Visibility:** It provides the foundational infrastructure metrics required to know if a server is healthy or about to crash.
- **Zero Configuration:** Once installed, it automatically exposes standard metrics on port 9100 without needing a complex config file.

## How We Used It
### Multi-Node Deployment
We used Ansible to install Node Exporter on all 5 EC2 instances (Control Plane, Monitoring, K8s Master, 2 Workers).

### Host Networking
We ran the container with `--network host` so it binds directly to the EC2 instance's network interface, allowing Prometheus to scrape it via the AWS Private IP (`10.0.x.x`).

### Dashboarding
We combined Node Exporter metrics with a pre-built Grafana dashboard (ID 1860) to instantly visualize CPU, RAM, and disk usage across the entire fleet.

## Why It Is Better Than Other Tools
- **vs. Telegraf:** Telegraf is powerful but plugin-heavy and requires a configuration file. Node Exporter is purpose-built for Prometheus, lightweight, and requires almost zero configuration to start gathering critical system metrics.
- **vs. CloudWatch Agent:** CloudWatch agent sends data to AWS, incurring costs and requiring IAM roles. Node Exporter is free, self-hosted, and keeps data within our private VPC.