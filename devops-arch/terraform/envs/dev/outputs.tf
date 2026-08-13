output "control_plane_public_ip" {
  value = module.compute.control_plane_public_ip
}

output "k8s_master_public_ip" {
  value = module.compute.k8s_master_public_ip
}

output "k8s_workers_public_ips" {
  value = module.compute.k8s_workers_public_ips
}

output "monitoring_ops_public_ip" {
  value = module.compute.monitoring_ops_public_ip
}
