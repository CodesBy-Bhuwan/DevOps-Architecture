# --- Environment Configuration ---
aws_region        = "eu-north-1"
availability_zone = "eu-north-1a"
environment       = "dev"

# --- Network Configuration ---
vpc_cidr          = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"

# --- EC2 Configuration ---
# Auto key pair creation
# The exact name of the SSH key you created in the AWS Console
key_name = "devops-aws-key" 

# Instance sizes based on your architecture
control_plane_instance_type = "t3.large"
k8s_master_instance_type    = "t3.large"
k8s_worker_instance_type    = "t3.medium"
monitoring_instance_type    = "t3.medium"

# Number of workers
k8s_worker_count = 2

# Storage sizes (Fixes the Vagrant storage issue!)
control_plane_volume_size = 30  # For Jenkins & SonarQube
k8s_master_volume_size    = 20  # For etcd & K8s control plane
k8s_worker_volume_size    = 25  # For app workloads
monitoring_volume_size    = 50  # For Prometheus & Nexus
