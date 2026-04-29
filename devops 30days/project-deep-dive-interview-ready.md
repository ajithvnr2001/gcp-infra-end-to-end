# Project Deep Dive - GCP Ecommerce DevOps Platform

Use this file to explain your current project in interviews. It is written for a DevOps / Cloud Engineer with 2.5 to 3 years experience.

## 30-Second Explanation

```text
This is a production-style ecommerce microservices platform built on GCP. It has frontend, API gateway, catalog, cart, and payment services. The services are containerized with Docker, deployed to GKE using Kubernetes manifests, provisioned with Terraform, built through Cloud Build, stored in Artifact Registry, and deployed using a GitOps-style ArgoCD workflow. It also includes monitoring, security manifests, and local Docker Compose for development.
```

## 2-Minute Interview Explanation

```text
The project simulates a real ecommerce platform. The browser talks to a frontend service served by NGINX. API requests go to an API gateway, and the gateway routes traffic to catalog, cart, and payment services.

From a DevOps perspective, the important part is the delivery and infrastructure workflow. Terraform provisions the GCP infrastructure such as VPC, GKE, and Cloud SQL modules. Cloud Build builds Docker images for each service, tags them with commit SHA and latest, pushes them to Artifact Registry, and updates Kubernetes manifests. ArgoCD watches the Git repository and reconciles the desired state into the GKE cluster.

Kubernetes manifests define Deployments, Services, ConfigMaps, HPA, security policies, and observability components. The project also includes Prometheus/Grafana style monitoring and OpenTelemetry-related dependencies for tracing/metrics.

The main learning from this project is end-to-end DevOps: infrastructure as code, containerization, CI/CD, image registry, Kubernetes deployment, GitOps, observability, security hardening, and production-style troubleshooting.
```

## Architecture Flow

```text
User Browser
  -> Frontend Service (NGINX static app)
  -> /api requests
  -> API Gateway
      -> Catalog Service
      -> Cart Service
      -> Payment Service

DevOps Flow
  -> Developer push to Git
  -> Cloud Build pipeline
  -> Docker build for each service
  -> Artifact Registry image push
  -> Kubernetes manifest image tag update
  -> ArgoCD sync
  -> GKE rollout
  -> Monitoring and verification

Infrastructure Flow
  -> Terraform
  -> VPC
  -> GKE
  -> Cloud SQL
  -> Supporting networking/security resources
```

## Services

### Frontend Service

Purpose:

- Serves ecommerce UI.
- Uses NGINX.
- Proxies `/api/*` requests to API gateway.
- Supports product search, cart, checkout, and order history.

Interview explanation:

```text
The frontend is packaged as a container using NGINX. It separates UI delivery from backend APIs and can be scaled independently in Kubernetes.
```

### API Gateway

Purpose:

- Entry point for backend API calls.
- Routes product calls to catalog service.
- Routes cart actions to cart service.
- Routes order creation and history to payment service.
- Clears cart after successful order.

Interview explanation:

```text
The API gateway simplifies frontend communication and hides internal service topology. It is also the right place for cross-cutting concerns like routing, auth, rate limiting, and request tracing in a real production version.
```

### Catalog Service

Purpose:

- Serves product list.
- Supports category filtering, product lookup, search, health, readiness.

Interview explanation:

```text
Catalog is a read-heavy service. In a production architecture, this could use cache/CDN or a database-backed product store.
```

### Cart Service

Purpose:

- Maintains user cart state.
- Supports add, update quantity, remove, clear cart.

Interview explanation:

```text
Cart is state-oriented. In production I would back it with Redis or a database, depending on persistence requirements.
```

### Payment Service

Purpose:

- Creates orders.
- Stores order history.
- Returns order by ID and user.

Interview explanation:

```text
Payment/order flow is critical, so I would focus on idempotency, audit logs, retries, and secure secret handling in production.
```

## Infrastructure Components

### Terraform

What it does:

- Defines infrastructure as code.
- Uses environment folder: `terraform/envs/prod`.
- Uses modules for VPC, GKE, Cloud SQL.

Interview answer:

```text
Terraform gives reproducibility and drift control. I would review `terraform plan` before apply, store state remotely, enable locking, and avoid manual cloud console changes.
```

### GKE

What it does:

- Runs Kubernetes workloads.
- Hosts microservice deployments.
- Supports rolling updates, service discovery, scaling, probes.

Interview answer:

```text
GKE is the runtime platform. Kubernetes deployments maintain replica count, services provide stable networking, and probes help avoid routing traffic to unhealthy pods.
```

### Artifact Registry

What it does:

- Stores Docker images.
- Replaced legacy `gcr.io` usage.
- Image path pattern:

```text
us-central1-docker.pkg.dev/<project>/ecommerce-docker/<service>:<tag>
```

Interview answer:

```text
I moved image pushes to Artifact Registry because new GCP projects should use Artifact Registry instead of relying on legacy GCR create-on-push behavior. I also ensured Cloud Build has writer permission and GKE nodes have reader permission.
```

### Cloud Build

What it does:

- Builds all service images.
- Tags images with commit SHA and `latest`.
- Pushes images to Artifact Registry.
- Updates Kubernetes manifests with new image tags.

Interview answer:

```text
Cloud Build handles CI. The pipeline builds images in parallel, pushes them to Artifact Registry, and updates manifests so GitOps deployment can occur through ArgoCD.
```

