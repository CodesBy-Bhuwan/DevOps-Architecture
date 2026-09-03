# Jenkins

## Description
Jenkins is the leading open-source automation server used to build, test, and deploy software. It acts as the central orchestrator for Continuous Integration (CI) and Continuous Deployment (CD) pipelines.

## Why We Chose It
- **Extensibility:** With over 1,800 plugins, Jenkins integrates with almost every tool in the DevOps ecosystem.
- **Enterprise Standard:** It is battle-tested and widely used across the industry, making it a reliable choice for complex pipelines.
- **Pipeline as Code:** Using `Jenkinsfile` (Groovy-based DSL), we can version control our entire deployment pipeline alongside the application code.

## How We Used It
### Containerized Deployment
Deployed as a Docker container (`jenkins/jenkins:lts-jdk21`) on the Control Plane EC2 instance, ensuring a consistent and isolated runtime environment.

### Configuration as Code (JCasC)
We completely bypassed the manual setup wizard. Using the JCasC plugin and a Jinja2 template (`jenkins.yml.j2`), Ansible automatically injected admin credentials, SonarQube server URLs, and Nexus service account credentials into Jenkins upon boot.

### Role-Based Access Control (RBAC)
We automated the creation of multiple users (`admin`, `dev`, `tester`, `jrdevops`) with strict matrix permissions. For example, `jrdevops` can configure jobs but cannot delete them, enforcing the **Principle of Least Privilege**.

### Pipeline Integration
Jenkins uses the `nexus-creds` credential to log into the Nexus Docker registry, build MERN stack Docker images, and push them securely.

## Why It Is Better Than Other Tools
- **vs. GitLab CI/GitHub Actions:** While those are excellent SaaS-first tools, Jenkins offers unmatched on-premises/VPC control. It doesn't lock you into a specific cloud provider's ecosystem and allows for deep, custom plugin integrations that SaaS platforms restrict.
- **vs. Bamboo/TeamCity:** Jenkins is 100% free and open-source, with a community far larger than any competitor, meaning solutions to any problem are readily available.