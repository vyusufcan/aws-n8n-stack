# n8n Infrastructure Diagram

This diagram reflects the current split-stack topology in this repository.

```mermaid
flowchart TB
  user[User Browser]
  dns[Route53<br/>n8n.vyusufcan.cloud<br/>chat.vyusufcan.cloud]
  alb[Application Load Balancer<br/>HTTPS 443]
  app[EC2 App Host<br/>Docker Compose<br/>n8n :5678<br/>chat UI :80]
  data[(Persistent EBS Volume<br/>/srv/n8n)]
  k3s[K3s EC2 Server<br/>Ubuntu<br/>API :6443]
  ssm[(SSM Parameter Store<br/>/n8n-ollama-prod/k3s/private-ip<br/>/n8n-ollama-prod/k3s/kubeconfig)]
  state[(S3 Terraform State)]

  user --> dns
  dns --> alb
  alb -->|default host| app
  alb -->|chat.vyusufcan.cloud| app
  app --> data
  k3s --> ssm
  ssm --> app

  subgraph Terraform Stacks
    bootstrap[bootstrap/<br/>creates remote state bucket]
    storage[storage/<br/>creates persistent EBS]
    k3sstack[k3s/<br/>creates k3s server]
    infrastack[infra/<br/>creates app, ALB, DNS]
  end

  bootstrap --> state
  storage --> data
  k3sstack --> k3s
  k3sstack --> ssm
  infrastack --> alb
  infrastack --> app
  infrastack --> dns
  infrastack --> data

  classDef edge fill:#eef6ff,stroke:#2a5c8a,color:#0f2740;
  classDef store fill:#fff7e8,stroke:#c98a16,color:#573600;
  classDef stack fill:#edf8ef,stroke:#2e7d4f,color:#153924;
  class user,dns,alb,app,k3s edge;
  class data,ssm,state store;
  class bootstrap,storage,k3sstack,infrastack stack;
```

## Provisioning Order

1. `bootstrap/`
2. `storage/`
3. `k3s/`
4. `infra/`

## Key Notes

- `storage/` owns the persistent EBS volume and should survive app rebuilds.
- `k3s/` publishes its private IP and kubeconfig path into SSM.
- `infra/` reads the k3s private IP from SSM and permits app access from the k3s server.
- Public HTTPS traffic enters through the ALB and is routed to the app EC2 instance.
