output "control_plane_public_ip" {
  value = aws_instance.control_plane.public_ip
}

output "k8s_master_public_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "k8s_workers_public_ips" {
  value = aws_instance.k8s_workers[*].public_ip
}

output "monitoring_ops_public_ip" {
  value = aws_instance.monitoring_ops.public_ip
}

##### we might use private_ip
output "control_plane_private_ip" {
  value = aws_instance.control_plane.private_ip
}

output "monitoring_ops_private_ip" {
  value = aws_instance.monitoring_ops.private_ip
}

output "k8s_master_private_ip" {
  value = aws_instance.k8s_master.private_ip
}

output "k8s_workers_private_ips" {
  value = aws_instance.k8s_workers[*].private_ip
}
