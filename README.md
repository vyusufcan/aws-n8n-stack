# n8n on AWS with Terraform

This repository provisions:

- An S3 bucket for Terraform remote state
- An Application Load Balancer in `eu-west-1`
- A `t2.micro` EC2 instance running `n8n` with Docker Compose
- Route53 DNS for `n8n.example.com`
- ACM-backed HTTPS on the load balancer
- Security groups that allow SSH only from your current public IP

## Layout

- `bootstrap/`: creates the S3 bucket used by Terraform state
- `infra/`: main AWS infrastructure and EC2 deployment

## Assumptions

- The hosted zone for `example.com` already exists in Route53
- The existing EC2 key pair is named `n8n-admin` and matches your local private key
- `n8n` will be publicly reachable through the ALB on HTTPS
- Application data is stored on the EC2 root volume, and the root volume is retained if the instance is destroyed

## Usage

1. Create the Terraform state bucket:

```powershell
cd bootstrap
$env:AWS_PROFILE = "n8n"
terraform init
terraform apply -auto-approve
```

2. Copy the bucket name from the output and create `infra/backend.hcl`:

```hcl
bucket = "your-terraform-state-bucket"
key    = "n8n-ollama/prod.tfstate"
region = "eu-west-1"
```

3. Create `infra/terraform.tfvars`:

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

4. Deploy the main stack:

```powershell
cd ../infra
$env:AWS_PROFILE = "n8n"
terraform init -backend-config=backend.hcl
terraform apply
```

## Notes

- SSH ingress is automatically restricted to your current public IP by resolving `https://checkip.amazonaws.com/` during `terraform apply`.
- The target group health check is configured for path `/healthz` on port `5678`.
- `n8n` listens on port `5678` inside the instance and the ALB forwards HTTPS traffic to it.
- Route53 creates an alias from `n8n.example.com` to the ALB automatically.
- The EC2 AMI is Ubuntu 24.04 LTS from Canonical.
