output "n8n_data_volume_id" {
  description = "Persistent EBS volume ID used for n8n data."
  value       = aws_ebs_volume.n8n_data.id
}

output "n8n_data_volume_availability_zone" {
  description = "Availability Zone of the persistent n8n EBS volume."
  value       = aws_ebs_volume.n8n_data.availability_zone
}
