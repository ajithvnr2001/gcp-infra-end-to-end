# 01 - Project Overview

## What This Project Is

This project is a production-style ecommerce platform built for DevOps/cloud learning and interviews.

It contains:

- Frontend storefront.
- API gateway.
- Catalog service.
- Cart service.
- Payment/order service.
- Dockerfiles for services.
- Local Docker Compose stack.
- Kubernetes manifests.
- Terraform infrastructure.
- Cloud Build CI/CD.
- Artifact Registry image workflow.
- ArgoCD GitOps deployment.
- Monitoring with Prometheus/Grafana concepts.
- Security manifests for RBAC, network policy, pod security, TLS, and secret management.

## Business Flow

```text
User opens storefront
  -> Frontend loads product list
  -> User adds item to cart
  -> API gateway forwards cart request to cart service
  -> User checks out
  -> API gateway sends order to payment service
  -> API gateway clears cart after successful order
  -> Frontend shows order history
```

## Technical Flow

```text
Browser
  -> frontend-service
  -> api-gateway
      -> catalog-service
      -> cart-service
      -> payment-service
```

## DevOps Flow

```text
Developer pushes code
  -> Cloud Build starts
  -> Docker images are built
  -> Images are pushed to Artifact Registry
  -> Kubernetes image tags are updated
  -> Git changes are pushed
  -> ArgoCD detects Git change
  -> ArgoCD syncs manifests to GKE
  -> Kubernetes performs rollout
  -> Monitoring verifies health
```

## Infrastructure Flow

```text
Terraform
  -> VPC module
  -> GKE module
  -> Cloud SQL module
  -> GCS remote state backend
```

## Main Technologies

| Area | Tool/Service |
|---|---|
| Cloud | GCP |
| Compute orchestration | GKE / Kubernetes |
| Infrastructure as Code | Terraform |
| CI/CD | Cloud Build |
| Container registry | Artifact Registry |
| GitOps | ArgoCD |
| Frontend serving | NGINX |
| Backend framework | Python FastAPI |
| Local dev | Docker Compose |
| Metrics | Prometheus |
| Dashboards | Grafana |
| Tracing | OpenTelemetry / Collector |
| Logs | stdout JSON logs / GCP Cloud Logging pattern |

## How To Explain In Interviews

Short answer:

```text
This project is an ecommerce microservices platform deployed on GCP. I used Docker for packaging, GKE for orchestration, Terraform for infrastructure, Cloud Build for CI, Artifact Registry for images, ArgoCD for GitOps deployment, and Prometheus/Grafana for monitoring.
```

Detailed answer:

```text
The application has frontend, API gateway, catalog, cart, and payment services. The frontend talks to the API gateway. The gateway routes requests to internal services. Each service is containerized and deployed on Kubernetes. Terraform provisions the cloud infrastructure. Cloud Build builds and pushes images to Artifact Registry. ArgoCD watches Git and syncs the Kubernetes manifests to GKE. The project also includes observability, HPA, security policies, and local Docker Compose for development.
```

