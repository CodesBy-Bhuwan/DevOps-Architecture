# AWS CLI — Cloud Management

## 📖 Overview

**AWS CLI (Command Line Interface)** is used to interact with AWS services directly from the terminal.

In this project, AWS CLI is primarily used for:

* AWS authentication and identity verification
* Managing EC2 instances
* Inspecting VPC and networking resources
* Managing IAM-related operations
* Supporting Terraform and Ansible workflows
* Troubleshooting and verifying AWS infrastructure

> **AWS CLI provides access to AWS; Terraform provisions infrastructure, while Ansible configures the servers.**

---



## 🏗️ AWS CLI in This Project

AWS CLI fits into the infrastructure workflow as follows:

```text
AWS IAM
   │
   │ Credentials / Identity
   ▼
AWS CLI
   │
   ├── EC2
   ├── VPC
   ├── IAM
   └── Security Groups
          │
          ▼
      Terraform
          │
          ▼
    AWS Infrastructure
          │
          ▼
       Ansible
```

---

## 🔐 AWS Authentication

AWS CLI uses an IAM identity to authenticate requests.

The recommended setup for this project is:

```text
AWS Account
    │
    ▼
IAM User
    │
    ▼
Access Key
    │
    ▼
AWS CLI
```

Configure the credentials with:

```bash
aws configure
```

Verify the authenticated identity:

```bash
aws sts get-caller-identity
```

> ⚠️ Never commit AWS access keys or secret keys to GitHub.

For the complete IAM setup, see:

[**AWS IAM & CLI Authentication →**](aws-cli-iam.md)

---

## ⚙️ Configuration

After running:

```bash
aws configure
```

AWS CLI stores configuration locally.

Common files:

```text
~/.aws/
├── config
└── credentials
```

The `config` file contains settings such as the default region, while `credentials` contains authentication credentials.

---

## 🌎 Default Region

This project uses:

```text
eu-north-1
```

Check the configured region:

```bash
aws configure get region
```

Change it if required:

```bash
aws configure set region eu-north-1
```

---

## 🧪 Useful Commands

### Check AWS identity

```bash
aws sts get-caller-identity
```

### List EC2 instances

```bash
aws ec2 describe-instances
```

### List VPCs

```bash
aws ec2 describe-vpcs
```

### List subnets

```bash
aws ec2 describe-subnets
```

### List Security Groups

```bash
aws ec2 describe-security-groups
```

### Check available EC2 instance types

```bash
aws ec2 describe-instance-types
```

These commands are useful for verifying resources created by Terraform.

---

## 👤 AWS Profiles

If multiple AWS accounts or IAM identities are required, named profiles can be used.

Create a profile:

```bash
aws configure --profile devops
```

Use the profile:

```bash
aws sts get-caller-identity --profile devops
```

Set it temporarily for the current shell:

```bash
export AWS_PROFILE=devops
```

---

## 🔄 AWS CLI & Infrastructure Workflow

The tools in this project have separate responsibilities:

```text
AWS CLI
   │
   │ Authentication & Verification
   ▼
Terraform
   │
   │ Provision
   ▼
AWS Infrastructure
   │
   │ Configure
   ▼
Ansible
   │
   ▼
DevOps Tools & Applications
```

This makes AWS CLI the **entry point for AWS authentication and command-line management**, rather than the primary infrastructure provisioning tool.

---

## 🔒 Security Guidelines

* Use IAM instead of the AWS root account for daily operations.
* Follow the **principle of least privilege**.
* Never commit `~/.aws/credentials` to Git.
* Never hard-code access keys in Terraform or Ansible.
* Rotate or remove unused access keys.
* Use temporary credentials or IAM roles where appropriate.
* Verify the active AWS identity before running destructive commands.

Before running infrastructure changes, check:

```bash
aws sts get-caller-identity
```

---

## 📚 Documentation

* [AWS CLI Installation](aws-cli-installation.md)
* [AWS IAM & CLI Authentication](aws-cli-iam.md)
* [AWS CLI Official Documentation](https://docs.aws.amazon.com/cli/latest/userguide/)
