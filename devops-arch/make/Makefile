# ==========================================
# DevOps Lab Makefile
# ==========================================

.DEFAULT_GOAL := help

ANSIBLE_INVENTORY = ansible/inventory/dev.ini

# Hardcoded node names (matches your Vagrantfile)
MASTER_NODE = master
WORKER_NODES = worker1 worker2

# Paths
VAGRANT_DIR = vagrant
KUBECONFIG = ~/.kube/config

.PHONY: help up halt destroy provision deploy status

help:
	@echo ""
	@echo "========== DevOps Lab =========="
	@echo "=============================="
	@echo "Infrastructure"
	@echo "=============================="
	@echo ""
	@echo "make up"
	@echo "make halt"
	@echo "make destroy"
	@echo ""
	@echo "=============================="
	@echo "Provisioning"
	@echo "=============================="
	@echo ""
	@echo "make provision"
	@echo "make deploy"
	@echo ""
	@echo "=============================="
	@echo "Kubernetes"
	@echo "=============================="
	@echo ""
	@echo "make k8s-bootstrap"
	@echo "make k8s-status"
	@echo "make k8s-reset"
	@echo "make k8s-check"
	@echo ""
	@echo "=============================="
	@echo "Platform"
	@echo "=============================="
	@echo ""
	@echo "make start"
	@echo "make stop"
	@echo "make restart"
	@echo "make status"
	@echo ""
	@echo "make jenkins-start"
	@echo "make jenkins-stop"
	@echo ""
	@echo "make sonarqube-start"
	@echo "make sonarqube-stop"
	@echo ""
	@echo "make nexus-start"
	@echo "make nexus-stop"
	@echo ""
	@echo "make prometheus-start"
	@echo "make prometheus-stop"
	@echo ""
	@echo "make grafana-start"
	@echo "make grafana-stop"
	@echo ""
	@echo "=============================="
	@echo "Terraform"
	@echo "=============================="
	@echo ""
	@echo "make tf-local"
	@echo "make tf-aws"
	@echo ""
	@echo "=============================="
	@echo "Utilities"
	@echo "=============================="
	@echo ""
	@echo "make help"


# ==========================================
# Infrastructure
# ==========================================

up:
	cd $(VAGRANT_DIR) && vagrant up

halt:
	cd $(VAGRANT_DIR) && vagrant halt

destroy:
	cd $(VAGRANT_DIR) && vagrant destroy -f


# ==========================================
# Provisioning
# ==========================================

provision:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/provision.yml

deploy:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/site.yml


# ==========================================
# Kubernetes - ACTUAL HARDCODED COMMANDS
# ==========================================

k8s-bootstrap:
	@echo "=========================================="
	@echo "🚀 Bootstrapping Kubernetes cluster..."
	@echo "=========================================="
	@echo ""
	@echo "Step 1: Initializing master node..."
	vagrant ssh $(MASTER_NODE) -c "sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.10"
	@echo ""
	@echo "Step 2: Setting up kubectl on master..."
	vagrant ssh $(MASTER_NODE) -c "mkdir -p $$HOME/.kube && sudo cp /etc/kubernetes/admin.conf $$HOME/.kube/config && sudo chown $$(id -u):$$(id -g) $$HOME/.kube/config"
	@echo ""
	@echo "Step 3: Installing Flannel CNI (pod network)..."
	vagrant ssh $(MASTER_NODE) -c "kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"
	@echo ""
	@echo "Step 4: Waiting for master to be ready (30s)..."
	sleep 30
	@echo ""
	@echo "Step 5: Generating join token and joining worker nodes..."
	vagrant ssh $(MASTER_NODE) -c "kubeadm token create --print-join-command" > /tmp/join_command
	@echo ""
	$(foreach node,$(WORKER_NODES),echo "Joining $(node)..."; vagrant ssh $(node) -c "sudo $$(cat /tmp/join_command)"; echo "";)
	@echo ""
	@echo "Step 6: Verifying cluster status..."
	vagrant ssh $(MASTER_NODE) -c "kubectl get nodes"
	@echo ""
	@echo "✅ Kubernetes cluster is ready!"
	@echo "=========================================="

k8s-status:
	@echo "=========================================="
	@echo "📊 Kubernetes Cluster Status"
	@echo "=========================================="
	@echo ""
	@echo "Nodes:"
	vagrant ssh $(MASTER_NODE) -c "kubectl get nodes -o wide"
	@echo ""
	@echo "Pods (all namespaces):"
	vagrant ssh $(MASTER_NODE) -c "kubectl get pods -A"
	@echo ""
	@echo "Services:"
	vagrant ssh $(MASTER_NODE) -c "kubectl get svc -A"
	@echo "=========================================="

k8s-reset:
	@echo "=========================================="
	@echo "⚠️  Resetting Kubernetes cluster..."
	@echo "=========================================="
	@read -p "Are you sure you want to reset the cluster? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "Resetting master..."; \
		vagrant ssh $(MASTER_NODE) -c "sudo kubeadm reset -f"; \
		$(foreach node,$(WORKER_NODES),echo "Resetting $(node)..."; vagrant ssh $(node) -c "sudo kubeadm reset -f"; echo "";) \
		echo "✅ Cluster reset complete!"; \
	else \
		echo "Aborted."; \
	fi
	@echo "=========================================="

k8s-check:
	@echo "=========================================="
	@echo "🔍 Kubernetes Health Check"
	@echo "=========================================="
	@echo ""
	@echo "Cluster Info:"
	vagrant ssh $(MASTER_NODE) -c "kubectl cluster-info"
	@echo ""
	@echo "Control Plane Status:"
	vagrant ssh $(MASTER_NODE) -c "kubectl get componentstatuses || echo 'Componentstatus API deprecated in newer K8s versions'"
	@echo ""
	@echo "Node Health:"
	vagrant ssh $(MASTER_NODE) -c "kubectl get nodes && kubectl describe nodes | grep -A5 Conditions"
	@echo "=========================================="


# ==========================================
# Platform - Docker and Services
# ==========================================

docker_start:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/docker.yml

start:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/control/start/all.yml

status:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/control/status/all.yml

stop:
	# FIXED: Changed 'all/yml' to 'all.yml'
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/control/stop/all.yml

restart: stop start


# ==========================================
# Platform - Individual Services
# ==========================================

jenkins-start:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/jenkins.yml

jenkins-stop:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/control/stop/jenkins.yml


sonarqube-start:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/sonarqube.yml

sonarqube-stop:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/control/stop/sonarqube.yml


nexus-start:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/nexus.yml

nexus-stop:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/control/stop/nexus.yml


prometheus-start:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/control/start/prometheus.yml

prometheus-stop:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/control/stop/prometheus.yml


grafana-start:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/grafana.yml

grafana-stop:
	ansible-playbook -i $(ANSIBLE_INVENTORY) ansible/playbooks/control/stop/grafana.yml


# ==========================================
# Terraform (Placeholders - you'll implement later)
# ==========================================

tf-local:
	@echo "🏗️  Terraform local environment - NOT YET IMPLEMENTED"
	@echo "Placeholder for: cd terraform/local && terraform apply"

tf-aws:
	@echo "☁️  Terraform AWS environment - NOT YET IMPLEMENTED"
	@echo "Placeholder for: cd terraform/aws && terraform apply"
