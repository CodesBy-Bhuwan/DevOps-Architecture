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

argocd:
	$(ANSIBLE) $(PLAYBOOK)/argocd.yml
