# Resume Bullets - DevOps / Cloud Engineer

Use these as a base. Adjust numbers only if they are true.

## Profile Summary

```text
DevOps and Cloud Engineer with hands-on experience in GCP, Kubernetes, Docker, Terraform, CI/CD, Linux, scripting, and production-style troubleshooting. Built an ecommerce microservices platform using GKE, Cloud Build, Artifact Registry, ArgoCD, Terraform, Kubernetes manifests, and observability components. Strong ability to map GCP architectures to AWS services including EKS/ECS, ECR, RDS, ALB, CloudWatch, CloudTrail, IAM, and VPC networking.
```

## Strong Resume Bullets

- Built a production-style ecommerce microservices platform using Docker, Kubernetes, GKE, Terraform, Cloud Build, Artifact Registry, and ArgoCD.
- Containerized frontend, API gateway, catalog, cart, and payment services with service-specific Dockerfiles and Kubernetes deployments.
- Implemented CI/CD workflow using Cloud Build to build images in parallel, tag images with commit SHA, push to Artifact Registry, and update Kubernetes manifests.
- Migrated image workflow from legacy GCR paths to Artifact Registry and resolved Cloud Build push failures by creating repositories explicitly and configuring IAM permissions.
- Designed Kubernetes manifests for Deployments, Services, ConfigMaps, HPA, readiness/liveness probes, RBAC, pod security, and network policies.
- Used Terraform modules to provision GCP infrastructure including VPC, GKE, and Cloud SQL components with reproducible infrastructure-as-code workflow.
- Practiced GitOps deployment model using ArgoCD to reconcile Kubernetes desired state from Git and detect configuration drift.
- Added production-style observability concepts using health endpoints, Prometheus/Grafana monitoring, and OpenTelemetry-oriented service dependencies.
- Improved deployment reliability using immutable image tags, rolling updates, readiness probes, resource requests, and rollback-ready manifests.
- Created AWS architecture mapping for the GCP platform using EKS/ECS, ECR, RDS, ALB, Route 53, CloudWatch, CloudTrail, IAM roles, NAT Gateway, and security groups.

## Project Bullet - Short Version

```text
Built and debugged a GCP-based ecommerce DevOps platform with Terraform, GKE, Cloud Build, Artifact Registry, ArgoCD, Kubernetes manifests, Dockerized microservices, and observability/security hardening.
```

## Project Bullet - AWS Mapping Version

```text
Mapped GCP-native platform architecture to AWS equivalents including EKS/ECS, ECR, CodeBuild/CodePipeline, RDS, ALB, Route 53, CloudWatch, CloudTrail, IAM roles, and VPC public/private subnet design.
```

## Incident Bullet

```text
Resolved CI/CD image push failure by identifying legacy GCR create-on-push permission issue, migrating image references to Artifact Registry, and adding Cloud Build writer plus GKE node reader IAM permissions.
```

## Automation Bullet

```text
Developed repeatable build/setup automation scripts for cloud project setup, API enablement, Artifact Registry repository creation, IAM configuration, image builds, and deployment verification.
```

## Interview "Tell Me About Your Project" Answer

```text
My main project is a GCP ecommerce microservices platform. It has frontend, API gateway, catalog, cart, and payment services. I containerized the services, deployed them to GKE using Kubernetes manifests, provisioned infrastructure with Terraform, built images through Cloud Build, stored them in Artifact Registry, and used ArgoCD for GitOps-style deployment. I also worked through real CI/CD troubleshooting, including fixing a registry push failure by moving from legacy GCR paths to Artifact Registry and correcting IAM permissions. I can map the same architecture to AWS using EKS or ECS, ECR, RDS, ALB, CloudWatch, CloudTrail, and IAM roles.
```

