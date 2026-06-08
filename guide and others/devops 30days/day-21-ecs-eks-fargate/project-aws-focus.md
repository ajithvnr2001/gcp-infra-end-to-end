# Day 21 Project + AWS Focus

## Project Connection

This project is Kubernetes-ready, so EKS is the most direct AWS mapping. ECS Fargate is a simpler alternative.

## GCP To AWS Mapping

GKE -> EKS.

Cloud Run style simplicity -> ECS Fargate/App Runner.

## Project Question

Would you migrate this project to EKS or ECS?

Answer:

```text
For fastest migration with existing Kubernetes manifests and ArgoCD, I would choose EKS. If the team wants less Kubernetes management and simpler AWS-native operations, I would evaluate ECS Fargate.
```

