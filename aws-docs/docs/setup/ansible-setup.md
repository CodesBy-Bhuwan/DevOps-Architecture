# Ansible — Configuration Management

## 📖 Overview

**Ansible** is used to automate server configuration and application setup across both **local Vagrant environments and AWS EC2 infrastructure**.

It allows the same infrastructure configuration to be reproduced without manually connecting to and configuring every server.

### What Ansible manages

* Base server configuration
* Docker installation and configuration
* Jenkins, SonarQube and Nexus
* Prometheus, Grafana, Loki, Promtail and Node Exporter
* Kubernetes prerequisites and node configuration
* Service configuration and integration

---

## 🏗️ Local & AWS Environments

The repository supports two environments:

```text
                    Ansible
                       │
             ┌─────────┴─────────┐
             │                   │
        Local Vagrant          AWS EC2
             │                   │
       local.ini             aws.ini
             │                   │
       Vagrant VMs          EC2 Servers
```

The **same roles and automation logic** can be reused across both environments, while the inventory defines which servers Ansible connects to.

---

## 📁 Directory Structure

```text
ansible/
├── ansible.cfg
├── inventory/
│   ├── local.ini
│   └── aws.ini
│
├── playbooks/
│   ├── site.yml
│   ├── docker.yml
│   ├── jenkins.yml
│   ├── sonarqube.yml
│   ├── nexus.yml
│   ├── monitoring.yml
│   └── kubernetes.yml
│
└── roles/
    ├── docker/
    ├── jenkins/
    ├── sonarqube/
    ├── nexus/
    ├── prometheus/
    ├── grafana/
    ├── loki/
    ├── promtail/
    ├── node_exporter/
    └── kubernetes/
```

### Important Files & Directories

| Path                  | Purpose                                  |
| --------------------- | ---------------------------------------- |
| `ansible.cfg`         | Global Ansible configuration             |
| `inventory/local.ini` | Local Vagrant servers                    |
| `inventory/aws.ini`   | AWS EC2 servers                          |
| `playbooks/`          | Main automation entry points             |
| `roles/`              | Reusable configuration components        |
| `site.yml`            | Main playbook for overall infrastructure |
| `group_vars/`         | Environment/group-specific variables     |
| `templates/`          | Dynamic configuration files              |
| `files/`              | Static files copied to servers           |

> Individual playbooks and roles are intentionally kept modular. You normally only need to understand the inventory, main playbooks, and relevant role when modifying the infrastructure.

---

## 🔐 Inventory

The inventory defines **where Ansible connects and how servers are grouped**.

Example:

```ini
[control]
control-plane ansible_host=<IP>

[monitoring]
monitoring ansible_host=<IP>

[kubernetes_master]
k8s-master ansible_host=<IP>

[kubernetes_workers]
k8s-worker-1 ansible_host=<IP>
k8s-worker-2 ansible_host=<IP>
```

The local inventory follows the same concept but points to the Vagrant machines.

---

## ⚙️ Configuration

`ansible.cfg` defines common Ansible behavior such as:

* Inventory location
* Remote user
* SSH configuration
* Host key checking
* Roles path

Environment-specific details such as server IPs and credentials should remain in the appropriate inventory/variable configuration rather than being hard-coded into playbooks.

---

## ▶️ Running Ansible

### Local Vagrant

```bash
ansible-playbook -i inventory/local.ini playbooks/site.yml
```

### AWS

```bash
ansible-playbook -i inventory/aws.ini playbooks/site.yml
```

### Test connectivity

```bash
ansible -i inventory/aws.ini all -m ping
```

Expected:

```text
server-name | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Run a specific component

```bash
ansible-playbook \
  -i inventory/aws.ini \
  playbooks/monitoring.yml
```

---

## 🔄 Automation Flow

```text
Inventory
    │
    ▼
Playbook
    │
    ▼
Role
    │
    ▼
Tasks / Templates / Files
    │
    ▼
Managed Server
```

For example:

```text
aws.ini
   │
   ▼
site.yml
   │
   ▼
docker role
   │
   ▼
AWS EC2 Server
   │
   ▼
Docker configured
```

---

## 🧩 Why Ansible?

Using Ansible provides:

* **Repeatability** — rebuild environments using the same automation.
* **Consistency** — apply the same configuration across servers.
* **Environment flexibility** — use the same automation for Vagrant and AWS.
* **Modularity** — roles separate each infrastructure component.
* **Scalability** — configure additional servers without repeating manual steps.

---

## 📚 Documentation

* [Ansible Official Documentation](https://docs.ansible.com/)

## Installation

### 1. Update packages

```bash
sudo apt update
```

### 2. Install Ansible

```bash
sudo apt install -y ansible
```

### 3. Verify

```bash
ansible --version
```

### 4. Test Ansible

```bash
ansible localhost -m ping
```

Expected:

```text
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

**Official Docs:** [Ansible Installation](https://docs.ansible.com/projects/ansible/latest/installation_guide/)
