output "ssh_allowed_cidr" {
  description = "CIDR automatically allowed to SSH."
  value       = local.ssh_ingress_cidr
}

output "k3s_public_ip" {
  description = "Public IP of the k3s EC2 instance."
  value       = aws_instance.k3s.public_ip
}

output "k3s_private_ip" {
  description = "Private IP of the k3s EC2 instance for VPC-internal access."
  value       = aws_instance.k3s.private_ip
}

output "kubeconfig_parameter_name" {
  description = "SSM parameter name storing the n8n kubeconfig."
  value       = local.kubeconfig_parameter
}

output "k3s_ready_parameter_name" {
  description = "SSM parameter name storing the ready private IP."
  value       = local.k3s_ready_parameter
}
