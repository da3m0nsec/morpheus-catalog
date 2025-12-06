#!/bin/bash

# Simple Web Application Deployment Script for Kubernetes

set -e

echo "========================================="
echo "Simple Web Application Deployment"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please install kubectl first."
    exit 1
fi

# Check cluster connection
if ! kubectl cluster-info &> /dev/null; then
    echo "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

print_info "Connected to Kubernetes cluster"
kubectl cluster-info | head -1
echo ""

# Deploy resources in order
print_info "Creating namespace..."
kubectl apply -f namespace.yaml

print_info "Creating ConfigMap..."
kubectl apply -f configmap.yaml

print_info "Creating Deployment..."
kubectl apply -f deployment.yaml

print_info "Creating Service..."
kubectl apply -f service.yaml

print_info "Creating HPA (optional, requires metrics-server)..."
kubectl apply -f hpa.yaml 2>/dev/null || print_warn "HPA creation failed (metrics-server might not be installed)"

echo ""
print_info "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s \
    deployment/webapp-deployment -n simple-webapp

echo ""
print_info "Deployment Status:"
kubectl get all -n simple-webapp

echo ""
print_info "Service Information:"
kubectl get svc webapp-service -n simple-webapp

echo ""
print_info "Deployment complete!"
echo ""
echo "To access the application:"
echo "  1. Get the service external IP:"
echo "     kubectl get svc webapp-service -n simple-webapp"
echo "  2. Access the application:"
echo "     curl http://<EXTERNAL-IP>"
echo ""
echo "To check logs:"
echo "  kubectl logs -l app=webapp -n simple-webapp"
echo ""
echo "To scale the deployment:"
echo "  kubectl scale deployment webapp-deployment --replicas=5 -n simple-webapp"
echo ""
