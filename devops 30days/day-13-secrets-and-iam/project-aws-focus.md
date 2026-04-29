# Day 13 Project + AWS Focus

## Project Connection

Secrets should not be committed to Git. This project includes secret-management related Kubernetes files and should use GCP Secret Manager in production.

## GCP To AWS Mapping

GCP Secret Manager maps to AWS Secrets Manager or SSM Parameter Store.

## Project Question

How would you avoid static keys?

Answer:

```text
In GCP I would use Workload Identity/service accounts. In AWS EKS I would use IAM Roles for Service Accounts or Pod Identity. In ECS I would use task roles.
```

