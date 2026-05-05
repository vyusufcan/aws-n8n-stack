# n8n Memory Vault

This vault is the durable context layer for the `n8n` repository. Future work should start here instead of relying on assistant memory alone.

## Read Order

1. [[01 Repo Overview]]
2. [[02 Stack Topology]]
3. [[03 Deployment Workflow]]
4. [[04 Runtime Model]]
5. [[05 Operations Guardrails]]

## Purpose

- Keep the repo's real operating model in one place.
- Preserve decisions that are easy to lose between sessions.
- Separate durable repo knowledge from ephemeral terminal history.

## Scope

This vault documents:

- the Terraform stack split across `bootstrap/`, `storage/`, `k3s/`, and `infra/`
- deployment order and dependencies
- runtime behavior on the EC2 host
- local-only operational constraints

This vault should not store:

- secrets
- private keys
- raw credential files
- copied `terraform.tfvars` values
- transient command output unless it explains a durable repo decision

## Working Rules

- Prefer facts verified from repo files over memory.
- Update the relevant note when the repo topology or operating model changes.
- Keep examples neutral unless a real value is required and safe to store.
- Treat this vault as the first source of context for future sessions in this repo.
