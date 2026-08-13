# THE FOUNDATION (Core Infrastructure)

# Aws Cli

## Installation

**- AWS**
```bash
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    # Verify installation
    aws --version

    # Mac with Homebrew
    brew install awscli
```

**Aws Configuration** 

``` bash
# Interactive configuration
aws configure

# You'll be prompted for:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format (json, yaml, text, table)

# Or set environment variables
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-east-1
export AWS_DEFAULT_OUTPUT=json
```


**- Azure**
```bash
    # Linux
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

    # Mac
    brew install azure-cli

    # Verify installation
    az --version
```

**Azure Configuration**
```bash
# Login interactively
az login

# For headless/automated login (Service Principal)
az ad sp create-for-rbac --name "cloud-automation" \
    --role Contributor \
    --scopes /subscriptions/YOUR_SUBSCRIPTION_ID

# Set environment variables
export AZURE_SUBSCRIPTION_ID=your-subscription-id
export AZURE_TENANT_ID=your-tenant-id
export AZURE_CLIENT_ID=your-client-id
export AZURE_CLIENT_SECRET=your-client-secret
```


**- GCP**
```bash
    # Mac
    brew install google-cloud-sdk

    # Linux
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
    gcloud init

    # Verify installation
    gcloud version
```

**Gcp Configuration**
```bash
# Login
gcloud auth login

# Set project
gcloud config set project YOUR_PROJECT_ID

# Create service account
gcloud iam service-accounts create cloud-automation \
    --display-name "Cloud Automation Service Account"

# Download credentials
gcloud iam service-accounts keys create ~/credentials.json \
    --iam-account cloud-automation@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS=~/credentials.json
```


### How to get aws-access keys

**1. Amazon Web Services (AWS)**

For AWS, access keys are tied to an IAM User (not your root account, for security reasons) .

- Sign in to the AWS Console as an IAM user with permissions to create access keys .

- Navigate to IAM (Identity and Access Management) > Users .

- Select your username.

- Go to the Security credentials tab.

- Scroll to Access keys and click Create access key .

- Select the use case (e.g., "Command Line Interface (CLI)") and click Next .

Important: Click Download .csv file to save your Access Key ID and Secret Access Key immediately. This is the only time you can see the secret key .


**2. Microsoft Azure**
Azure uses Service Principals as identities for automated tools, which is the recommended approach over using a user account .

Using the Azure CLI, we can create one with a single command:

```bash
az ad sp create-for-rbac --name "my-service-principal-name" \
                         --role contributor \
                         --scopes /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP
```
- --role and --scopes are best practices that limit the principal's permissions to what is strictly necessary .

- The command will output an appId (your username), password (your secret), and tenant. Save this information immediately, as the password won't be shown again .

**3. Google Cloud Platform (GCP)**
For GCP, you create and download a Service Account Key file, which is a JSON file containing your credentials .

- In the GCP Console, go to IAM & Admin > Service Accounts .

- Select or create a service account.

- Go to the Keys tab.

- Click ADD KEY > Create new key .

- Choose JSON as the key type and click CREATE .

- The JSON key file will download to your computer. Store this file securely, as it contains your private key and can't be downloaded again . You will then use this file to authenticate tools like the gcloud CLI .

# AWS Cloud
What it is: The entire construction site and all the tools
Real-world analogy: A massive real estate development where you can rent any size space
Why we need it: Instead of buying your own servers (like buying land and building from scratch), you rent exactly what you need, when you need it

## IAM (Identity and Access Management)
What it is: The security guard and key management system
Real-world analogy: Building security with ID badges, locks, and access levels
Why we need it:

- You don't want the janitor (developer) accessing the vault (production database)

- You want to know who entered and when (audit logging)

- You need to give temporary access to contractors (temporary credentials)

### How to create IAM user





### VPC (Virtual Private Cloud)
What is it? A logically isolated section of the AWS cloud where you can launch resources in a virtual network you define.
Why we need it: You don't want your private databases sitting on the public internet. VPC lets you create public streets (for your website) and private, walled-off streets (for your databases).
Building Block: The Zoning Laws, Fences, and Private Roads of your city.
🏭 2. The Engines: Compute Services
The factories and workers that actually do the computing.

