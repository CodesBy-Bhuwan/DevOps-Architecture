.DEFAULT_GOAL := help

include make/config.mk
include make/infrastructure.mk
include make/provisioning.mk
include make/platform.mk
include make/kubernetes.mk
include make/terraform.mk

bootstrap:
	$(ANSIBLE) $(PLAYBOOK)/bootstrap.yml

.PHONY: help \
        up halt destroy \
        bootstrap provision \
        docker kubernetes jenkins sonarqube nexus prometheus grafana argocd \
        start stop status \
        nodes pods \
        tf-init tf-plan tf-apply tf-destroy

help:
	@echo ""
	@echo "========== DevOps Lab =========="
	@echo ""
	@echo "Infrastructure"
	@echo "  make up"
	@echo "  make bootstrap"
	@echo "  make halt"
	@echo "  make destroy"
	@echo ""
	@echo "Provision"
	@echo "  make provision"
	@echo "  make docker"
	@echo ""
	@echo "  make kubernetes"
	@echo "  make stop-kubernetes"
	@echo ""
	@echo "  make jenkins"
	@echo "  make jenkins-base"
	@echo "  make jenkins-plugins"
	@echo "  make sonarqube"
	@echo "  make integrate-all"
	@echo "  make stop-jenkins"
	@echo ""
	@echo "  make integrate-nexus"
	@echo "  make integrate-sonar"
	@echo "  make integrate-jenkins"
	@echo ""
	@echo "  make stop-sonarqube"
	@echo ""
	@echo "  make nexus"
	@echo "  make stop-nexus"
	@echo ""
	@echo "  make prometheus"
	@echo "  make stop-prometheus"
	@echo ""
	@echo "  make grafana"
	@echo "  make stop-grafana"
	@echo ""
	@echo "  make argocd"
	@echo ""
	@echo "Platform"
	@echo "  make start"
	@echo "  make stop"
	@echo "  make status"
	@echo ""
	@echo "Kubernetes"
	@echo "  make nodes"
	@echo "  make pods"
	@echo ""
	@echo "Terraform"
	@echo "  make aws-init"
	@echo "  make aws-plan"
	@echo "  make aws-up"
	@echo "  make inventory"
	@echo "  make aws-destroy"
	@echo "  """
