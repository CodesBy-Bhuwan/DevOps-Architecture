## AWS-CLI 

### 1. Update packages

```bash
sudo apt update
```

### 2. Install AWS CLI

```bash
sudo apt install -y awscli
```

### 3. Verify installation

```bash
aws --version
```
# AWS IAM & AWS CLI Authentication

This guide explains how to create an IAM user, generate AWS access keys, connect the user to the AWS CLI, and verify AWS access.

## 1. Create an IAM User

Login to the **AWS Management Console**.

Go to:

**IAM → Users → Create user**

Enter a username, for example:

```text
devops-admin
```

Continue to **Permissions**.

### Grant Permissions

For a personal lab, you can attach:

```text
AdministratorAccess
```

> For production environments, use a custom least-privilege policy instead of `AdministratorAccess`.

Create the user.

---

## 2. Create Access Keys

Open:

**IAM → Users → devops-admin → Security credentials**

Find:

**Access keys → Create access key**

Select the use case appropriate for your environment and create the access key.

You will receive:

```text
Access Key ID
Secret Access Key
```

> ⚠️ **Important:** The Secret Access Key is sensitive. Save it securely. Do not commit it to GitHub or place it inside Terraform/Ansible files.

AWS recommends creating only the credentials required for the user's actual use case.

---

## 3. Configure AWS CLI

On your local machine:

```bash
aws configure
```

Enter your IAM credentials:

```text
AWS Access Key ID: <YOUR_ACCESS_KEY>
AWS Secret Access Key: <YOUR_SECRET_KEY>
Default region name: eu-north-1
Default output format: json
```

AWS CLI stores these settings in the user's AWS configuration and credentials files.

---

## 4. Verify AWS CLI Authentication

Run:

```bash
aws sts get-caller-identity
```

Successful authentication returns information similar to:

```json
{
    "UserId": "...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/devops-admin"
}
```

You are now connected:

```text
Local Machine
     │
     │ AWS CLI
     ▼
IAM User
     │
     │ Permissions
     ▼
AWS Account
```

---

## 5. Test AWS Access

Check your AWS region:

```bash
aws configure get region
```

List EC2 instances:

```bash
aws ec2 describe-instances
```

Check your VPCs:

```bash
aws ec2 describe-vpcs
```

If these commands return AWS resources, the AWS CLI is successfully authenticated and authorized.

---

## 6. Check Current AWS Identity

At any time, verify which IAM identity the CLI is using:

```bash
aws sts get-caller-identity
```

This is especially useful when working with multiple AWS profiles.

---

## 7. Optional: Use a Named AWS Profile

For multiple AWS accounts/users, create a separate profile:

```bash
aws configure --profile devops
```

Then use it with:

```bash
aws sts get-caller-identity --profile devops
```

You can also make it the default profile for the current shell:

```bash
export AWS_PROFILE=devops
```

---

## 🔐 Security Rules

* Never commit AWS access keys to GitHub.
* Never put credentials directly inside Terraform files.
* Never put credentials directly inside Ansible playbooks.
* Do not share your Secret Access Key.
* Use least-privilege permissions whenever possible.
* Delete unused access keys.
* For production workloads, prefer temporary credentials, IAM roles, or IAM Identity Center.

---

## Official Documentation

* [**AWS IAM – Create an IAM User →**](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
* [**AWS CLI – Configure Credentials →**](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)
* [**AWS CLI – IAM User Credentials →**](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html)




### 4. Configure AWS credentials

```bash
aws configure
```

Provide:

```text
AWS Access Key ID
AWS Secret Access Key
Default region: eu-north-1
Output format: json
```

### 5. Test connection

```bash
aws sts get-caller-identity
```

> **Security:** Never commit AWS credentials to the repository.

**Official Docs:** [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/)


