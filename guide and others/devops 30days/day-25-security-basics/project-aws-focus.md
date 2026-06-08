# Day 25 Project + AWS Focus

## Project Connection

Security areas in this project:

- IAM for build/pull.
- Kubernetes RBAC.
- Network policies.
- Pod security.
- Secret management.
- TLS/cert-manager.
- Image scanning.

## GCP To AWS Mapping

GCP IAM -> AWS IAM.

NetworkPolicy remains Kubernetes-level.

Secret Manager -> Secrets Manager.

Artifact Analysis/Trivy -> ECR scanning/Trivy/Snyk.

## Project Question

How would you secure the AWS version?

Answer:

```text
Use private subnets, least privilege IAM roles, security groups with minimum ports, Secrets Manager, ECR image scanning, CloudTrail audit, CloudWatch alerts, Kubernetes RBAC/network policies if EKS, and TLS at ALB.
```

