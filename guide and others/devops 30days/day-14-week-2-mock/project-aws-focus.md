# Day 14 Project + AWS Focus

## Project Connection

You should now explain the full GCP flow:

```text
Terraform -> GKE/Cloud SQL/VPC
Cloud Build -> Artifact Registry
ArgoCD -> Kubernetes sync
Monitoring/security -> production readiness
```

## GCP To AWS Mapping

Equivalent AWS flow:

```text
Terraform -> EKS/RDS/VPC
CodeBuild -> ECR
ArgoCD -> EKS sync
CloudWatch/CloudTrail -> observability/audit
```

## Project Question

Give the strongest 60-second project answer.

Answer:

```text
This is a GCP ecommerce microservices platform using Docker, GKE, Terraform, Cloud Build, Artifact Registry, ArgoCD, and Kubernetes manifests. It helped me practice real DevOps work: provisioning infrastructure, building images, deploying through GitOps, debugging CI/CD, and preparing production observability/security.
```

