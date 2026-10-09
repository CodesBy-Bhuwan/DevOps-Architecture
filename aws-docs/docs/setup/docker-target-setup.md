Docker Target Node (Deploy Node) Setup
This document outlines the infrastructure, security, and deployment configuration for the deploy-node (Docker Target). This server is designed to be a secure, production-ready environment for hosting Dockerized applications behind an Nginx Reverse Proxy.

1. Infrastructure Provisioning (Terraform)
Files: terraform/modules/compute/main.tf, terraform/modules/security/main.tf

Purpose: Provisions a dedicated t3.medium EC2 instance for Docker deployments and configures its AWS firewall.
What We Did:
Added an aws_instance resource named docker_target with a count toggle (var.enable_docker_target). This allows us to turn the server off to save money when not actively testing deployments.
Created a dedicated Security Group (docker_target_sg) that strictly allows SSH (22), HTTP (80), HTTPS (443), and internal VPC traffic for Node Exporter (9100). All other inbound traffic is denied by default.
2. Base Tooling Installation (Ansible)
Files: ansible/playbooks/docker.yml, ansible/playbooks/node_exporter.yml

Purpose: Installs the base runtime (Docker) and monitoring agents required for the observability stack.
What We Did:
Installed Docker Engine and Docker Compose on the deploy-node.
Deployed node_exporter as a Docker container using network_mode: host. This binds it directly to the EC2 instance's private IP, allowing Prometheus to scrape hardware metrics without exposing ports to the public internet.
3. Host Security & Hardening (Ansible)
File: ansible/roles/secure_host/tasks/main.yml

Purpose: Locks down the operating system to prevent unauthorized access and brute-force attacks.
What We Did:
Configured UFW (Uncomplicated Firewall) to enforce a strict allow-list policy (Deny all inbound, explicitly Allow 22, 80, 443).
Installed and enabled fail2ban to dynamically ban IPs that attempt brute-force SSH attacks.
Disabled SSH Password Authentication in sshd_config, enforcing SSH key-only access for the ubuntu user.
4. Nginx Reverse Proxy & Network Isolation (Ansible)
Files: ansible/roles/nginx_proxy/templates/nginx.conf.j2, ansible/roles/nginx_proxy/tasks/main.yml

Purpose: Establishes a secure traffic routing architecture where Nginx is the only public entry point, and backend applications are hidden on an isolated Docker network.
What We Did:
Created an internal Docker network (internal_net with internal: true). Containers attached to this network cannot be accessed directly from the internet.
Deployed a backend-app container attached only to internal_net. Noticeably, it has no published ports, making it invisible to the public.
Deployed an nginx-proxy container. We configured it to listen on ports 80/443 and route traffic to the backend-app via the internal network.
Key Detail: We attached the nginx-proxy to both the internal_net and the default bridge network. This bypasses Docker's rule that blocks port mapping on internal: true networks, allowing Nginx to receive external traffic while securely forwarding it internally.
Execution & Verification
Execution:
bash

make aws-up ENABLE_DOCKER=true
make docker ENV=aws
make node_exporter ENV=aws
make secure-host ENV=aws
make nginx-proxy ENV=aws
Verification:
Verify the firewall: ansible docker_target -i ansible/inventory/aws.ini -b -m shell -a "ufw status"
Verify the isolated network: ansible docker_target -i ansible/inventory/aws.ini -b -m shell -a "docker network inspect internal_net"
Verify the reverse proxy: Open a browser and go to http://<deploy-node-ip>. You should see the backend app's webpage, served securely through the Nginx proxy.
