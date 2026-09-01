# 🏗️ Terraform

> Infrastructure as Code (IaC) used to provision and manage the AWS foundation of this DevOps platform — VPC, networking, security, EC2 instances, IAM, and supporting infrastructure.

---

## 📌 What is it?

Terraform is the Infrastructure as Code tool used to create and manage the **AWS infrastructure layer** of this platform.

Instead of creating AWS resources manually from the AWS Console, the infrastructure is defined in version-controlled Terraform configuration files.

Terraform is responsible for the **infrastructure layer**. After the servers are provisioned, **Ansible** is used for operating-system configuration, Docker installation, and deployment of the DevOps tools.

### Responsibility split

```text
Terraform
    │
    ├── VPC
    ├── Subnets
    ├── Internet Gateway
    ├── Route Tables
    ├── Security Groups
    ├── EC2 Instances
    └── IAM / Access Configuration
            │
            ▼
         Ansible
            │
            ├── Docker
            ├── Jenkins
            ├── SonarQube
            ├── Nexus
            ├── Monitoring Stack
            └── Kubernetes Prerequisites
```

---

## 📦 Version

| **Component** | **Version / Requirement** | **Source** |
|---|---|---|
| Terraform | `>= 1.5.0` | HashiCorp |
| AWS Provider | Defined in `versions.tf` | Terraform Registry |

> Terraform and provider versions should be controlled through `versions.tf` so the infrastructure remains reproducible.

---

## 🖥️ Where it runs

Terraform is executed from the **operator/development machine**, not from the EC2 servers.

```text
Developer / Admin Machine
          │
          │ Terraform
          ▼
       AWS API
          │
          ▼
    AWS Infrastructure
          │
          ├── control-plane
          ├── monitoring
          ├── k8s-master
          ├── k8s-worker-1
          └── k8s-worker-2
```

The AWS credentials used by Terraform come from the AWS CLI/IAM configuration.

---

## 📁 Terraform Structure

```text
terraform/
├── main.tf
├── providers.tf
├── versions.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── .gitignore
└── modules/
    ├── vpc/
    ├── security-groups/
    ├── ec2/
    └── iam/
```

### Important files

| **File / Directory** | **Purpose** |
|---|---|
| `main.tf` | Main infrastructure resources and module usage |
| `providers.tf` | AWS provider configuration |
| `versions.tf` | Terraform and provider version constraints |
| `variables.tf` | Input variable definitions |
| `terraform.tfvars` | Environment-specific variable values |
| `outputs.tf` | Useful resource outputs such as IDs and IPs |
| `modules/` | Reusable infrastructure components |
| `.gitignore` | Prevents Terraform state and sensitive files from being committed |

> Individual `.tf` files are intentionally separated by responsibility. Contributors do not need to understand every resource definition before using the infrastructure.

---

## ☁️ AWS Resources

Terraform provisions the AWS foundation required by the platform:

| **Resource** | **Purpose** |
|---|---|
| VPC | Isolated AWS network |
| Subnets | Network segmentation |
| Internet Gateway | Internet connectivity |
| Route Tables | Network routing |
| Security Groups | Instance-level traffic control |
| EC2 | Compute resources for the platform |
| IAM | Access and permission management |

The resulting EC2 environment contains:

| **Server** | **Role** |
|---|---|
| `control-plane` | Jenkins, SonarQube, Nexus |
| `monitoring` | Prometheus, Grafana, Loki, Promtail |
| `k8s-master` | Kubernetes control-plane node |
| `k8s-worker-1` | Kubernetes worker |
| `k8s-worker-2` | Kubernetes worker |

---

## 🔐 AWS Authentication

Terraform uses the AWS identity configured through the AWS CLI.

Verify the active AWS identity before running Terraform:

```bash
aws sts get-caller-identity
```

The command should return the IAM identity and AWS account currently being used.

> **Security:** Do not place AWS access keys directly inside `.tf` files or commit credential files to the repository.

See [**AWS CLI & IAM Setup →**](../prerequisites/aws-cli-iam.md).

---

## 🚀 Terraform Workflow

```text
Terraform Configuration
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

### Initialize

```bash
terraform init
```

### Format

```bash
terraform fmt -recursive
```

### Validate

```bash
terraform validate
```

### Review changes

```bash
terraform plan
```

### Provision infrastructure

```bash
terraform apply
```

### View outputs

```bash
terraform output
```

### Destroy infrastructure

```bash
terraform destroy
```

> ⚠️ `terraform destroy` removes resources managed by the Terraform configuration. Use it only when the environment is intentionally being decommissioned.

---

## 🔄 Terraform → Ansible Workflow

Terraform and Ansible intentionally have different responsibilities.

```text
Terraform
    │
    │ Provision
    ▼
AWS VPC + EC2 + Security
    │
    ▼
EC2 Servers
    │
    │ Configure
    ▼
