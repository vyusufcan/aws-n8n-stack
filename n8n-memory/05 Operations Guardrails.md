# Operations Guardrails

## Non-Negotiable Defaults

- Prefer `AWS_PROFILE=n8n`.
- Treat `infra/` as the default Terraform working folder unless the task clearly targets `bootstrap/`, `storage/`, or `k3s/`.
- Verify repo facts from files before relying on remembered context.

## Destruction Rules

- `infra/` is disposable.
- `k3s/` is disposable.
- `storage/` is persistent and should be preserved unless the task explicitly includes deleting application data.

## Documentation Rules

- Store durable decisions here in the vault.
- Keep personal domains, secrets, and copied credential material out of the vault.
- Record repo topology changes here when folders, ownership boundaries, or bootstrapping behavior change.

## Known Failure Patterns

- Missing or incomplete `AWS_PROFILE=n8n` credentials can surface as Terraform credential errors.
- Local proxy or sandbox restrictions can break AWS calls without indicating a Terraform bug.
- `terraform validate` is not enough to claim the live environment was updated.
- Security group behavior can differ from older notes; always verify the current checked-in Terraform before assuming prior access restrictions still apply.

## Recommended Session Start

For future work in this repo:

1. Read [[00 Start Here]].
2. Read the note for the part of the stack being changed.
3. Verify current repo files if the note might be stale.
4. Only then run Terraform or AWS commands.
