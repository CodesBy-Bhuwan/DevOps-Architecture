output "control_plane_sg_id" {
  value = aws_security_group.control_plane.id
}

output "k8s_sg_id" {
  value = aws_security_group.k8s.id
}

output "monitoring_sg_id" {
  value = aws_security_group.monitoring.id
}

output "docker_target_sg_id" {
  value = aws_security_group.docker_target.id
}
