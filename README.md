# n8n Platform on AWS

Self-hosted [n8n](https://n8n.io) deployment on AWS, built with a split-stack Terraform model and extended with AI-driven Kubernetes automation workflows.

The infrastructure separates persistent storage, the k3s cluster, and the application layer into independent Terraform stacks so any layer can be rebuilt without touching the others.

## What This Repo Provisions

- **S3 bucket** for Terraform remote state (`bootstrap/`)
- **Persistent encrypted EBS volume** for n8n workflow data (`storage/`)
- **Standalone k3s EC2 server** that publishes its connection details to SSM (`k3s/`)
- **Application EC2 host** running n8n in Docker, served behind an ALB (`infra/`)
- **Route53 DNS** for `n8n.vyusufcan.cloud` and `chat.vyusufcan.cloud`
- **ACM-backed HTTPS** on the load balancer
- **Security groups** that restrict SSH to your current public IP at apply time

## Stack Layout

| Folder | Owns | Disposable? |
|---|---|---|
| `bootstrap/` | S3 remote state bucket | One-time |
| `storage/` | Persistent EBS volume at `/srv/n8n` | No — keep always |
| `k3s/` | k3s EC2 server + SSM parameters | Yes |
| `infra/` | App EC2, ALB, Route53, IAM, security groups | Yes |

`infra/` reads k3s connection details from SSM Parameter Store at plan time and at EC2 boot time. The EBS volume is attached to the app instance on each apply and detached safely on destroy.

## n8n Workflows

Two production workflows run on the platform:

**K8S SRE** — a chat-driven Kubernetes investigation agent. Send it a symptom description and it runs read-only `kubectl` commands to figure out what is wrong. Available as an MCP tool.

**Prometheus Alert Manager** — a webhook-triggered autonomous responder. When Alertmanager fires a `POST /prometheus-alert`, the workflow parses the payload, investigates the affected pod with `kubectl`, and emails a structured HTML incident report.

Both workflows use `gpt-4o`, share a kubeconfig at `.n8n/k3s/kubeconfig.yaml`, and are restricted to read-only kubectl operations.

## Docs

- [`docs/infra-diagram.html`](docs/infra-diagram.html) — full architecture diagram: infra components, Terraform stacks, and both workflow cards on one page
- [`docs/overview-presentation.html`](docs/overview-presentation.html) — 8-slide presentation covering design rationale, stack layout, traffic flow, persistence model, and workflow deep dives

## Assumptions

- The Route53 hosted zone for `vyusufcan.cloud` already exists
- An EC2 key pair named `n8n-admin` exists in `eu-west-1` and matches your local private key at `vyusufcan.pem`
- AWS credentials are configured under the profile name `n8n`
- `storage/` is applied before `infra/` so the EBS volume exists
- `k3s/` is applied before `infra/` so SSM contains the kubeconfig and private IP

## Deployment Order

### 1. Bootstrap — create state bucket (once)

```powershell
cd bootstrap
$env:AWS_PROFILE = "n8n"
terraform init
terraform apply -auto-approve
```

### 2. Create per-stack backend configs

Create a `backend.hcl` file in each of `storage/`, `k3s/`, and `infra/`:

```hcl
bucket = "your-terraform-state-bucket"
key    = "n8n-ollama/prod.tfstate"        # use a unique key per stack
region = "eu-west-1"
```

### 3. Apply storage

```powershell
cd storage
$env:AWS_PROFILE = "n8n"
terraform init -backend-config=backend.hcl
terraform apply
```

### 4. Apply k3s

Create `k3s/terraform.tfvars`:

```hcl
aws_profile       = "n8n"
project_name      = "n8n-ollama"
environment       = "prod"
key_pair_name     = "n8n-admin"
k3s_instance_type = "t3.medium"
```

```powershell
cd k3s
$env:AWS_PROFILE = "n8n"
terraform init -backend-config=backend.hcl
terraform apply
```

### 5. Apply infra

Create `infra/terraform.tfvars`:

```hcl
aws_profile        = "n8n"
project_name       = "n8n-ollama"
environment        = "prod"
domain_name        = "n8n.vyusufcan.cloud"
hosted_zone_name   = "vyusufcan.cloud"
certificate_arn    = "arn:aws:acm:eu-west-1:ACCOUNT_ID:certificate/CERT_ID"
instance_type      = "t3.small"
key_pair_name      = "n8n-admin"
n8n_encryption_key = "replace-with-a-long-random-string"
```

```powershell
cd infra
$env:AWS_PROFILE = "n8n"
terraform init -backend-config=backend.hcl
terraform apply
```

## Key Operational Notes

- **SSH ingress** is locked to your current public IP — resolved from `https://checkip.amazonaws.com/` at apply time.
- **Destroying `infra/`** does not delete the EBS volume. Workflow data is safe.
- **Never destroy `storage/`** unless you intend to delete all n8n data permanently.
- **ALB health checks** hit `GET /healthz` on port `5678` for n8n and `GET /` on port `80` for the chat UI.
- **k3s API** (port `6443`) is reachable only from within the VPC CIDR.
- **EC2 AMI** is Ubuntu 24.04 LTS (Canonical).