EC2 (Elastic Compute Cloud)
What is it? Virtual servers you can rent in the cloud. You choose the OS (Linux/Windows), CPU, and RAM.
Why we need it: To run applications that require a traditional server. If you need to host a complex video game server or a heavy enterprise app, EC2 gives you a computer that lives in the cloud.
Building Block: The Factories and Machines doing the heavy lifting.
AWS Lambda
What is it? A "serverless" compute service that runs your code in response to events, automatically managing the underlying servers.
Why we need it: You don't always need a server running 24/7. If you just need code to run every time a user uploads a photo (e.g., to resize it), Lambda wakes up, does the job, and goes back to sleep. You only pay for the milliseconds it runs.
Building Block: The Temp Workers who show up, do a specific job, and leave.
Elastic Beanstalk
What is it? A Platform-as-a-Service (PaaS) that automatically handles capacity provisioning, load balancing, and deployments.
Why we need it: Developers just want to write code, not configure servers and networks. Beanstalk lets you upload your code, and AWS figures out the rest.
Building Block: The Pre-fabricated House. You bring the furniture (code), and the foundation, plumbing, and electricity are already done.
📦 3. The Storage: Where Data Lives
The warehouses, filing cabinets, and vaults.

S3 (Simple Storage Service)
What is it? Object storage built to store and retrieve any amount of data from anywhere on the web.
Why we need it: It's infinitely scalable, incredibly cheap, and perfect for storing files like images, videos, backups, and website assets.
Building Block: The Massive Warehouse where you put things in boxes (objects) and put them on shelves.
EBS (Elastic Block Store)
What is it? Virtual hard drives that you attach to your EC2 virtual servers.
Why we need it: EC2 instances are temporary; if they reboot, data in their memory is lost. EBS provides permanent storage for things like an operating system or a database that needs fast, continuous read/write access.
Building Block: The Physical Hard Drive plugged directly into your factory machine.
EFS (Elastic File System)
What is it? A scalable, shared file storage system for multiple EC2 instances.
Why we need it: Sometimes, multiple servers need to read and write to the exact same files at the same time. EBS can only attach to one server; EFS can attach to hundreds simultaneously.
Building Block: The Shared Filing Cabinet that all workers in the factory can access at once.
S3 Glacier
What is it? A low-cost cloud storage service for data archiving and long-term backup.
Why we need it: You are legally required to keep tax records for 7 years, but you never look at them. Storing them in S3 is too expensive. Glacier stores them safely for fractions of a penny, though it takes a few hours to "thaw" the data when you need it.
Building Block: The Deep Underground Vault for things you rarely need.
🗄️ 4. The Databases: Structured Information
The organized filing systems.

Amazon RDS (Relational Database Service)
What is it? A managed service for traditional SQL databases (MySQL, PostgreSQL, SQL Server, etc.).
Why we need it: Running a database requires patching, backups, and updates. RDS automates all the boring administrative work so you can just focus on the data structure.
Building Block: The Organized Filing Cabinet (alphabetical, strict rules).
Amazon Aurora
What is it? AWS's proprietary, high-performance relational database compatible with MySQL and PostgreSQL.
Why we need it: It is up to five times faster than standard MySQL and features automatic replication across multiple locations for extreme reliability.
Building Block: The High-Speed, Luxury Filing Cabinet.
Amazon DynamoDB
What is it? A fast, flexible NoSQL database service for single-digit millisecond performance at any scale.
Why we need it: Traditional SQL databases struggle when millions of users log in at the exact same second. DynamoDB handles massive, unpredictable traffic for things like gaming leaderboards or shopping carts effortlessly.
Building Block: The Flexible Shelving Unit (no strict rules, you can throw items in and pull them out lightning fast).
Amazon Redshift
What is it? A fast, fully managed data warehouse for analyzing petabytes of data.
Why we need it: RDS and DynamoDB are for running your app day-to-day (transactional data). Redshift is for Big Data—analyzing years of sales data to find business trends.
Building Block: The City Analytics Headquarters crunching numbers for the mayor.
🚦 5. The Operations: Traffic & Maintenance
The traffic cops, power grid, and security cameras.

ELB (Elastic Load Balancing)
What is it? A service that automatically distributes incoming application traffic across multiple targets (like EC2 instances).
Why we need it: If your website goes viral, one server will crash. ELB acts as a traffic cop, sending User A to Server 1 and User B to Server 2, ensuring no single server gets overwhelmed.
Building Block: The Traffic Cop directing cars to open lanes at the toll booth.
Amazon CloudWatch
What is it? A monitoring and observability service that collects logs, metrics, and events.
Why we need it: You need to know if your server's CPU is at 99% or if your database is about to run out of space. CloudWatch watches everything and can send you an SMS or email if something looks wrong.
Building Block: The Security Cameras and Dashboard Gauges of the city.

Auto Scaling
What is it? A service that automatically monitors and adjusts compute resources based on demand.
Why we need it: To save money and prevent crashes. If it's Black Friday and traffic spikes, Auto Scaling launches 10 new servers automatically. When the weekend hits and traffic drops, it deletes 8 of them so you stop paying for them.
Building Block: The Magic Workforce that expands and shrinks based on how busy the city is.