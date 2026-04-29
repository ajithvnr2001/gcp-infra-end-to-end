# Resume And Interview Stories

Use these to position yourself for DevOps/Cloud Engineer roles.

## 30-Second Introduction

```text
I am a cloud and DevOps-focused engineer with hands-on experience in GCP, containers, Kubernetes, Terraform, CI/CD, and automation. My strongest area is debugging and building reliable deployment workflows. I am GCP-native, and I am actively mapping that knowledge to AWS services like IAM, VPC, EC2, EKS/ECS, RDS, S3, CloudWatch, and ECR.
```

## Project Story - Ecommerce Platform

```text
I worked on an ecommerce microservices platform with services for catalog, cart, payment, API gateway, and frontend. The platform used Docker images, Kubernetes manifests, Terraform infrastructure, Cloud Build CI/CD, GitOps-style deployment, and monitoring.

My responsibilities were around cloud infrastructure, deployment automation, Kubernetes configuration, registry/image workflow, and troubleshooting production-style issues.
```

## Strong Incident Story - Registry Push Failure

Situation:

```text
Cloud Build could build Docker images but failed while pushing images to gcr.io. The log showed: repo does not exist and create-on-push permission was missing.
```

Action:

```text
I treated it as a registry/IAM issue. Using VERDICT:
V - registry path used legacy gcr.io.
E - failure occurred in Cloud Build.
R - build succeeded, push failed.
D - dependency was container registry / artifact registry.
I - Cloud Build service account needed permissions.
C - registry endpoint and image path were wrong for a fresh project.
T - Cloud Build logs gave the exact denied message.
```

Fix:

```text
I moved image pushes to Artifact Registry, created the Docker repository explicitly, updated Kubernetes image references, and added IAM permissions for Cloud Build to push and GKE nodes to pull.
```

Result:

```text
The build became compatible with fresh GCP projects and avoided implicit legacy GCR repository creation.
```

Prevention:

```text
Add registry creation and IAM setup as part of setup/build scripts. Use immutable image tags for traceability.
```

## Resume Bullets

Use or adapt:

- Built and maintained containerized microservices deployment workflow using Docker, Kubernetes, and Cloud Build.
- Automated cloud infrastructure provisioning with Terraform for GKE, networking, and managed database components.
- Implemented production-style Kubernetes manifests with resource requests, probes, service discovery, and rolling deployment strategy.
- Debugged CI/CD image push failures by migrating legacy GCR references to Artifact Registry and correcting IAM push/pull permissions.
- Designed cloud troubleshooting workflow using logs, metrics, Kubernetes events, and deployment history.
- Practiced AWS service mapping from GCP-native experience across IAM, VPC, EC2, EKS/ECS, RDS, S3, ECR, and CloudWatch.

## Interview Story Format

Use this for every project answer:

```text
Context:
Problem:
My role:
Actions:
Tools:
Result:
What I improved after:
```

## 5 Strong Closing Lines

```text
I debug by isolating the failing layer first, then validating through logs and metrics.
```

```text
I prefer automation that is idempotent, observable, and safe to rerun.
```

```text
I treat Terraform plan and CI/CD logs as review artifacts, not just command output.
```

```text
My GCP experience helps me learn AWS quickly because the core cloud patterns are the same.
```

```text
For production issues, my priority is impact reduction first, root cause second, prevention third.
```

