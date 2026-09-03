# Terraform

## Description
Terraform is an Infrastructure as Code (IaC) tool created by HashiCorp. It allows users to define and provision cloud data center infrastructure using a declarative configuration language known as HashiCorp Configuration Language (HCL).

## Why We Chose It
- **Declarative Automation:** We define what the infrastructure should look like, and Terraform figures out how to build it, ensuring exact state matching.
- **Cloud Agnosticism:** The same workflow principles apply whether we are deploying to AWS, Azure, or GCP.
- **State Management:** The `terraform.tfstate` file keeps track of exactly what resources exist, allowing for safe updates and clean destructions.

## How We Used It
### Modular Architecture
We split our code into reusable modules (networking, security, compute) to keep the code DRY (Don't Repeat Yourself) and organized.

### Dynamic Inventory Generation
We used the `local_file` resource to automatically generate the `aws.ini` Ansible inventory file immediately after creating the EC2 instances.

### Hairpin NAT Solution
To solve AWS routing issues, we configured Terraform to output both `public_ip` and `private_ip` directly into the Ansible inventory file.

### Cost Control
We utilized the `terraform destroy / apply` loop to tear down all AWS resources after testing, ensuring a $0.00 cloud bill.

## Why It Is Better Than Other Tools
- **vs. AWS CloudFormation:** Terraform is cloud-agnostic and uses a much cleaner, easier-to-read syntax (HCL) compared to CloudFormation's verbose JSON/YAML.
- **vs. Ansible for Provisioning:** While Ansible can provision infrastructure, Terraform is strictly declarative. If someone manually deletes an EC2 instance, Terraform will detect the drift and rebuild it automatically.