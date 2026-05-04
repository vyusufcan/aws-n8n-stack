#!/bin/bash

# ─── CONFIGURE THIS ────────────────────────────────────────────
K3S_PRIVATE_IP="<K3S_PRIVATE_IP>"   # e.g. 10.0.1.50
# ───────────────────────────────────────────────────────────────

NAMESPACE="kube-system"
SA_NAME="n8n-ai-agent"
KUBECONFIG_FILE="n8n-agent-kubeconfig.yaml"

# Create long-lived token secret
kubectl apply -f - <<MANIFEST
apiVersion: v1
kind: Secret
metadata:
  name: n8n-ai-agent-token
  namespace: ${NAMESPACE}
  annotations:
    kubernetes.io/service-account.name: ${SA_NAME}
type: kubernetes.io/service-account-token
MANIFEST

# Wait for token to be populated
echo "Waiting for token..."
sleep 5

# Extract values
TOKEN=$(kubectl get secret n8n-ai-agent-token -n ${NAMESPACE} -o jsonpath='{.data.token}' | base64 -d)
CA=$(kubectl get secret n8n-ai-agent-token -n ${NAMESPACE} -o jsonpath='{.data.ca\.crt}')

# Write kubeconfig with private IP
cat > ${KUBECONFIG_FILE} <<KUBECONF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CA}
    server: https://${K3S_PRIVATE_IP}:6443
  name: k3s-n8n
contexts:
- context:
    cluster: k3s-n8n
    user: n8n-ai-agent
  name: n8n-context
current-context: n8n-context
users:
- name: n8n-ai-agent
  user:
    token: ${TOKEN}
KUBECONF

echo "Kubeconfig generated: ${KUBECONFIG_FILE}"
echo "Server: https://${K3S_PRIVATE_IP}:6443"