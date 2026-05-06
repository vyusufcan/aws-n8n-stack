# Workflow Summary

## `K8S SRE.json`

- Type: chat-driven SRE assistant workflow.
- Trigger: public `chatTrigger` webhook named `When chat message received`.
- Model: `gpt-4o` via `OpenAI Chat Model`.
- Tooling: `Execute Command` node used as an AI tool for `kubectl` shell commands.
- Memory: `Simple Memory` buffer window with context length `10`.
- Main purpose: investigate Kubernetes cluster issues through read-only `kubectl` access.
- Kubeconfig path expected by the agent: `./.n8n/k3s/kubeconfig.yaml`.
- Safety rules in prompt:
  - always use `--kubeconfig`
  - read-only commands only
  - no `delete`, `apply`, `patch`, `edit`, `exec`, or `port-forward`
  - maximum `10` kubectl commands per investigation
- Output behavior:
  - pod listings must be formatted as markdown tables
  - other investigations return structured status, findings, commands, details, and recommendations
  - agent should answer in the same language as the user
- Notable setting: `availableInMCP = true`.

## `Prometheus Alert Manager.json`

- Type: alert-driven incident investigation workflow.
- Trigger: `Webhook` node with `POST` path `prometheus-alert`.
- Model: `gpt-4o` via `OpenAI Chat Model`.
- Tooling: `Execute Command` node used for autonomous read-only `kubectl` investigation.
- Main purpose: receive Prometheus Alertmanager payloads, investigate the affected pod or node, and send an incident email.
- Flow:
  1. `Webhook` receives Alertmanager request.
  2. `Parse Alert Payload` extracts `alertname`, `severity`, `namespace`, `pod`, `status`, `summary`, `description`, `startsAt`, and `notification_reason`.
  3. `AI Agent` runs the investigation using `kubectl`.
  4. `Parse AI Agent Output` parses the returned JSON report and builds an HTML email.
  5. `Send a message` sends the report through Gmail to `vehbiyusufcan@gmail.com`.
- Agent output contract:
  - strict JSON only
  - includes `incident`, `investigation`, `root_cause`, `recommendation`, and `email`
- Safety rules in prompt:
  - same read-only `kubectl` restrictions as the chat workflow
  - maximum `10` kubectl commands
  - retry logic for `BadRequest`
  - continue with alternatives on `Forbidden`
- Email formatting:
  - HTML incident report
  - severity-colored header
  - incident metadata, root cause, recommendations, commands run, and findings

## Shared Notes

- Both workflows assume shell access to `kubectl` on the n8n host.
- Both workflows depend on the kubeconfig file at `./.n8n/k3s/kubeconfig.yaml`.
- Both workflows use the same OpenAI credential name: `OpenAI account`.
- Both workflows are active exports.
