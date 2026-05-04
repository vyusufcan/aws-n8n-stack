# n8n on AWS with Terraform

This repository provisions:

- An S3 bucket for Terraform remote state
- A dedicated `k3s/` stack for a standalone Kubernetes server
- An Application Load Balancer in `eu-west-1`
- A `t2.micro` EC2 instance running `n8n` with Docker Compose
- Route53 DNS for `n8n.example.com`
- ACM-backed HTTPS on the load balancer
- Security groups that allow SSH only from your current public IP

## Layout

- `bootstrap/`: creates the S3 bucket used by Terraform state
- `storage/`: persistent EBS volume for n8n data
- `k3s/`: standalone k3s server and SSM-published kubeconfig
- `infra/`: n8n app, ALB, DNS, and data-volume attachment

## Assumptions

- The hosted zone for `example.com` already exists in Route53
- The existing EC2 key pair is named `n8n-admin` and matches your local private key
- `n8n` will be publicly reachable through the ALB on HTTPS
- `storage/` has already created the persistent EBS volume consumed by `infra/`
- `k3s/` is applied before `infra/` so the kubeconfig exists in SSM Parameter Store

## Usage

1. Create the Terraform state bucket:

```powershell
cd bootstrap
$env:AWS_PROFILE = "n8n"
terraform init
terraform apply -auto-approve
```

2. Create one backend config per stack:

```hcl
bucket = "your-terraform-state-bucket"
key    = "n8n-ollama/prod.tfstate"
region = "eu-west-1"
```

For `k3s/backend.hcl`, use a separate key such as `n8n-ollama/k3s-prod.tfstate`.

3. Create `k3s/terraform.tfvars`:

```hcl
aws_profile       = "n8n"
project_name      = "n8n-ollama"
environment       = "prod"
key_pair_name     = "n8n-admin"
k3s_instance_type = "t3.medium"
```

4. Apply the k3s stack:

```powershell
cd k3s
$env:AWS_PROFILE = "n8n"
terraform init -backend-config=backend.hcl
terraform apply
```

5. Create `infra/terraform.tfvars`:

```hcl
aws_profile         = "n8n"
project_name        = "n8n-ollama"
domain_name         = "n8n.example.com"
hosted_zone_name    = "example.com"
certificate_arn     = "arn:aws:acm:eu-west-1:948453117899:certificate/1508e766-5889-4a83-95d1-172617acdb65"
instance_type       = "t2.micro"
key_pair_name       = "n8n-admin"
n8n_encryption_key  = "replace-with-a-long-random-string"
```

6. Deploy the main app stack:

```powershell
cd ../infra
$env:AWS_PROFILE = "n8n"
terraform init -backend-config=backend.hcl
terraform apply
```

## Notes

- SSH ingress is automatically restricted to your current public IP by resolving `https://checkip.amazonaws.com/` during `terraform apply`.
- The `k3s/` stack writes the kubeconfig and server private IP into SSM Parameter Store; `infra/` waits for those values during EC2 boot.
- The target group health check is configured for path `/healthz` on port `5678`.
- `n8n` listens on port `5678` inside the instance and the ALB forwards HTTPS traffic to it.
- Route53 creates an alias from `n8n.example.com` to the ALB automatically.
- The EC2 AMI is Ubuntu 24.04 LTS from Canonical.
