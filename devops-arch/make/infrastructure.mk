.PHONY: up halt destroy reload ssh-master ssh-worker1 ssh-worker2

up:
	cd $(VAGRANT_DIR) && vagrant up

halt:
	cd $(VAGRANT_DIR) && vagrant halt

reload:
	cd $(VAGRANT_DIR) && vagrant reload

destroy:
	cd $(VAGRANT_DIR) && vagrant destroy -f

ssh-master:
	cd $(VAGRANT_DIR) && vagrant ssh $(MASTER)

ssh-worker1:
	cd $(VAGRANT_DIR) && vagrant ssh $(WORKER1)

ssh-worker2:
	cd $(VAGRANT_DIR) && vagrant ssh $(WORKER2)

.PHONY: aws-up aws-destroy aws-refresh inventory

# 1. Build AWS Infrastructure and generate Ansible inventory

aws-init: 
	@echo "Initializing..."
	cd terraform/envs/dev && terraform init

aws-up:
	@echo "Building AWS Infrastructure..."
	cd terraform/envs/dev && terraform apply -auto-approve
	@echo "Generating Ansible Inventory..."
	./scripts/generate-ansible-inventory.sh
	@echo "AWS servers are up and Ansible is ready!"

aws-plan:
	@echo "Plan AWS Infrastructure..."
	cd terraform/envs/dev && terraform plan

# 2. Destroy AWS Infrastructure to save money
aws-destroy:
	@echo "Destroying AWS Infrastructure..."
	cd terraform/envs/dev && terraform destroy -auto-approve
	@echo "AWS servers have been destroyed. Billing stopped."

# 3. Just refresh the Ansible inventory (if you manually changed Terraform)
inventory:
	./scripts/generate-ansible-inventory.sh