### ArgoCD

What it does:

- Watches Git repo.
- Applies Kubernetes manifests to cluster.
- Detects drift.

Interview answer:

```text
ArgoCD makes Git the source of truth. If someone manually changes the cluster, ArgoCD can detect drift and reconcile it back to the desired state.
```

### Kubernetes Manifests

Includes:

- Deployments.
- Services.
- ConfigMaps.
- HPA.
- Namespace.
- RBAC.
- Network policies.
- Pod security.
- TLS/cert-manager related files.
- OpenTelemetry collector.

Interview answer:

```text
The Kubernetes layer defines how the app runs: replica count, resource requests, ports, probes, service discovery, security posture, and scaling.
```

## End-To-End Deployment Story

Use this as a strong project story:

```text
When a developer pushes code, Cloud Build starts the CI pipeline. It builds Docker images for catalog, cart, payment, API gateway, and frontend. Each image is tagged with the commit SHA for traceability and pushed to Artifact Registry. The pipeline then updates Kubernetes manifests with the new image tag. ArgoCD detects the Git change and syncs the desired state to GKE. Kubernetes performs rolling updates, readiness probes decide when pods receive traffic, and monitoring helps verify the rollout.
```

## Real Issue You Can Mention: GCR To Artifact Registry

Situation:

```text
Cloud Build successfully built Docker images but failed while pushing to gcr.io. The log said the repo did not exist and create-on-push permission was missing.
```

Root cause:

```text
The project was using legacy GCR image paths. Newer GCP setups should use Artifact Registry repositories explicitly. Cloud Build also needed write permission to the repository and nodes needed read permission.
```

Fix:

```text
I changed the registry path to Artifact Registry, added repository creation to build/setup scripts, updated Kubernetes image references, and added IAM bindings for Cloud Build writer and compute node reader access.
```

Interview-ready conclusion:

```text
This taught me that CI/CD failures are often not Docker build problems but registry, IAM, or environment problems. I debugged it by reading the exact Cloud Build push error instead of changing the Dockerfile blindly.
```

## VERDICT Breakdown For This Project

If interviewer asks "deployment failed", answer:

```text
V - Check commit SHA, image tag, manifest update, Terraform/provider changes.
E - Is it local, Cloud Build, GKE dev/prod namespace, or ArgoCD sync?
R - Check pod CPU/memory, node capacity, quota, disk pressure.
D - Check Artifact Registry, Cloud SQL, secrets, downstream services.
I - Check GKE node health, Kubernetes events, ArgoCD health, ingress.
C - Check service DNS, ports, ingress, firewall, private networking.
T - Check Cloud Build logs, kubectl describe/logs, ArgoCD events, Cloud Logging, metrics.
```

## Interview Questions From This Project

### 1. Explain your project architecture.

Answer:

```text
It is a GCP-based ecommerce microservices platform. Frontend talks to API gateway, which routes to catalog, cart, and payment services. Infrastructure is provisioned using Terraform. Services are containerized and deployed to GKE. Cloud Build builds and pushes images to Artifact Registry, and ArgoCD handles GitOps deployment to Kubernetes.
```

### 2. Why did you use Kubernetes?

Answer:

```text
Kubernetes gives service discovery, rolling updates, self-healing, scaling, and consistent deployment for multiple microservices. Since this project has separate frontend, gateway, catalog, cart, and payment services, Kubernetes is a good fit to manage them independently.
```

### 3. Why Terraform?

Answer:

```text
Terraform makes infrastructure reproducible. Instead of manually creating GKE, VPC, and Cloud SQL, the configuration can be reviewed, versioned, and applied consistently. It also helps detect drift.
```

### 4. Why ArgoCD if Cloud Build already deploys?

Answer:

```text
Cloud Build is good for CI: building, testing, and pushing artifacts. ArgoCD is good for CD/GitOps: reconciling cluster state from Git. This separation gives auditability and prevents manual drift.
```

### 5. What is the difference between CI and CD in your project?

Answer:

```text
CI is Cloud Build building and pushing images. CD is ArgoCD syncing Kubernetes manifests to GKE. The Git commit/image tag connects both.
```

### 6. How do you rollback?

Answer:

```text
Because images are tagged with commit SHA, I can rollback by reverting the manifest image tag or using Kubernetes rollout undo if revision history exists. ArgoCD then reconciles the previous desired state.
```

### 7. How do services communicate?

Answer:

```text
Inside Kubernetes, services communicate through Kubernetes Service DNS names. The frontend sends API traffic to the API gateway; the gateway calls catalog, cart, and payment services using internal service URLs.
```

### 8. How did you handle observability?

Answer:

```text
The project includes Prometheus/Grafana style monitoring and OpenTelemetry dependencies. In production I would track golden signals: latency, traffic, errors, saturation, pod restarts, and dependency latency.
```

### 9. How do you secure this project?

Answer:

```text
Use least privilege IAM, Artifact Registry permissions, Kubernetes RBAC, network policies, pod security settings, non-root containers, secrets from Secret Manager through External Secrets, TLS, and image scanning.
```

### 10. What would you improve next?

Answer:

```text
I would add canary deployment, stronger image vulnerability scanning, policy-as-code, SLO alerts, better integration tests, secret rotation, and production-grade database persistence for stateful services.
```

