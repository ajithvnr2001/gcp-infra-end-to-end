# Final One-Page Interview Sheet

Read this 30 minutes before interview.

## My Positioning

```text
I am a GCP-native DevOps/Cloud Engineer candidate with hands-on project experience in Docker, Kubernetes, Terraform, Cloud Build, Artifact Registry, ArgoCD, Linux, scripting, and production-style troubleshooting. I can map this architecture to AWS using EKS/ECS, ECR, RDS, ALB, CloudWatch, CloudTrail, IAM roles, and VPC networking.
```

## Project In 30 Seconds

```text
My project is an ecommerce microservices platform on GCP. It has frontend, API gateway, catalog, cart, and payment services. I containerized them with Docker, deployed them to GKE using Kubernetes manifests, provisioned infrastructure with Terraform, built images using Cloud Build, stored them in Artifact Registry, and used ArgoCD for GitOps deployment.
```

## AWS Mapping In 30 Seconds

```text
The AWS version would use EKS or ECS for containers, ECR for images, CodeBuild/CodePipeline for CI/CD, RDS for database, ALB for ingress, Route 53 for DNS, CloudWatch for logs/metrics, CloudTrail for audit, Secrets Manager for secrets, and IAM roles for secure access.
```

## My Best Incident Story

```text
Cloud Build built images successfully but failed while pushing to gcr.io. I checked the logs and isolated it to registry/IAM, not Docker. I moved the workflow to Artifact Registry, created the repo explicitly, updated image paths, and configured Cloud Build writer plus node reader permissions. This showed structured troubleshooting across CI/CD, registry, and IAM.
```

## VERDICT

```text
V - Version/change
E - Environment
R - Resources
D - Dependencies
I - Infra health
C - Connectivity
T - Telemetry
```

## Strong Openers

```text
I will first isolate the failing layer.
I will verify with logs and metrics before changing anything.
Because this is production, I will reduce impact first, then debug root cause.
My project is GCP-native, and I map the same architecture to AWS this way.
```

## Must-Mention Commands

```bash
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous
kubectl get events -n <ns> --sort-by=.lastTimestamp
terraform plan
docker logs <container>
aws sts get-caller-identity
aws elbv2 describe-target-health --target-group-arn <arn>
aws cloudtrail lookup-events
```

## Do Not Say

```text
I only know GCP.
I will just restart.
I will check everything.
I don't know.
```

## Say Instead

```text
I implemented it in GCP, and I can map the same design to AWS.
Restart may restore service, but I would capture logs and identify root cause.
I would narrow it by checking identity, network, resources, dependencies, infra health, connectivity, and telemetry.
I have not used that exact service deeply, but I know how I would troubleshoot it.
```

