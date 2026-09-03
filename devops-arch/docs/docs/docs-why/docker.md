# Docker

## Description
Docker is a platform that uses OS-level virtualization to deliver software in packages called containers. Containers are isolated from one another and bundle their own software, libraries, and configuration files.

## Why We Chose It
- **Environment Parity:** Docker guarantees that an application built on a developer's laptop runs exactly the same way on the AWS EC2 production server, eliminating the "it works on my machine" problem.
- **Microservices Architecture:** It allows us to isolate complex tools (Jenkins, Nexus, Prometheus) into self-contained units, preventing dependency conflicts.
- **Lightweight & Fast:** Unlike traditional Virtual Machines, containers share the host OS kernel, making them start in milliseconds and consume far fewer resources.

## How We Used It
### Base Runtime
Installed via Ansible on all 5 EC2 instances. It serves as the universal runtime for our entire DevOps platform.

### Insecure Registry Configuration
To allow Jenkins to push Docker images to our private Nexus registry over HTTP (port 8082), we configured the Docker daemon (`/etc/docker/daemon.json`) on the Jenkins server to recognize the Nexus IP as an `insecure-registry`.

### Multi-Stage Builds
Used Docker multi-stage builds for our MERN application, compiling the React frontend in one container and serving it via a lightweight Node.js container.

## Why It Is Better Than Other Tools
- **vs. Virtual Machines (Vagrant):** While Vagrant is great for simulating full OS environments, Docker containers are immutable, use a fraction of the disk space, and can be easily orchestrated at scale.
- **vs. Podman/Containerd:** Docker remains the industry standard with the most extensive ecosystem (Docker Compose, Docker Hub) and the most seamless integration with CI/CD tools like Jenkins.



[**Back to Previous Page**](../../../README.md)