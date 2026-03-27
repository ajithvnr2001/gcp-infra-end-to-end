# 🛒 Production E-Commerce Platform on GCP
### Full End-to-End DevOps Project | GKE · Terraform · ArgoCD · GitHub Actions · Cloud Monitoring

---

## 🏗️ Architecture Overview

```
GitHub Repo
    │
    ▼
GitHub Actions CI
    │  (test → docker build → push to GCR)
    ▼
Google Container Registry (GCR)
    │
    ▼
ArgoCD (GitOps sync)
    │
    ▼
GKE Cluster (Autopilot)
    ├── api-gateway      (Ingress → routes all traffic)
    ├── catalog-service  (Product listings)
    ├── cart-service     (Add/remove items)
    └── payment-service  (Order processing)
    │
    ├── Cloud SQL (PostgreSQL) — catalog & orders DB
    ├── Cloud Monitoring — dashboards + alerting
    └── Cloud NAT — outbound internet for private nodes
```

---

## 📁 Folder Structure

```
ecommerce-gcp-project/
├── terraform/                  ← Infrastructure as Code
│   ├── envs/prod/              ← Production env entry point
│   └── modules/
│       ├── vpc/                ← VPC, subnets, Cloud NAT
│       ├── gke/                ← GKE Autopilot cluster
│       └── cloudsql/           ← Postgres DB
│
├── k8s/                        ← Kubernetes manifests (ArgoCD watches this)
│   ├── namespaces/
│   ├── deployments/            ← All 4 microservices
│   ├── services/               ← ClusterIP + LoadBalancer
│   ├── hpa/                    ← Horizontal Pod Autoscaler
│   ├── ingress/                ← NGINX Ingress Controller
│   ├── configmaps/
│   └── secrets/                ← (templates only, never commit real secrets)
│
├── argocd/                     ← ArgoCD Application manifests
│
├── github-actions/             ← CI/CD pipeline workflows
│
├── monitoring/                 ← Alert policies + dashboards JSON
│
├── services/                   ← Sample microservice code (Python FastAPI)
│   ├── catalog/
│   ├── cart/
│   ├── payment/
│   └── api-gateway/
│
└── scripts/                    ← Helper shell scripts
```

---

## 🚀 Step-by-Step Setup Guide

### Step 1 — Prerequisites
```bash
# Install these tools on your machine
gcloud CLI     → https://cloud.google.com/sdk/docs/install
terraform      → https://developer.hashicorp.com/terraform/install
kubectl        → https://kubernetes.io/docs/tasks/tools/
argocd CLI     → https://argo-cd.readthedocs.io/en/stable/cli_installation/
helm           → https://helm.sh/docs/intro/install/
docker         → https://docs.docker.com/get-docker/
```

### Step 2 — GCP Project Setup
```bash
# Authenticate
gcloud auth login
gcloud auth application-default login

# Set your project (replace with your project ID)
export PROJECT_ID="your-gcp-project-id"
export REGION="asia-south1"    # Mumbai — closest to India

gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable \
  container.googleapis.com \
  sqladmin.googleapis.com \
  cloudbuild.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  artifactregistry.googleapis.com \
  compute.googleapis.com
```

### Step 3 — Provision Infrastructure with Terraform
```bash
cd terraform/envs/prod
terraform init
terraform plan -var="project_id=$PROJECT_ID" -var="region=$REGION"
terraform apply -var="project_id=$PROJECT_ID" -var="region=$REGION"
```

### Step 4 — Connect to GKE
```bash
gcloud container clusters get-credentials ecommerce-cluster \
  --region $REGION --project $PROJECT_ID
kubectl get nodes
```

### Step 5 — Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Port-forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open: https://localhost:8080  (user: admin)
```

### Step 6 — Install NGINX Ingress Controller
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer
```

### Step 7 — Deploy ArgoCD Applications
```bash
# Apply namespace first
kubectl apply -f k8s/namespaces/

# Apply ArgoCD apps — these will auto-sync your k8s/ folder to the cluster
kubectl apply -f argocd/
```

### Step 8 — Set up GitHub Actions CI
```bash
# Add these secrets to your GitHub repo (Settings → Secrets → Actions):
GCP_PROJECT_ID     → your GCP project ID
GCP_SA_KEY         → base64 encoded service account JSON key
GCR_HOSTNAME       → gcr.io
```

### Step 9 — Configure Monitoring Alerts
```bash
cd scripts/
chmod +x setup-monitoring.sh
./setup-monitoring.sh
```

---

## 💡 What You Will Learn

| Area | Skills Practiced |
|------|-----------------|
| Terraform | VPC, GKE, Cloud SQL modules, remote state, workspaces |
| Kubernetes | Deployments, HPA, Ingress, ConfigMaps, Secrets, Rolling updates |
| ArgoCD | GitOps sync, self-healing, app-of-apps pattern |
| GitHub Actions | Multi-stage CI, Docker build, GCR push, ArgoCD trigger |
| GCP Monitoring | SLO alerts, log-based metrics, uptime checks, dashboards |
| Python | FastAPI microservices, Dockerfile, health endpoints |

---

## ⚡ Simulate Production Scenarios

```bash
# 1. Simulate flash sale traffic spike → watch HPA scale pods
kubectl run load-test --image=busybox --restart=Never -- \
  sh -c "while true; do wget -q -O- http://api-gateway/catalog; done"

# 2. Force a rollback
kubectl rollout undo deployment/catalog-service -n ecommerce

# 3. Kill a pod → watch self-healing
kubectl delete pod -l app=cart-service -n ecommerce

# 4. Watch HPA in real time
kubectl get hpa -n ecommerce -w

# 5. Check ArgoCD sync status
argocd app list
argocd app sync ecommerce-catalog
```
