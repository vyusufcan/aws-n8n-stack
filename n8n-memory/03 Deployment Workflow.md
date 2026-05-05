# Deployment Workflow

## Standard Order

1. Apply `bootstrap/` once to create the Terraform state bucket.
2. Create per-stack `backend.hcl` files locally.
3. Apply `storage/` to create or preserve the persistent EBS volume.
4. Apply `k3s/` so SSM contains the k3s kubeconfig and private IP.
5. Apply `infra/` to create the application layer.

## Expected Local Files

These are local operational files and should be treated as sensitive or environment-specific:

- `storage/backend.hcl`
- `storage/terraform.tfvars`
- `k3s/backend.hcl`
- `k3s/terraform.tfvars`
- `infra/backend.hcl`
- `infra/terraform.tfvars`
- `OPERATIONS.md`

## Known Command Pattern

Use PowerShell and set:

```powershell
$env:AWS_PROFILE = "n8n"
```

Then run Terraform from the target folder.

## What Each Stack Needs

### `storage/`

- backend config
- optional `terraform.tfvars` override for volume sizing

### `k3s/`

- backend config
- tfvars for key pair and instance size if defaults are not enough

### `infra/`

- backend config
- `data_volume_id` from `storage`
- certificate ARN
- domain and hosted zone values
- `n8n_encryption_key`

## Apply Expectations

- `storage/` may report no changes while the rest of the system still needs work.
- `k3s/` and `infra/` are the stacks most likely to be recreated during iterative changes.
- If AWS calls fail because of local proxy or credential issues, treat that as an execution boundary, not as proof that the Terraform configuration is wrong.
