# SonarQube

## Description
SonarQube is an open-source platform developed by SonarSource for continuous inspection of code quality and security. It performs automatic static code analysis to detect bugs, code smells, and security vulnerabilities.

## Why We Chose It
- **Shift-Left Security:** Integrating code scanning early in the CI/CD pipeline (before deployment) prevents vulnerabilities from reaching production.
- **Multi-Language Support:** Perfect for our MERN stack architecture, as it analyzes both JavaScript/TypeScript (frontend) and Node.js/Express (backend) seamlessly.
- **Quality Gates:** It can automatically fail a Jenkins pipeline if the code does not meet predefined quality standards (e.g., coverage < 80%).

## How We Used It
### Optimized Deployment
Deployed via Docker (`sonarqube:9.9-community`) on the Control Plane server alongside Jenkins. To prevent Out-Of-Memory (OOM) crashes common in Java apps, we strictly limited its heap size using `-e "SONAR_ES_JAVA_OPTS=-Xms512m -Xmx512m"`.

### Automated User Provisioning
Instead of manual UI configuration, we used Ansible's `uri` module to call the SonarQube REST API, automatically creating `dev` and `tester` accounts with standard `sonar-users` permissions.

### Jenkins Integration
Jenkins was configured (via JCasC) to recognize the SonarQube server. When a pipeline runs, Jenkins sends the code to SonarQube for scanning and waits for the Quality Gate result.

## Why It Is Better Than Other Tools
- **vs. SonarCloud:** SonarCloud requires sending source code to an external SaaS. SonarQube keeps all intellectual property and code analysis strictly inside our private AWS VPC, which is mandatory for enterprise compliance.
- **vs. ESLint/Checkstyle:** While linters are great for immediate feedback, they only run locally. SonarQube provides a centralized, historical dashboard of technical debt across the entire engineering organization, enforcing team-wide standards.



[**Back to Previous Page**](../../../README.md)