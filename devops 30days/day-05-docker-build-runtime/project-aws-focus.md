# Day 05 Project + AWS Focus

## Project Connection

Each service has a Dockerfile. Cloud Build builds images for catalog, cart, payment, API gateway, and frontend.

## GCP To AWS Mapping

Artifact Registry maps to ECR. Cloud Build maps to CodeBuild.

## Project Question

Cloud Build succeeds at Docker build but fails at push. Is Dockerfile the first suspect?

Answer:

```text
No. If build succeeds and push fails, the likely layer is registry path, repository existence, authentication, IAM permission, or network access to registry.
```

