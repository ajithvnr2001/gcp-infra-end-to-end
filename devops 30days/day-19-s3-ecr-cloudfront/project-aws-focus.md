# Day 19 Project + AWS Focus

## Project Connection

Artifact Registry is central to this project because all service images are pushed and pulled from it.

## GCP To AWS Mapping

Artifact Registry maps to ECR.

Static frontend alternative:

```text
GCS + Cloud CDN -> S3 + CloudFront
```

## Project Question

How would image push work in AWS?

Answer:

```text
CodeBuild authenticates to ECR, builds Docker images, tags with commit SHA, pushes to ECR, and EKS/ECS pulls images using IAM permissions.
```

