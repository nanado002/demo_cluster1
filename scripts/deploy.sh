#!/bin/bash
# EKS 2048 Game Deployment Script

set -e

# Configuration
CLUSTER_NAME="demo-cluster"
REGION="us-east-1"
NAMESPACE="game-2048"

echo "Starting EKS 2048 deployment..."

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install eksctl
echo "Installing eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Create EKS cluster
echo "Creating EKS cluster..."
eksctl create cluster --name $CLUSTER_NAME --region $REGION --fargate

# Update kubeconfig
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Create Fargate profile
echo "Creating Fargate profile..."
eksctl create fargateprofile \
    --cluster $CLUSTER_NAME \
    --region $REGION \
    --name alb-sample-app \
    --namespace $NAMESPACE

# Deploy 2048 game
echo "Deploying 2048 game..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/examples/2048/2048_full.yaml

echo "Deployment completed! Check your ingress for the ALB URL:"
kubectl get ingress -n $NAMESPACE
