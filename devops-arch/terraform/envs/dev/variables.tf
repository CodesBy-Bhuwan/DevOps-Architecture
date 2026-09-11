variable "aws_region" {
  type    = string
}

variable "availability_zone" {
  type    = string
}

variable "environment" {
  type    = string
}

variable "vpc_cidr" {
  type    = string
}

variable "public_subnet_cidr" {
  type    = string
}

variable "key_name" {
  type    = string
}

variable "enable_kubernetes" {
  type    = bool
}

variable "enable_docker_target" {
  type    = bool
}
# Instance Types
variable "control_plane_instance_type" { type = string }
variable "k8s_master_instance_type"    { type = string }
variable "k8s_worker_instance_type"    { type = string }
variable "monitoring_instance_type"    { type = string }
variable "docker_target_instance_type" { type = string }

# Worker Count
variable "k8s_worker_count" { type = number }

# Volume Sizes
variable "control_plane_volume_size" { type = number }
variable "k8s_master_volume_size"    { type = number }
variable "k8s_worker_volume_size"    { type = number }
variable "monitoring_volume_size"    { type = number }
variable "docker_target_volume_size" { type = number }

