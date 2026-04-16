variable "aws_region" {
  description = "AWS region for the Terraform state bucket."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name prefix."
  type        = string
  default     = "n8n-ollama"
}

variable "environment" {
  description = "Environment label."
  type        = string
  default     = "prod"
}
