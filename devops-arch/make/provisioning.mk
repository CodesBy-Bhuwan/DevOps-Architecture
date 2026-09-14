.PHONY: provision

provision:
	$(ANSIBLE) $(PLAYBOOK)/provision.yml

docker:
	$(ANSIBLE) $(PLAYBOOK)/docker.yml

kubernetes:
	$(ANSIBLE) $(PLAYBOOK)/kubernetes.yml

jenkins:
	$(ANSIBLE) $(PLAYBOOK)/jenkins.yml --tags "jenkins_base" && $(ANSIBLE) $(PLAYBOOK)/jenkins.yml --tags "jenkins_plugins"

jenkins-base:
	$(ANSIBLE) $(PLAYBOOK)/jenkins.yml --tags "jenkins_base"

jenkins-plugins:
	$(ANSIBLE) $(PLAYBOOK)/jenkins.yml --tags "jenkins_plugins"

sonarqube:
	$(ANSIBLE) $(PLAYBOOK)/sonarqube.yml

integrate-nexus:
	$(ANSIBLE) $(PLAYBOOK)/integrate-tools.yml --tags "nexus"

integrate-sonar:
	$(ANSIBLE) $(PLAYBOOK)/integrate-tools.yml --tags "sonar"

integrate-jenkins:
	$(ANSIBLE) $(PLAYBOOK)/integrate-tools.yml --tags "jenkins"

integrate-all:
	$(ANSIBLE) $(PLAYBOOK)/integrate-all.yml

nexus:
	$(ANSIBLE) $(PLAYBOOK)/nexus.yml

node-export:
	$(ANSIBLE) $(PLAYBOOK)/monitoring.yml

prometheus:
	$(ANSIBLE) $(PLAYBOOK)/prometheus.yml

grafana:
	$(ANSIBLE) $(PLAYBOOK)/grafana.yml

loki:
	$(ANSIBLE) $(PLAYBOOK)/loki.yml

promtail:
	$(ANSIBLE) $(PLAYBOOK)/promtail.yml

integrate-monitor:
	$(ANSIBLE) $(PLAYBOOK)/integrate-monitor.yml

# ==========================================
# MONITORING & DASHBOARDS
# ==========================================

cadvisor:
	$(ANSIBLE) $(PLAYBOOK)/cadvisor.yml

grafana-rebuild:
	@echo "Wiping old Grafana container and data..."
	ansible monitoring_ops -i $(INVENTORY) -b -m shell -a "docker rm -f grafana; rm -rf /opt/grafana"
	@echo "Rebuilding Grafana with new volume mounts..."
	$(MAKE) grafana ENV=$(ENV)

# Master command to set up the entire observability stack
monitoring-setup:
	@echo "Step 1: Installing cAdvisor..."
	$(MAKE) cadvisor ENV=$(ENV)
	@echo "Step 2: Rebuilding Grafana..."
	$(MAKE) grafana-rebuild ENV=$(ENV)
	@echo "Step 3: Running Monitoring Integration (Prometheus config & Dashboards)..."
	$(MAKE) integrate-monitor ENV=$(ENV)
	@echo "Observability stack setup complete! Wait 30s for Grafana to boot."

argocd:
	$(ANSIBLE) $(PLAYBOOK)/argocd.yml
