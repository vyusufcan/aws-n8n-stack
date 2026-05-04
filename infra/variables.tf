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

variable "domain_name" {
  description = "Full domain name for n8n."
  type        = string
  default     = "n8n.example.com"
}

variable "hosted_zone_name" {
  description = "Existing Route53 hosted zone name."
  type        = string
  default     = "example.com"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the load balancer HTTPS listener."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "k8s_instance_type" {
  description = "EC2 instance type for the Kubernetes VM."
  type        = string
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "Existing AWS EC2 key pair name for SSH access."
  type        = string
  default     = "n8n-admin"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB."
  type        = number
  default     = 25
}

variable "data_device_name" {
  description = "Device name used to attach the persistent n8n data volume."
  type        = string
  default     = "/dev/sdf"
}

variable "data_volume_id" {
  description = "Persistent EBS volume ID used for n8n data."
  type        = string
}

variable "data_mount_path" {
  description = "Host path where the persistent n8n EBS volume is mounted."
  type        = string
  default     = "/srv/n8n"
}

variable "k3s_kubeconfig_relative_path" {
  description = "Relative path under the n8n data mount where the k3s kubeconfig is copied."
  type        = string
  default     = "k3s/kubeconfig.yaml"
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
