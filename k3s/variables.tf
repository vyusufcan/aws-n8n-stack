variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "AWS shared credentials profile used by Terraform."
  type        = string
  default     = "n8n"
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

variable "key_pair_name" {
  description = "Existing AWS EC2 key pair name for SSH access."
  type        = string
  default     = "n8n-admin"
}

variable "k3s_instance_type" {
  description = "EC2 instance type for the k3s server."
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB."
  type        = number
  default     = 25
}
