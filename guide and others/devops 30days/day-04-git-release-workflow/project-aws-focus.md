# Day 04 Project + AWS Focus

## Project Connection

This project uses Git as the control point for deployments. Cloud Build updates manifests, and ArgoCD syncs Git state to the cluster.

## GCP To AWS Mapping

GitOps works the same on AWS:

```text
Git -> CodeBuild/GitHub Actions -> ECR -> manifest update -> ArgoCD -> EKS
```

## Project Question

Why is commit SHA tagging better than only `latest`?

Answer:

```text
Commit SHA tags are traceable and rollback-safe. `latest` is mutable, so we cannot prove which code is running.
```

