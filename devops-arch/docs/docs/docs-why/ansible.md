# Ansible

## Description
Ansible is an open-source software provisioning, configuration management, and application-deployment tool. It uses human-readable YAML files to define automation tasks.

## Why We Chose It
- **Agentless:** Ansible communicates over standard SSH. We don't need to install heavy agents on our target EC2 instances, reducing attack surface and maintenance.
- **Idempotency:** If a playbook is run multiple times, it only makes changes if the system is not already in the desired state.
- **Ecosystem:** Ansible Galaxy and built-in modules (like `uri` and `docker_container`) make interacting with complex APIs incredibly easy.

## How We Used It
### Role-Based Architecture
We organized configurations into standard Ansible roles (`jenkins`, `nexus`, `prometheus`), separating tasks, variables, and templates.

### REST API Automation
We used Ansible's `uri` module to bypass manual UI configuration. We automatically hit the SonarQube and Nexus REST APIs to create users, service accounts, and Docker repositories.

### Jinja2 Templating
We used the `template` module to dynamically inject AWS Private IPs into `prometheus.yml` and dynamically inject Nexus passwords into Jenkins JCasC files.

## Why It Is Better Than Other Tools
- **vs. Chef/Puppet:** Chef and Puppet require a master server and client agents installed on every node. Ansible's push-based, agentless SSH model is much simpler to set up and debug.
- **vs. Bash Scripting:** Bash scripts are procedural and hard to maintain across different OS versions. Ansible abstracts the underlying OS commands into readable, idempotent modules.


[**Back to Previous Page**](../../../README.md)