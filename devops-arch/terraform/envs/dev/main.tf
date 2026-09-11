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

  # Existing variables 
  docker_target_instance_type = var.docker_target_instance_type
  docker_target_volume_size   = var.docker_target_volume_size
  docker_target_sg_id         = module.security.docker_target_sg_id

  # ... existing  variables ...
  enable_kubernetes          = var.enable_kubernetes
  enable_docker_target       = var.enable_docker_target
}
####################################################
# Automatically generate ansible/inventory/aws.ini
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../../../ansible/inventory/aws.ini"
  
  content = <<-EOF
# --- DevOps Tools ---
[jenkins]
control-node ansible_host=${module.compute.control_plane_public_ip} private_ip=${module.compute.control_plane_private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem

[sonarqube]
control-node ansible_host=${module.compute.control_plane_public_ip} private_ip=${module.compute.control_plane_private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem

[nexus]
monitoring-node ansible_host=${module.compute.monitoring_ops_public_ip} private_ip=${module.compute.monitoring_ops_private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem

[prometheus]
monitoring-node ansible_host=${module.compute.monitoring_ops_public_ip} private_ip=${module.compute.monitoring_ops_private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem

[grafana]
monitoring-node ansible_host=${module.compute.monitoring_ops_public_ip} private_ip=${module.compute.monitoring_ops_private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem

[k8s_master]
%{ if var.enable_kubernetes }
 ${module.compute.k8s_master_public_ip} private_ip=${module.compute.k8s_master_private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem
%{ endif }

[k8s_workers]
%{ if var.enable_kubernetes }
%{ for i, ip in module.compute.k8s_workers_public_ips ~}
 ${ip} private_ip=${module.compute.k8s_workers_private_ips[i]} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem
%{ endfor ~}
%{ endif }

[docker_target]
%{ if var.enable_docker_target }
 ${module.compute.docker_target_public_ip} private_ip=${module.compute.docker_target_private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}/devops-aws-key.pem
%{ endif }
  EOF
}