Ansible
    │
    ├── Docker
    ├── Jenkins
    ├── SonarQube
    ├── Nexus
    ├── Monitoring
    └── Kubernetes Preparation
```

This separation makes it possible to rebuild the AWS infrastructure without mixing infrastructure provisioning with application/tool configuration.

---

## 📤 Outputs

Terraform outputs are used to expose information needed by the next stage of the deployment process.

Typical outputs include:

- VPC ID
- Subnet IDs
- Security Group IDs
- EC2 instance IDs
- Private IP addresses
- Public IP addresses

View all outputs:

```bash
terraform output
```

Get one specific output:

```bash
terraform output <output-name>
```

These values can then be used when configuring the Ansible inventory.

---

## 🗃️ Terraform State

Terraform maintains a **state file** to track the infrastructure it manages.

Typical local state files include:

```text
terraform.tfstate
terraform.tfstate.backup
```

These files can contain sensitive infrastructure information.

> **Never commit Terraform state files to GitHub.**

Recommended `.gitignore` entries:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
```

> Keep `.terraform.lock.hcl` tracked if the repository uses it to lock provider versions.

---

## 🔍 Verification

Check AWS resources:

```bash
aws ec2 describe-vpcs
aws ec2 describe-subnets
aws ec2 describe-instances
```

Check Terraform state:

```bash
terraform show
```

Check outputs:

```bash
terraform output
```

---

## 🧯 Troubleshooting

| **Symptom** | **Likely Cause** | **Check / Fix** |
|---|---|---|
| `No valid credential sources found` | AWS credentials unavailable | Run `aws sts get-caller-identity` |
| `terraform init` fails | Provider/network issue | Check connectivity and provider configuration |
| Unexpected resources in `plan` | Configuration/state mismatch | Review `terraform plan` carefully |
| EC2 cannot be reached | Security Group/routing issue | Check Security Groups, routes, and addressing |
| State lock/error | Another Terraform process or stale lock | Ensure no other run is active before resolving |
| Variables not found | Missing variable values | Check `variables.tf` and `terraform.tfvars` |

---

## 🔒 Security Notes

| **Concern** | **Current Practice** | **Recommended Practice** |
|---|---|---|
| AWS credentials | Managed through AWS CLI/IAM | Prefer temporary credentials or IAM roles where possible |
| IAM permissions | Controlled through IAM | Follow least privilege |
| Terraform state | Local state | Use encrypted remote state with locking for shared environments |
| Secrets in `.tf` files | Avoided | Use AWS Secrets Manager, SSM, or another secret store |
| Security Groups | Explicitly configured | Allow only required ports and sources |

---

## 🛠️ Maintenance

Before modifying infrastructure:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

Recommended workflow:

```text
Change
  │
  ▼
Format
  │
  ▼
Validate
  │
  ▼
Plan
  │
  ▼
Review
  │
  ▼
Apply
```

Avoid unnecessary manual changes in the AWS Console to resources managed by Terraform, as this can introduce configuration drift.

---

## 🗂️ Related Files

| **File / Path** | **Description** |
|---|---|
| `terraform/main.tf` | Main Terraform configuration |
| `terraform/providers.tf` | AWS provider configuration |
| `terraform/versions.tf` | Terraform/provider requirements |
| `terraform/variables.tf` | Input variables |
| `terraform/terraform.tfvars` | Environment-specific values |
| `terraform/outputs.tf` | Infrastructure outputs |
| `terraform/modules/` | Reusable infrastructure modules |
| `ansible/` | Post-provisioning server configuration |

---

## 🔗 References

- [**Terraform Official Documentation**](https://developer.hashicorp.com/terraform/docs)
- [**Terraform AWS Provider**](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [**AWS CLI & IAM Setup**](../prerequisites/aws-cli-iam.md)
- [**Ansible Configuration Management**](./ansible.md)

---

## 🧠 Documentation Scope

This document focuses on **how Terraform is used in this platform**, rather than serving as a general Terraform tutorial.

### ✅ Included

- AWS resources provisioned by Terraform
- Repository structure
- Important configuration files
- Terraform workflow
- AWS authentication
- State management
- Verification
- Security considerations
- Terraform → Ansible handoff
- Troubleshooting
- Related files

### ❌ Excluded

- Complete Terraform language reference
- Tutorials for every AWS resource
- Detailed explanation of every `.tf` block
- Generic Terraform examples unrelated to this platform

---

## 📋 Summary

Terraform provides the **AWS infrastructure layer** of this platform.

```text
Terraform
    │
    ▼
AWS Infrastructure
    │
    ├── Network
    ├── Security
    ├── EC2
    └── IAM
         │
         ▼
      Ansible
         │
         ▼
Docker + DevOps Tools + Kubernetes
```

The infrastructure is therefore reproducible, version-controlled, and separated into **provisioning (Terraform)** and **configuration (Ansible)**.
