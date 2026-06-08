# Day 15 Project + AWS Focus

## Project Connection

The project needs identities for:

- Cloud Build pushing images.
- GKE nodes pulling images.
- Workloads accessing cloud services.

## GCP To AWS Mapping

Cloud Build service account writer -> CodeBuild role with ECR push.

GKE node reader -> EKS node role or ECS execution role with ECR pull.

Workload Identity -> IAM Roles for Service Accounts / ECS task role.

## Project Question

What are AWS task role and execution role?

Answer:

```text
Execution role lets ECS pull ECR images, read secrets, and write logs. Task role is the application identity used to call AWS APIs.
```

