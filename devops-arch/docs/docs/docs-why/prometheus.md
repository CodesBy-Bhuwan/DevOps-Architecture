# Prometheus

## Description
Prometheus is an open-source systems monitoring and alerting toolkit. It collects and stores metrics as time-series data, recording information with a timestamp.

## Why We Chose It
- **Pull-Based Architecture:** Prometheus actively scrapes metrics from targets, making it easy to detect when a server goes offline (the metrics simply stop appearing).
- **Powerful Query Language (PromQL):** Allows for deep slicing and dicing of metrics data for highly customized dashboards and alerts.
- **Cloud-Native Standard:** It is the default monitoring tool for Kubernetes and cloud-native ecosystems.

## How We Used It
### Host Networking
Deployed via Docker using `--network host` to bypass Docker's internal NAT and allow direct scraping of AWS Private IPs.

### Dynamic Target Discovery
We used a Jinja2 template to loop through the Ansible inventory. If we add a new EC2 instance, Prometheus automatically begins scraping its `node_exporter` metrics without manual config changes.

### AWS Hairpin NAT Bypass
We configured the `prometheus.yml.j2` template to use `private_ip` variables instead of public IPs, solving the AWS networking timeout issues.

## Why It Is Better Than Other Tools
- **vs. CloudWatch:** CloudWatch is locked to AWS and incurs costs for custom metrics. Prometheus is free, open-source, and works across any cloud or on-prem infrastructure.
- **vs. InfluxDB:** Prometheus has built-in alerting (AlertManager) and is deeply integrated with Grafana out of the box, making it superior for comprehensive observability.



[**Back to Previous Page**](../../../README.md)