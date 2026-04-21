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

variable "data_volume_size" {
  description = "Persistent EBS volume size in GB for n8n data."
  type        = number
  default     = 50
}
