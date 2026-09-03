# Terraform — Infrastructure as Code

## 📖 Overview

**Terraform** is used to provision and manage the cloud infrastructure required by this project.

It follows an **Infrastructure as Code (IaC)** approach, allowing AWS resources to be created, modified, and removed using version-controlled configuration instead of manual configuration through the AWS Console.

### What Terraform manages

* AWS VPC and networking
* Subnets
* Internet Gateway
* Route tables
* Security Groups
* EC2 instances
* IAM resources
* Infrastructure variables and outputs

> **Terraform provisions the infrastructure; Ansible configures the servers and applications running on that infrastructure.**

---

## 🏗️ Terraform & Ansible Workflow

Terraform and Ansible have separate responsibilities:

```text
Terraform
    │
    ▼
AWS Infrastructure
    │
    ├── VPC
    ├── Subnets
    ├── Security Groups
    └── EC2 Instances
            │
            ▼
         Ansible
            │
            ├── Docker
            ├── Jenkins
            ├── SonarQube
            ├── Nexus
            ├── Monitoring
            └── Kubernetes
```

This separation keeps **infrastructure provisioning** independent from **server configuration**.

---

## 📁 Directory Structure

```text
terraform/
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── versions.tf
└── modules/
    ├── vpc/
    ├── security-groups/
    ├── ec2/
    └── iam/
```

### Important Files & Directories

| Path               | Purpose                                     |
| ------------------ | ------------------------------------------- |
| `providers.tf`     | Configures the AWS provider                 |
| `versions.tf`      | Terraform and provider version requirements |
| `main.tf`          | Main infrastructure resources               |
| `variables.tf`     | Input variables                             |
| `terraform.tfvars` | Environment-specific variable values        |
| `outputs.tf`       | Exposes useful resource information         |
| `modules/`         | Reusable infrastructure components          |

Individual resource definitions are kept modular so that infrastructure can be changed without managing one large Terraform file.

---


## Terraform Installation

### 1. Update packages

```bash
sudo apt update
```

### 2. Add HashiCorp repository

```bash
sudo apt install -y gnupg software-properties-common wget
```

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

### 3. Install Terraform

```bash
sudo apt update
sudo apt install -y terraform
```

### 4. Verify

```bash
terraform version
```

**Official Docs:** [Terraform Installation](https://developer.hashicorp.com/terraform/install)


## 🔐 AWS Authentication

Terraform uses the AWS credentials configured through the **AWS CLI**.

Verify the AWS identity before running Terraform:

```bash
aws sts get-caller-identity
```

Terraform can then use the authenticated AWS identity to provision resources.

> **Never hard-code AWS access keys or secrets inside `.tf` files.**

---

## 🚀 Terraform Workflow

Terraform follows a predictable workflow:

```text
Write Configuration
        │
        ▼
terraform init
        │
        ▼
terraform validate
        │
        ▼
terraform plan
        │
        ▼
terraform apply
        │
        ▼
AWS Infrastructure
```

### 1. Initialize

Run this when starting or cloning the Terraform project:

```bash
terraform init
```

Downloads required providers and initializes the working directory.

### 2. Validate

```bash
terraform validate
```

Checks whether the Terraform configuration is syntactically valid.

### 3. Review Changes

```bash
terraform plan
```

Shows what Terraform intends to create, modify, or destroy.

### 4. Provision Infrastructure

```bash
terraform apply
```

Review the proposed changes and confirm when prompted.

### 5. Destroy Infrastructure

When the environment is no longer required:

```bash
terraform destroy
```

> ⚠️ This removes resources managed by the Terraform configuration. Use it carefully.

---

## 📤 Outputs

Terraform outputs useful information after provisioning, such as:

* VPC ID
* Subnet IDs
* EC2 public/private IP addresses
* Security Group IDs
* Instance IDs

View outputs with:

```bash
terraform output
```

Specific output:

```bash
terraform output <output_name>
```

---

## 🧪 Safe Testing

Before applying changes, use:

```bash
terraform fmt
terraform validate
terraform plan
```

Recommended workflow:

```text
Change Configuration
        │
        ▼
terraform fmt
        │
        ▼
terraform validate
        │
        ▼
terraform plan
        │
        ▼
Review
        │
        ▼
terraform apply
```

---

## 🔄 Infrastructure Lifecycle

The complete infrastructure workflow is:

```text
AWS CLI
   │
   ▼
Terraform
   │
   ▼
AWS VPC & Networking
   │
   ▼
EC2 Instances
   │
   ▼
Ansible
   │
   ▼
Applications & DevOps Tools
```

Terraform is responsible for the **cloud infrastructure layer**, while Ansible handles the **configuration and application layer**.

---

## 🧩 Why Terraform?

* **Infrastructure as Code** — infrastructure is version controlled.
* **Repeatability** — environments can be recreated consistently.
* **Automation** — reduces manual AWS configuration.
* **Modularity** — reusable Terraform modules simplify infrastructure management.
* **Change visibility** — `terraform plan` shows changes before applying them.
* **Resource lifecycle management** — infrastructure can be created, updated, or destroyed from configuration.

---

## 📚 Documentation

* [Terraform Installation Guide](terraform-installation.md)
* [AWS CLI & IAM Setup](aws-cli-iam.md)
* [Terraform Official Documentation](https://developer.hashicorp.com/terraform/docs)



[**Back to Previous Page**](../../../README.md)