# Repo Overview

This repository provisions and operates an AWS-hosted `n8n` deployment with supporting infrastructure.

## High-Level Intent

- `bootstrap/` creates the S3 bucket for Terraform remote state.
- `storage/` owns the persistent EBS data volume.
- `k3s/` owns a separate Kubernetes server and publishes its connection details to SSM Parameter Store.
- `infra/` owns the application EC2 instance, ALB, DNS, IAM, security groups, and attaches the persistent data volume.

## Durable Defaults

- AWS region: `eu-west-1`
- AWS profile: `n8n`
- Project name: `n8n-ollama`
- Environment: `prod`
- App port: `5678`
- Chat UI host port: `80`
- Host data mount: `/srv/n8n`
- k3s kubeconfig copy target under the data disk: `k3s/kubeconfig.yaml`

## Important Repo Reality

- The repo is no longer a single-stack Terraform setup.
- `storage/` is the persistent layer.
- `k3s/` and `infra/` are the disposable layers.
- `infra/` depends on both `storage/` and `k3s/` outputs being available before it can fully work.

## Files Worth Reading First

- [README.md](../README.md)
- [bootstrap/main.tf](../bootstrap/main.tf)
- [storage/main.tf](../storage/main.tf)
- [k3s/main.tf](../k3s/main.tf)
- [infra/main.tf](../infra/main.tf)
- [infra/user_data.sh.tftpl](../infra/user_data.sh.tftpl)
- [k3s/user_data.sh.tftpl](../k3s/user_data.sh.tftpl)
