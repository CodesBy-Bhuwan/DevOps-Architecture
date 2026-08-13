# ==========================================
# Terraform
# ==========================================

.PHONY: tf-local tf-aws

tf-local:
	@echo "Running Terraform Local..."
	cd terraform/local && terraform apply -auto-approve

tf-aws:
	@echo "Running Terraform AWS..."
	cd terraform/aws && terraform apply -auto-approve
