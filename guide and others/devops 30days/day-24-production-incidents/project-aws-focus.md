# Day 24 Project + AWS Focus

## Project Connection

Use the Artifact Registry push failure as a real incident/debugging story.

## GCP To AWS Mapping

GCP failure:

```text
Cloud Build could not push to Artifact Registry/GCR.
```

AWS equivalent:

```text
CodeBuild cannot push to ECR due to repository missing or IAM permission denied.
```

## Project Question

How do you tell this as an incident story?

Answer:

```text
Build succeeded, push failed, so I isolated the failure to registry/IAM instead of Dockerfile. I read the exact log, found the legacy GCR create-on-push issue, moved to Artifact Registry, created the repo explicitly, and added writer/reader IAM permissions.
```

