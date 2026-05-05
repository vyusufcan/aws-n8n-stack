helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f prometheus-values.yaml

# CrashLoop pod deploy et
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: crashloop-test
  namespace: default
  labels:
    app: crashloop-test
spec:
  containers:
  - name: crashloop
    image: busybox
    command: ["sh", "-c", "exit 1"]
EOF