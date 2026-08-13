
##################START

start:
	$(ANSIBLE) $(PLAYBOOK)/control/start/all.yml

start-jenkins:
	$(ANSIBLE) $(PLAYBOOK)/control/jenkins.yml

start-sonarqube:
	$(ANSIBLE) $(PLAYBOOK)/control/sonarqube.yml

start-nexus:
	$(ANSIBLE) $(PLAYBOOK)/control/nexus.yml

start-prometheus:
	$(ANSIBLE) $(PLAYBOOK)/control/prometheus.yml

start-grafana:
	$(ANSIBLE) $(PLAYBOOK)/control/grafana.yml


##################STOP

stop:
	$(ANSIBLE) $(PLAYBOOK)/control/stop/all.yml

stop-jenkins:
	$(ANSIBLE) $(PLAYBOOK)/control/stop/jenkins.yml

stop-sonarqube:
	$(ANSIBLE) $(PLAYBOOK)/control/stop/sonarqube.yml

stop-nexus:
	$(ANSIBLE) $(PLAYBOOK)/control/stop/nexus.yml

stop-prometheus:
	$(ANSIBLE) $(PLAYBOOK)/control/stop/prometheus.yml

stop-grafana:
	$(ANSIBLE) $(PLAYBOOK)/control/stop/grafana.yml


##################STATUS

status:
	$(ANSIBLE) $(PLAYBOOK)/control/status/all.yml
	@echo "=================================================="
	@echo "🌐 DEVOPS PLATFORM DASHBOARD (ENV: $(ENV))"
	@echo "=================================================="
	@awk -F'[ =]' '/^\[/ {group=$$1} /ansible_host/ {print "  " group " -> http://" $$3 ":8080 (Jenkins)"}' ansible/inventory/$(ENV).ini 2>/dev/null || echo "  Inventory file not found. Run 'make aws-up' first."
	@awk -F'[ =]' '/^\[/ {group=$$1} /ansible_host/ {print "  " group " -> http://" $$3 ":9000 (SonarQube)"}' ansible/inventory/$(ENV).ini 2>/dev/null
	@awk -F'[ =]' '/^\[/ {group=$$1} /ansible_host/ {print "  " group " -> http://" $$3 ":8081 (Nexus)"}' ansible/inventory/$(ENV).ini 2>/dev/null
	@awk -F'[ =]' '/^\[/ {group=$$1} /ansible_host/ {print "  " group " -> http://" $$3 ":3000 (Grafana)"}' ansible/inventory/$(ENV).ini 2>/dev/null
	@awk -F'[ =]' '/^\[/ {group=$$1} /ansible_host/ {print "  " group " -> http://" $$3 ":9090 (Prometheus)"}' ansible/inventory/$(ENV).ini 2>/dev/null
	@echo "=================================================="
	@echo "🐳 DOCKER CONTAINER STATUS"
	@echo "=================================================="
	# Use raw 'ansible' command, not $(ANSIBLE) which is ansible-playbook
	#ansible all -i ansible/inventory/$(ENV).ini -b -m shell -a "docker ps --format 'table {{.Names}}\t{{.Ports}}\t{{.Status}}'"
