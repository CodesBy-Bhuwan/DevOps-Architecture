variable "ami_id" { type = string }
variable "key_name" { type = string }
variable "public_subnet_id" { type = string }

variable "control_plane_sg_id" { type = string }
variable "k8s_sg_id" { type = string }
variable "monitoring_sg_id" { type = string }

variable "control_plane_instance_type" { type = string }
variable "k8s_master_instance_type" { type = string }
variable "k8s_worker_instance_type" { type = string }
variable "monitoring_instance_type" { type = string }

variable "k8s_worker_count" { type = number }

variable "control_plane_volume_size" { type = number }
variable "k8s_master_volume_size" { type = number }
variable "k8s_worker_volume_size" { type = number }
variable "monitoring_volume_size" { type = number }
