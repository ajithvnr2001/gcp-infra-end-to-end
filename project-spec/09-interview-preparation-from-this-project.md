# 09 - Interview Preparation Using This Project Alone

This project is enough to prepare for many DevOps/Cloud Engineer interviews if you explain it properly.

## Your Core Story

```text
I worked on a GCP ecommerce microservices platform with frontend, API gateway, catalog, cart, and payment services. I containerized the services, deployed them on GKE using Kubernetes manifests, provisioned infrastructure with Terraform, built images using Cloud Build, stored images in Artifact Registry, and used ArgoCD for GitOps deployment. I also practiced monitoring, HPA, security policies, and production troubleshooting.
```

## What This Project Proves

| Skill | Proof In Project |
|---|---|
| Linux | Containers and runtime debugging |
| Docker | Dockerfiles for services |
| Python | FastAPI backend services |
| CI/CD | Cloud Build pipeline |
| Registry | Artifact Registry image workflow |
| Kubernetes | Deployments, Services, HPA, probes |
| GitOps | ArgoCD app |
| Terraform | VPC, GKE, Cloud SQL modules |
| Monitoring | Prometheus/Grafana guide |
| Logging | Structured logs |
| Tracing | OpenTelemetry collector |
| Security | RBAC, NetworkPolicy, Pod Security, TLS, secrets |
| Incident handling | Registry push failure debug |
| AWS readiness | GCP-to-AWS mapping |

## 10 Must-Know Project Questions

### 1. Explain the project architecture.

Answer:

```text
Browser talks to frontend. Frontend API calls go to API gateway. API gateway routes requests to catalog, cart, and payment services. Services run as containers on GKE. Terraform provisions infrastructure. Cloud Build builds images and pushes to Artifact Registry. ArgoCD syncs Kubernetes manifests from Git.
```

### 2. Why API gateway?

Answer:

```text
It centralizes frontend access and hides internal service topology. It routes to catalog, cart, and payment services and can later handle auth, rate limiting, tracing, and request validation.
```

### 3. Why Kubernetes/GKE?

Answer:

```text
The app has multiple independently deployable services. Kubernetes provides service discovery, self-healing, rolling updates, resource management, readiness/liveness probes, and autoscaling.
```

### 4. Why Terraform?

Answer:

```text
Terraform makes infrastructure repeatable and version-controlled. It avoids manual console drift and lets me review the plan before applying changes.
```

### 5. Why ArgoCD?

Answer:

```text
ArgoCD makes Git the source of truth. It continuously compares live cluster state with Git and can self-heal drift.
```

### 6. How does CI/CD work?

Answer:

```text
Cloud Build builds Docker images for all services, tags them with commit SHA and latest, pushes them to Artifact Registry, updates Kubernetes manifests, and pushes changes to Git. ArgoCD then deploys the new desired state.
```

### 7. How do you monitor it?

Answer:

```text
I monitor golden signals: latency, traffic, errors, and saturation. Prometheus stores metrics, Grafana visualizes them, Kubernetes metrics show pod health, and logs/traces help root cause issues.
```

### 8. What was a real issue you fixed?

Answer:

```text
Cloud Build built images successfully but failed to push to gcr.io because the repo did not exist and create-on-push permission was missing. I moved to Artifact Registry, explicitly created the repo, updated image paths, and configured IAM permissions.
```

### 9. What are current limitations?

Answer:

```text
Cart and payment currently use in-memory state. In production I would use Redis for cart and Cloud SQL for orders/payment records. I would also add canary deployments, stronger integration tests, secret rotation, and image scanning.
```

### 10. How would you map this to AWS?

Answer:

```text
GKE maps to EKS or ECS, Artifact Registry to ECR, Cloud Build to CodeBuild/CodePipeline, Cloud SQL to RDS, GCP Load Balancer to ALB, Cloud Monitoring to CloudWatch, Cloud Audit Logs to CloudTrail, and Secret Manager to AWS Secrets Manager.
```

## Project-Based Scenario Questions

### Scenario: Frontend works but products do not load.

Answer:

```text
I trace frontend -> API gateway -> catalog. I check browser network, frontend logs, API gateway logs, catalog logs, service endpoints, and readiness. Most likely causes are gateway upstream failure, catalog pod issue, service DNS/port mismatch, or frontend API path problem.
```

### Scenario: Payment latency is high.

Answer:

```text
I check payment service metrics, CPU/memory, pod restarts, API gateway upstream latency, order payload size, logs, and dependency health. Since payment is critical, I would check SLO burn rate and consider rollback if latency started after deployment.
```

### Scenario: ArgoCD is OutOfSync.

Answer:

```text
I check ArgoCD diff to see what differs between Git and cluster. If it is manual drift, self-heal can fix it. If sync fails, I check invalid manifests, missing CRDs, RBAC, namespace, or resource conflicts.
```

### Scenario: New deployment causes CrashLoopBackOff.

Answer:

```text
I check rollout history, pod describe, previous logs, environment variables, image tag, config maps, and dependency readiness. If production is impacted, I rollback to previous image tag and then debug root cause.
```

## How To Sound Confident

Use this structure:

```text
Context -> My role -> Tools -> Flow -> Issue handled -> Improvement
```

Example:

```text
The project is a GCP ecommerce microservices platform. My DevOps focus was infrastructure, containerization, CI/CD, Kubernetes deployment, GitOps, and troubleshooting. I used Terraform, GKE, Cloud Build, Artifact Registry, ArgoCD, and monitoring tools. One real issue I handled was registry push failure, which I fixed by migrating from legacy GCR paths to Artifact Registry and correcting IAM permissions.
```

