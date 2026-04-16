variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name prefix."
  type        = string
  default     = "n8n-ollama"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "Full domain name for n8n."
  type        = string
  default     = "n8n.vyusufcan.cloud"
}

variable "hosted_zone_name" {
  description = "Existing Route53 hosted zone name."
  type        = string
  default     = "vyusufcan.cloud"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the load balancer HTTPS listener."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.large"
}

variable "key_pair_name" {
  description = "Existing AWS EC2 key pair name for SSH access."
  type        = string
  default     = "vyusufcan"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB."
  type        = number
  default     = 80
}

variable "n8n_encryption_key" {
  description = "Encryption key for n8n credentials."
  type        = string
  sensitive   = true
}

variable "n8n_timezone" {
  description = "Timezone used by n8n."
  type        = string
  default     = "Europe/Lisbon"
}

variable "n8n_host_port" {
  description = "Port exposed by n8n on the EC2 instance."
  type        = number
  default     = 5678
}

variable "ollama_model" {
  description = "Model to pull on first boot."
  type        = string
  default     = "llama3.2"
}
