# Nexus Repository (OSS)

## Description
Sonatype Nexus Repository OSS is an open-source repository manager that allows you to proxy, collect, and manage your dependencies and artifacts. It acts as a central hub for Docker images, npm packages, and Maven artifacts.

## Why We Chose It
- **Single Source of Truth:** It provides a single, private, centralized location to store built Docker images, ensuring developers and servers pull from a trusted, internal source.
- **Format Support:** It natively supports Docker, npm, PyPI, and Maven, making it highly versatile for polyglot microservice architectures.
- **VPC Security:** By hosting the registry privately inside AWS, we avoid exposing our internal application images to the public internet (like Docker Hub).

## How We Used It
### Stable Deployment
Deployed via Docker (`sonatype/nexus3:3.79.0`) on the Monitoring/Ops server with a 50GB EBS volume to handle large Docker image storage.

### Automated Password Management
We bypassed the fragile random UUID password generation by booting Nexus with `-e "NEXUS_SECURITY_RANDOM_PASSWORD=false"`, forcing a stable `admin123` password that Ansible could reliably use for API calls.

### API Automation
We used Ansible to call the Nexus REST API to automatically create the `docker-hosted` repository (listening on port `8082`) and provision a `jenkins-ci` Service Account.

### Docker Daemon Configuration
We configured the Jenkins EC2 instance's Docker daemon (`/etc/docker/daemon.json`) to recognize the Nexus HTTP registry as an `insecure-registry`, allowing seamless `docker login` and `docker push` operations.

## Why It Is Better Than Other Tools
- **vs. Docker Hub / ECR:** Nexus is format-agnostic. ECR only handles Docker images, but Nexus can also serve as a private npm registry for the React frontend or a Maven repo for Java.
- **vs. JFrog Artifactory:** Artifactory is excellent but highly expensive and resource-heavy. Nexus OSS provides 90% of the functionality for free, with a much smaller memory footprint, making it ideal for a mid-sized EC2 instance.


[**Back to Previous Page**](../../../README.md)