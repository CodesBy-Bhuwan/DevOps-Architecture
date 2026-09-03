# Promtail

## Description
Promtail is an agent which ships the contents of local logs to a private Grafana Loki instance. It is the log shipping companion for Loki.

## Why We Chose It
- **Native Loki Integration:** It is specifically built to label and ship logs directly to Loki.
- **Docker Service Discovery:** It can automatically discover running Docker containers and begin tailing their logs without manual configuration.

## How We Used It
### Multi-Node Deployment
We deployed Promtail via Ansible on both the Control Plane and Monitoring nodes, ensuring we collected logs from Jenkins, SonarQube, Nexus, and the monitoring tools themselves.

### Docker Socket Mounting
We mounted `/var/run/docker.sock` into the Promtail container. This allowed Promtail to use Docker Service Discovery to automatically find new containers, extract their names as labels, and ship their `stdout`/`stderr` logs to Loki.

### Host Networking
We used `--network host` to ensure Promtail could reliably communicate with local Docker daemons and the Loki service.

## Why It Is Better Than Other Tools
- **vs. Fluentd/Fluent Bit:** Fluentd requires complex configuration files to parse and route logs. Promtail is simpler, relies on labels (just like Prometheus), and is the official agent for Loki.
- **vs. Logstash:** Logstash is heavy (Java-based) and resource-intensive. Promtail is written in Go, uses minimal RAM, and is designed specifically for cloud-native architectures.



[**Back to Previous Page**](../../../README.md)