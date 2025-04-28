#!/bin/bash
set -e

# 1. Start Minikube
echo "🚀 Starting Minikube..."
# minikube start --cpus=4 --memory=6g --disk-size=30g

# 2. Create ArgoCD namespace
echo "🚀 Creating namespace 'argocd'..."
kubectl create namespace infrastructure || true

# 3. Install ArgoCD
echo "🚀 Installing ArgoCD..."
kubectl apply -n infrastructure -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 4. Install Argo Rollouts
echo "🚀 Installing Argo Rollouts..."
kubectl apply -n infrastructure -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# 5. Wait for ArgoCD server to be ready
echo "⏳ Waiting for ArgoCD server to be ready..."
kubectl rollout status deployment/argocd-server -n infrastructure

# 6. Port-forward ArgoCD
echo "🚀 Port-forwarding ArgoCD server to localhost:8080..."
kubectl port-forward svc/argocd-server -n infrastructure 8080:443 > /dev/null 2>&1 &
sleep 5

# 7. Print login info
echo "✅ ArgoCD UI ready at: https://localhost:8080"
echo "👤 Username: admin"
echo -n "🔑 Password: "
kubectl get secret argocd-initial-admin-secret -n infrastructure -o jsonpath="{.data.password}" | base64 -d
echo ""

# 8. Done!
echo "🎉 Setup complete! You can now open ArgoCD UI and start deploying Rollouts."