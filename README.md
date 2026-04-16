# n8n + Ollama on AWS with Terraform

This repository provisions:

- An S3 bucket for Terraform remote state
- An Application Load Balancer in `eu-west-1`
- A `t2.large` EC2 instance running `n8n` and `ollama` with Docker Compose
- Route53 DNS for `n8n.vyusufcan.cloud`
- ACM-backed HTTPS on the load balancer
- Security groups that allow SSH only from your current public IP

## Layout

- `bootstrap/`: creates the S3 bucket used by Terraform state
- `infra/`: main AWS infrastructure and EC2 deployment

## Assumptions

- The hosted zone for `vyusufcan.cloud` already exists in Route53
- The existing EC2 key pair is named `vyusufcan` and matches `vyusufcan.pem`
- `n8n` will be publicly reachable through the ALB on HTTPS
- `ollama` will stay private on the EC2 host and be reachable from `n8n` at `http://ollama:11434`
- Application data is stored on the EC2 instance volume; only Terraform state is stored in S3

## Usage

1. Create the Terraform state bucket:

```powershell
cd bootstrap
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
project_name        = "n8n-ollama"
domain_name         = "n8n.vyusufcan.cloud"
hosted_zone_name    = "vyusufcan.cloud"
certificate_arn     = "arn:aws:acm:eu-west-1:948453117899:certificate/1508e766-5889-4a83-95d1-172617acdb65"
key_pair_name       = "vyusufcan"
n8n_encryption_key  = "replace-with-a-long-random-string"
ollama_model        = "llama3.2"
```

4. Deploy the main stack:

```powershell
cd ../infra
terraform init -backend-config=backend.hcl
terraform apply
```

## Notes

- SSH ingress is automatically restricted to your current public IP by resolving `https://checkip.amazonaws.com/` during `terraform apply`.
- The target group health check is configured for path `/healthz` on port `5678`.
- `n8n` listens on port `5678` inside the instance and the ALB forwards HTTPS traffic to it.
- The EC2 AMI is Ubuntu 24.04 LTS from Canonical.
