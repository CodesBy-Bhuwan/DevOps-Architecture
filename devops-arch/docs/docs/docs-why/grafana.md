# Grafana

## Description
Grafana is a multi-platform open-source analytics and interactive visualization web application. It provides charts, graphs, and alerts for the web when connected to supported data sources.

## Why We Chose It
- **Multi-Source Visualization:** Grafana can display Prometheus metrics and Loki logs on the exact same dashboard, providing a unified view of system health.
- **Dynamic Dashboards:** Allows for templating variables (e.g., switching between different EC2 instances with a dropdown menu).
- **Provisioning Support:** Supports configuration-as-code, allowing dashboards and data sources to be automated.

## How We Used It
### Auto-Provisioning
We mounted a `/etc/grafana/provisioning/datasources` directory into the Grafana container. Using a Jinja2 template (`datasources.yml.j2`), Ansible automatically configured Grafana to connect to Prometheus and Loki on boot—zero manual UI clicks required.

### Unified Observability
We used Grafana's "Explore" tab to query Loki for live container logs, correlating them with Prometheus CPU/RAM spikes to troubleshoot OOM crashes.

## Why It Is Better Than Other Tools
- **vs. Kibana:** Kibana is heavily tied to the Elastic Stack and is primarily a log visualization tool. Grafana is agnostic and excels at time-series metrics (Prometheus) while still supporting logs (Loki).
- **vs. Tableau:** Grafana is open-source, built for DevOps/infrastructure monitoring, and integrates natively with cloud-native databases.



[**Back to Previous Page**](../../../README.md)