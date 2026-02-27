#!/bin/bash

echo "========================================"
echo "  GitOps Monitoring Project - Startup"
echo "========================================"

# Step 1: Start Minikube
echo ""
echo "[1/4] Starting Minikube..."
minikube start
if [ $? -ne 0 ]; then
  echo "ERROR: Minikube failed to start."
  exit 1
fi

# Step 2: Restart deployments
echo ""
echo "[2/4] Restarting deployments..."
kubectl rollout restart deployment -n argocd 2>/dev/null
kubectl rollout restart deployment -n monitoring 2>/dev/null
echo "Waiting 40 seconds for pods to stabilize..."
sleep 40

# Step 3: Start all tunnels in background
echo ""
echo "[3/4] Starting service tunnels in background..."

minikube service argocd-server -n argocd --url > /tmp/argo_url.txt 2>/dev/null &
minikube service monitoring-grafana -n monitoring --url > /tmp/grafana_url.txt 2>/dev/null &
minikube service monitoring-kube-prometheus-prometheus -n monitoring --url > /tmp/prom_url.txt 2>/dev/null &
minikube service gitops-app-service -n gitops-app --url > /tmp/app_url.txt 2>/dev/null &

echo "Waiting 15 seconds for tunnels to establish..."
sleep 15

# Step 4: Print URLs
echo ""
echo "========================================"
echo "  SERVICE URLS"
echo "========================================"
echo ""
echo "ArgoCD UI:   $(head -1 /tmp/argo_url.txt)"
echo "Grafana:     $(head -1 /tmp/grafana_url.txt)  (admin/gitops123)"
echo "Prometheus:  $(head -1 /tmp/prom_url.txt)"
echo "App:         $(cat /tmp/app_url.txt | head -1)"
echo ""
echo "========================================"
echo "  Copy URLs above and open in Chrome"
echo "  Keep this terminal OPEN"
echo "========================================"
