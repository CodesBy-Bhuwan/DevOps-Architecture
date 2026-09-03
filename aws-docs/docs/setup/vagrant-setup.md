# Vagrant Environment Setup

## 📖 Description

**Vagrant** is used to create and manage reproducible local virtual machines. In this project, it provides a local environment for testing infrastructure, server configuration, Docker, Kubernetes, and Ansible automation before moving workloads to AWS.

The Vagrant environment consists of multiple Ubuntu virtual machines that simulate a distributed infrastructure.

### Environment

| Server    | Role                     |
| --------- | ------------------------ |
| `master`  | Kubernetes Control Plane |
| `worker1` | Kubernetes Worker        |
| `worker2` | Kubernetes Worker        |

Vagrant uses **VirtualBox** as the virtualization provider.

---

## Installation

Vagrant requires a virtualization provider such as VirtualBox.

### 1. Install VirtualBox

```bash
sudo apt update
sudo apt install -y virtualbox
```

Verify:

```bash
VBoxManage --version
```

### 2. Install Vagrant

Download the latest `.deb` package from:

[**Vagrant Downloads**](https://developer.hashicorp.com/vagrant/install)

Install it:

```bash
sudo apt install ./vagrant_<version>_amd64.deb
```

### 3. Verify

```bash
vagrant --version
```

### 4. Create a Vagrant environment

```bash
mkdir vagrant-lab
cd vagrant-lab
vagrant init ubuntu/jammy64
```

### 5. Start the VM

```bash
vagrant up
```

### 6. Connect

```bash
vagrant ssh

OR 

vagrant ssh master
```

**Official Docs:** [Vagrant Documentation](https://developer.hashicorp.com/vagrant/docs)
