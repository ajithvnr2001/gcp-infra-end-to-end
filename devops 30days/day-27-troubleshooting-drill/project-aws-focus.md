# Day 27 Project + AWS Focus

## Project Connection

Practice these project failures:

- Cloud Build push denied.
- Pod ImagePullBackOff.
- Frontend cannot reach API gateway.
- API gateway cannot reach payment service.
- ArgoCD OutOfSync.
- Terraform unexpected destroy.

## GCP To AWS Mapping

Same failures in AWS:

- CodeBuild ECR push denied.
- EKS/ECS image pull denied.
- ALB target unhealthy.
- ECS service discovery issue.
- ArgoCD EKS sync error.
- Terraform AWS plan unexpected destroy.

## Project Question

What is your universal troubleshooting framework?

Answer:

```text
I use VERDICT: version, environment, resources, dependencies, infra health, connectivity, telemetry. It keeps me from guessing.
```

