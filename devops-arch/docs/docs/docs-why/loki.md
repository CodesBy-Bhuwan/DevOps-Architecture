# Loki

## Description
Loki is a horizontally scalable, highly available, multi-tenant log aggregation system inspired by Prometheus. It is designed to be cost-effective and easy to operate.

## Why We Chose It
- **Index Metadata, Not Content:** Unlike traditional log tools, Loki only indexes the labels (metadata) of your logs, not the full text. This makes it incredibly lightweight and cheap to run.
- **Grafana Integration:** Built by the Grafana team, it integrates seamlessly, allowing you to view metrics and logs in the same UI.
- **Prometheus Syntax:** Uses LogQL, a query language very similar to PromQL, reducing the learning curve.

## How We Used It
### Deployed on Monitoring Node
We ran the Loki Docker container (`grafana/loki:2.9.0`) on the Monitoring EC2 instance, exposing port 3100.

### Permission Management
We had to explicitly set the `/opt/loki` directory ownership to UID `10001` in our Ansible role, as the Loki container runs as a non-root user and would crash if the directory was owned by root.

## Why It Is Better Than Other Tools
- **vs. Elasticsearch/ELK Stack:** The ELK stack requires massive amounts of RAM and CPU to index full-text logs. Loki uses a fraction of the resources because it only indexes labels, making it perfect for a single `t3.medium` EC2 instance.
- **vs. CloudWatch Logs:** CloudWatch requires agents and incurs ingestion costs. Loki is free, self-hosted, and highly performant.