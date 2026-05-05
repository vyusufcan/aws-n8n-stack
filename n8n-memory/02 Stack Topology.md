# Stack Topology

## Ownership Split

### `bootstrap/`

- Creates the remote-state S3 bucket.
- Uses the `n8n` AWS profile by default.
- Has no dependency on the other stacks.

### `storage/`

- Creates the persistent encrypted EBS volume for n8n data.
- This is the stateful layer that should survive `infra` recreation.
- `infra/` consumes the resulting `data_volume_id`.

### `k3s/`

- Creates a standalone Ubuntu EC2 instance for k3s.
- Restricts SSH to the current public IP at apply time.
- Allows port `6443` from within the VPC.
- Publishes these SSM parameters:
  - `/${project_name}-${environment}/k3s/kubeconfig`
  - `/${project_name}-${environment}/k3s/private-ip`

### `infra/`

- Creates the app EC2 instance, ALB, Route53 records, IAM role/profile, and security groups.
- Attaches the persistent EBS volume created by `storage/`.
- Reads the k3s private IP from SSM during Terraform evaluation.
- Passes the kubeconfig parameter name into EC2 `user_data` for bootstrap-time consumption.

## Dependency Order

1. `bootstrap/`
2. `storage/`
3. `k3s/`
4. `infra/`

## Practical Dependency Notes

- `storage/` can remain unchanged while `infra/` is recreated. That is normal.
- `k3s/` must run before `infra/` when the app host needs the kubeconfig and private IP published to SSM.
- Destroying `infra/` should not delete persistent data.
- Destroying `k3s/` and `infra/` together is safe only when the goal is to remove the disposable layers while preserving `storage/`.
