# 1. CONTROL PLANE
resource "aws_instance" "control_plane" {
  ami                    = var.ami_id
  instance_type          = var.control_plane_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.control_plane_sg_id]

  root_block_device {
    volume_size = var.control_plane_volume_size
    volume_type = "gp3"
  }
  tags = { Name = "dev-control-plane" }
}

# 2. K8s Master (Only builds if enable_kubernetes = true)
resource "aws_instance" "k8s_master" {
  count                  = var.enable_kubernetes ? 1 : 0
  ami                    = var.ami_id
  instance_type          = var.k8s_master_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.k8s_sg_id]
  root_block_device {
    volume_size = var.k8s_master_volume_size
    volume_type = "gp3"
  }
  tags = { Name = "dev-k8s-master" }
}

# 3. K8s Workers (Only builds if enable_kubernetes = true)
resource "aws_instance" "k8s_workers" {
  count                  = var.enable_kubernetes ? var.k8s_worker_count : 0
  ami                    = var.ami_id
  instance_type          = var.k8s_worker_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.k8s_sg_id]
  root_block_device {
    volume_size = var.k8s_worker_volume_size
    volume_type = "gp3"
  }
  tags = { Name = "dev-k8s-worker-${count.index + 1}" }
}

# 4. Docker Deployment Target (Only builds if enable_docker_target = true)
resource "aws_instance" "docker_target" {
  count                  = var.enable_docker_target ? 1 : 0
  ami                    = var.ami_id
  instance_type          = var.docker_target_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.docker_target_sg_id]
  root_block_device {
    volume_size = var.docker_target_volume_size
    volume_type = "gp3"
  }
  tags = { Name = "dev-docker-target" }
}

# 5. MONITORING & OPS
resource "aws_instance" "monitoring_ops" {
  ami                    = var.ami_id
  instance_type          = var.monitoring_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.monitoring_sg_id]

  root_block_device {
    volume_size = var.monitoring_volume_size
    volume_type = "gp3"
  }
  tags = { Name = "dev-monitoring-ops" }
}

