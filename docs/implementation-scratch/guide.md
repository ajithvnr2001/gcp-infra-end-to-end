# 🏗️ Building a Production E-Commerce Platform on GCP from Scratch

This guide provides a comprehensive, step-by-step walkthrough of how this project was designed and implemented. It covers infrastructure provisioning, microservices development, Kubernetes orchestration, GitOps, and CI/CD.

---

## 📑 Table of Contents
1. [Architecture Design](#architecture-design)
2. [Phase 1: Infrastructure as Code (Terraform)](#phase-1-infrastructure-as-code-terraform)
3. [Phase 2: Developing Microservices (FastAPI)](#phase-2-developing-microservices-fastapi)
4. [Phase 3: Kubernetes Orchestration](#phase-3-kubernetes-orchestration)
5. [Phase 4: GitOps with ArgoCD](#phase-4-gitops-with-argocd)
6. [Phase 5: CI/CD Pipeline (GitHub Actions)](#phase-5-cicd-pipeline-github-actions)
7. [Phase 6: Security & Zero-Trust](#phase-6-security--zero-trust)
8. [Phase 7: Observability & Monitoring](#phase-7-observability--monitoring)

---

## Architecture Design

The project follows a **Cloud-Native Microservices** architecture pattern:

- **Google Kubernetes Engine (GKE) Autopilot**: Chosen for managed Kubernetes with automatic scaling and security.
- **Microservices (Python FastAPI)**: Lightweight, high-performance services handling specific domains (Catalog, Cart, Payment, API Gateway).
- **Terraform**: Used for consistent, reproducible infrastructure provisioning.
- **GitOps (ArgoCD)**: Ensures the cluster state always matches the Git repository.
- **GitHub Actions**: Provides automated testing and container image builds.

---

## Phase 1: Infrastructure as Code (Terraform)

We use a modular Terraform structure to manage GCP resources.

### 1.1 Project Structure
```text
terraform/
├── envs/prod/          # Entry point for production
└── modules/            # Reusable resource blocks
    ├── vpc/            # Networking (VPC, Subnets, Cloud NAT)
    ├── gke/            # GKE Cluster definition
    └── cloudsql/       # PostgreSQL Database
```

### 1.2 Resource Breakdown
- **VPC Module**: Creates a custom network with private subnets. We use **Cloud NAT** so private GKE nodes can access the internet (to pull images or updates) without having public IPs.
- **GKE Module**: Provisions an **Autopilot** cluster. This is the modern recommendation for GCP as it manages nodes, scaling, and security patches for you.
- **Cloud SQL Module**: Creates a private PostgreSQL instance for service persistence.

### 1.3 State Management
We use a **GCS Bucket** for remote state storage. This allows multiple team members to work on the infrastructure without state conflicts.
```hcl
backend "gcs" {
  bucket = "tf-state-ecommerce-prod"
  prefix = "prod/terraform.tfstate"
}
```

---

## Phase 2: Developing Microservices (FastAPI)

Each service (e.g., `catalog`, `cart`) is built as a standalone container.

### 2.1 Production-Ready code
The `main.py` in each service includes:
- **Structured JSON Logging**: Formats logs so GCP Cloud Logging can parse them automatically.
- **OpenTelemetry Tracing**: Sends trace data to **GCP Cloud Trace** for distributed debugging.
- **Prometheus Metrics**: Exposes an `/metrics` endpoint for performance monitoring.
- **Health Checks**: `/health` and `/ready` endpoints for Kubernetes probes.

### 2.2 Containerization (Dockerfile)
We use multi-stage builds or slim base images (like `python:3.11-slim`) to keep images small and secure.
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## Phase 3: Kubernetes Orchestration

The `k8s/` folder contains the "desired state" of our application.

### 3.1 Namespace Isolation
We deploy into a dedicated `ecommerce` namespace to isolate our resources from system pods.

### 3.2 Deployments & Services
- **HPA (Horizontal Pod Autoscaler)**: Automatically scales the number of pods based on CPU/Memory usage.
- **ClusterIP Services**: Internal communication between microservices.
- **Ingress (NGINX)**: The entry point that routes external traffic to the `api-gateway`.

### 3.3 Configuration & Secrets
- **ConfigMaps**: Store environment-specific variables like `DB_HOST`.
- **Secrets**: Use GCP Secret Manager or K8s Secrets (templated) for sensitive data like `DB_PASSWORD`.

---

## Phase 4: GitOps with ArgoCD

ArgoCD implements the **Continuous Delivery** part of the pipeline.

### 4.1 "App of Apps" Pattern
We apply a single manifest (`argocd/apps.yaml`) that tells ArgoCD to watch the `k8s/` directory in our GitHub repo.

### 4.2 Automated Sync
If we push a change to a Kubernetes manifest in Git, ArgoCD detects the drift and automatically updates the cluster. It also provides a **self-healing** mechanism: if someone manually deletes a pod or service via `kubectl`, ArgoCD will recreate it to match Git.

---

## Phase 5: CI/CD Pipeline (GitHub Actions)

The `.github/workflows/ci-cd.yaml` handles the automation:

1.  **PR Checks**: Run unit tests and linting on every Pull Request.
2.  **Container Build**: When code is merged to `main`, it builds a new Docker image.
3.  **Push to GCR**: The image is tagged (using the Git SHA) and pushed to **Google Container Registry**.
4.  **Manifest Update**: (Optional but recommended) The pipeline can update the image tag in the `k8s/` manifests, triggering ArgoCD to deploy the new version.

---

## Phase 6: Security & Zero-Trust

Security is baked into the platform using Kubernetes native resources in `k8s/security/`.

### 6.1 Zero-Trust Networking (NetPol)
We use **Network Policies** to implement a "Deny All" by default stance.
- **Microservice Isolation**: Only the API Gateway can talk to the microservices.
- **Namespace Isolation**: Prevents unauthorized traffic from other namespaces.
- **Egress Control**: Pods can only talk to specific external services (e.g., Payment Gateway or GCP APIs).

### 6.2 Least-Privilege RBAC
We define custom **Roles** and **ServiceAccounts** in `rbac.yaml`:
- **Workload Identity**: Pods use GCP Service Accounts via annotations, avoiding the need for static JSON keys.
- **Scaped Roles**: Developers have "Read-Only" access, while the CI/CD service account only has "Patch" permissions on specific deployments.

### 6.3 Secret Management
We use **External Secrets Operator** to sync secrets from **GCP Secret Manager** into Kubernetes. High-value secrets like DB passwords never touch Git or the local environment.

---

## Phase 7: Observability & Monitoring

We don't just "deploy and forget"; we monitor production health.

### 6.1 Monitoring Stack
- **Cloud Monitoring Dashboards**: Visualize request rates, latency, and error codes.
- **Uptime Checks**: Ping the API Gateway every minute from multiple global locations.
- **Alerting Policies**: If the error rate exceeds 5% or the site goes down, an email alert is sent via the `setup-monitoring.sh` script configuration.

### 6.2 Distributed Tracing
Using **Cloud Trace**, we can see the entire lifecycle of a request as it hops from the API Gateway to the Catalog service and back, helping identify bottlenecks.

---

## 🏁 Final Thoughts

Implementing this from scratch requires a "Shift Left" mentality where security, monitoring, and infrastructure are treated as code from day one. By combining **Terraform, GKE, and GitOps**, we've built a platform that is not only scalable but also extremely resilient and easy to maintain.
