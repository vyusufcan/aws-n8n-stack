# Runtime Model

## App Host

The `infra/` stack launches an Ubuntu 24.04 EC2 instance that:

- receives a persistent EBS volume attachment
- mounts the data disk at `/srv/n8n`
- runs `n8n` in Docker
- exposes `n8n` on host port `5678`
- serves a separate chat UI behind nginx on host port `80`

## Load Balancer

- ALB listener: HTTPS `443`
- Default target group: `n8n`
- Additional listener rule: forwards the chat host name to the chat target group
- Health checks:
  - n8n: `GET /healthz` on port `5678`
  - chat UI: `GET /` on port `80`

## Security Groups

### `k3s`

- SSH from the current public IP at apply time
- k3s API `6443` from the VPC CIDR

### `infra`

- ALB allows `443` from `0.0.0.0/0` in the current checked-in `infra/main.tf`
- App instance allows:
  - `5678` from the ALB
  - `5678` from the k3s private IP
  - `80` from the ALB
  - `22` from the current public IP at apply time

## Persistence Model

- Root disk is ephemeral and deleted with the app instance.
- The separate EBS volume is the durable data layer.
- The persistent data path is `/srv/n8n` on the host and `/home/node/.n8n` in the container.

## k3s Integration

- `k3s/` publishes connection details to SSM.
- `infra/` reads the k3s private IP during Terraform evaluation.
- `infra/user_data.sh.tftpl` uses the kubeconfig parameter name during bootstrap so the app host can work with the cluster context.
