output "alb_dns_name" {
  description = "DNS name of the application load balancer."
  value       = aws_lb.this.dns_name
}

output "application_url" {
  description = "Public URL for n8n."
  value       = "https://${var.domain_name}"
}

output "ssh_allowed_cidr" {
  description = "CIDR automatically allowed to SSH."
  value       = local.ssh_ingress_cidr
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance."
  value       = aws_instance.app.public_ip
}

output "n8n_data_volume_id" {
  description = "Persistent EBS volume ID used for n8n data."
  value       = var.data_volume_id
}
