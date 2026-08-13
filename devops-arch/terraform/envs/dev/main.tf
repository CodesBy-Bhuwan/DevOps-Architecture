module "networking" {
  source = "../../modules/networking"
  
  # Pass network variables
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  availability_zone   = var.availability_zone
  environment         = var.environment
}

module "security" {
  source = "../../modules/security"
  vpc_id = module.networking.vpc_id
  environment = var.environment
}
module "compute" {
  source = "../../modules/compute"
  
  ami_id           = data.aws_ami.ubuntu.id
  key_name         = aws_key_pair.dev_key.key_name
  public_subnet_id = module.networking.public_subnet_id
  
  # Security Groups
  control_plane_sg_id = module.security.control_plane_sg_id
  k8s_sg_id           = module.security.k8s_sg_id
  monitoring_sg_id    = module.security.monitoring_sg_id
  
  # Instance Types
  control_plane_instance_type = var.control_plane_instance_type
  k8s_master_instance_type    = var.k8s_master_instance_type
  k8s_worker_instance_type    = var.k8s_worker_instance_type
  monitoring_instance_type    = var.monitoring_instance_type
  
  # Worker Count
  k8s_worker_count = var.k8s_worker_count
  
  # Volume Sizes
  control_plane_volume_size = var.control_plane_volume_size
  k8s_master_volume_size    = var.k8s_master_volume_size
  k8s_worker_volume_size    = var.k8s_worker_volume_size
  monitoring_volume_size    = var.monitoring_volume_size
}
####################################################
# Automatically generate ansible/inventory/aws.ini
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../../../ansible/inventory/aws.ini"
  
  content = <<-EOF
# --- DevOps Tools ---
[jenkins]
 ${module.compute.control_plane_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem

[sonarqube]
 ${module.compute.control_plane_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem

[nexus]
 ${module.compute.monitoring_ops_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem

[prometheus]
 ${module.compute.monitoring_ops_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem

[grafana]
 ${module.compute.monitoring_ops_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem

# --- Kubernetes ---
[k8s_master]
 ${module.compute.k8s_master_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem

[k8s_workers]
%{ for ip in module.compute.k8s_workers_public_ips ~}
 ${ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem
%{ endfor ~}
  EOF
}
