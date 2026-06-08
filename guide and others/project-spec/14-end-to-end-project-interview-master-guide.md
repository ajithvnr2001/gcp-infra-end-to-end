# End-To-End Project Interview Master Guide

This guide explains the full ecommerce DevOps/cloud project end to end. Use it when you want to prepare for DevOps Engineer, Cloud Engineer, Platform Engineer, or SRE interviews using this project alone.

The goal is not to memorize files. The goal is to explain the system clearly:

```text
I built a production-style ecommerce microservices platform on GCP using Terraform, GKE, Docker, Cloud Build, Artifact Registry, ArgoCD GitOps, Kubernetes manifests, ingress, autoscaling, Prometheus, Grafana, tracing, security controls, and operational runbooks. I can also map the same architecture to AWS using EKS, ECR, CodeBuild, VPC, RDS, CloudWatch, and Route 53.
```

## 1. Full Project Story

This project simulates how a real ecommerce application is built, deployed, monitored, secured, and operated on cloud infrastructure.

High-level flow:

```text
Developer writes code
        |
        v
Git repository
        |
        v
Cloud Build builds Docker images
        |
        v
Artifact Registry stores images
        |
        v
Kubernetes YAML defines desired runtime state
        |
        v
ArgoCD syncs manifests to GKE
        |
        v
GKE runs frontend and backend microservices
        |
        v
Ingress exposes frontend/API traffic
        |
        v
Prometheus, Grafana, logs, events, and tracing support operations
```

Core services:

- `frontend`: browser UI served through NGINX
- `api-gateway`: API entry point for backend calls
- `catalog-service`: product service and strongest metrics example
- `cart-service`: cart management service
- `payment-service`: order/payment simulation service

Infrastructure and platform components:

- Terraform for cloud infrastructure
- GKE for Kubernetes
- Artifact Registry for container images
- Cloud Build for CI image builds
- ArgoCD for GitOps deployment
- ingress-nginx for traffic entry
- Prometheus and Grafana for metrics
- OpenTelemetry collector for tracing foundation
- Kubernetes security controls for RBAC, network policy, pod security, TLS, and secrets patterns

## 2. Folder-To-Concept Map

| Folder/File | What It Means | Interview Angle |
|---|---|---|
| `services/` | Application source code | Microservices, APIs, Dockerization, health checks |
| `services/*/Dockerfile` | Container build instructions | Image layers, runtime, ports, production images |
| `k8s/` | Kubernetes desired state | Deployments, Services, HPA, ingress, security, monitoring |
| `argocd/apps.yaml` | GitOps application definition | ArgoCD watches Git and syncs to cluster |
| `terraform/` | Cloud infrastructure as code | VPC, GKE, Cloud SQL, backend state |
| `cloudbuild.yaml` | CI build pipeline | Build, tag, push, deploy manifest workflow |
| `scripts/` | Automation helpers | Setup, build, rebuild, operational commands |
| `monitoring/` | Observability assets | Dashboards, metrics, alerts concepts |
| `disaster-recovery/` | DR planning | Backup, restore, failure recovery story |
| `cost/` | Cost optimization | Right-sizing, autoscaling, cleanup, FinOps |
| `aws/` | AWS mapping material | GCP-native to AWS transition |
| `project-spec/` | Interview and operations guides | Read this before interviews |
| `devops 30days/` | 30-day learning plan | Daily learning and interview drills |

## 3. Architecture In Simple Words

The user accesses the frontend through ingress. The frontend calls the API Gateway. The API Gateway routes requests to catalog, cart, and payment services using Kubernetes service names. Each backend service runs as a Deployment behind a ClusterIP Service. Kubernetes probes check health and readiness. HPA can scale workloads based on resource metrics. Prometheus scrapes metrics and Grafana visualizes them. ArgoCD keeps the cluster matching Git.

Request path:

```text
Browser
  -> Ingress Controller
  -> frontend Service
  -> frontend Pod
  -> API Gateway Service
  -> api-gateway Pod
  -> catalog/cart/payment Service
  -> backend Pod
```

Interview version:

```text
The architecture uses Kubernetes-native service discovery. The frontend and API gateway do not need Pod IPs. They call stable Service DNS names. Deployments manage Pods, Services provide stable networking, Ingress handles external routing, and ArgoCD ensures the live cluster follows Git.
```

## 4. CI/CD And GitOps Flow

This project separates build and deploy responsibilities.

CI responsibility:

- Run tests
- Build Docker images
- Push images to Artifact Registry
- Update or validate manifests

CD/GitOps responsibility:

- Watch Git
- Compare desired state with live cluster
- Sync manifests to GKE
- Self-heal drift
- Prune deleted resources

Cloud Build handles image creation. ArgoCD handles Kubernetes deployment.

Why this is good:

- Build pipeline does not need broad cluster mutation for every deployment step
- Git becomes the audit trail
- ArgoCD provides deployment visibility
- Manual cluster drift can be detected and corrected

Interview answer:

```text
I separated CI and CD. Cloud Build builds and pushes images. ArgoCD deploys manifests from Git. This gives traceability, rollback through Git history, and better control over cluster state.
```

## 5. Terraform Infrastructure Layer

Terraform is used to provision cloud infrastructure.

Expected infrastructure responsibilities:

- VPC and subnet design
- GKE cluster
- Node pools
- Cloud SQL module
- Remote state backend
- Outputs for cluster and network information

Folders:

- `terraform/envs/prod`: production environment composition
- `terraform/modules/vpc`: reusable network module
- `terraform/modules/gke`: reusable Kubernetes module
- `terraform/modules/cloudsql`: reusable database module

How to explain:

```text
I structured Terraform with environment folders and reusable modules. The prod environment composes VPC, GKE, and Cloud SQL modules. This keeps infrastructure repeatable, reviewable, and easier to extend for staging or production.
```

GCP to AWS mapping:

| GCP | AWS | Purpose |
|---|---|---|
| VPC | VPC | Private network boundary |
| Subnet | Subnet | IP range per zone/region |
| GKE | EKS | Managed Kubernetes |
| Cloud SQL | RDS | Managed relational database |
| GCS backend | S3 backend + DynamoDB lock | Terraform remote state |
| Cloud NAT | NAT Gateway | Private outbound internet |
| Firewall rules | Security Groups / NACLs | Network access control |

Interview question:

```text
Why use Terraform instead of creating resources manually?
```

Strong answer:

```text
Terraform gives repeatability, version control, reviewability, and drift detection for infrastructure. Manual setup is hard to audit and reproduce. With Terraform, I can recreate the same VPC, GKE cluster, and database configuration consistently across environments.
```

## 6. Kubernetes Runtime Layer

Kubernetes is the runtime platform.

Important objects:

- Namespace: isolates project resources
- Deployment: manages Pods and rolling updates
- Service: stable networking inside the cluster
- Ingress: external HTTP/HTTPS entry point
- HPA: autoscaling
- ConfigMap: non-secret configuration
- Secret: sensitive configuration pattern
- NetworkPolicy: traffic control
- RBAC: access control
- Pod security settings: runtime hardening

How to read Kubernetes in this repo:

```text
k8s/namespaces -> where resources live
k8s/deployments -> what workloads run
k8s/services -> how workloads talk
k8s/ingress -> how users enter
k8s/hpa -> how workloads scale
k8s/security -> how access and traffic are restricted
k8s/tracing -> how telemetry is collected
```

Interview answer:

```text
Kubernetes gives me a consistent deployment platform. Deployments handle rollout and replica management, Services provide stable networking, Ingress exposes traffic, HPA handles scaling, and probes improve reliability by only sending traffic to ready Pods.
```

## 7. Service-To-Service Communication

The API Gateway calls backend services through Kubernetes DNS.

Pattern:

```text
http://catalog-service:8000
http://cart-service:8001
http://payment-service:8002
```

Why this matters:

- Pod IPs are temporary
- Service names are stable
- Kubernetes load-balances across ready Pods
- Readiness probes prevent traffic to unready Pods

Interview answer:

```text
I avoid hardcoding Pod IPs. Services provide stable DNS and load balancing. If a Pod restarts or scales, traffic still goes through the Service to healthy endpoints.
```

## 8. Health, Readiness, And Metrics

Health endpoint:

```text
/health
```

Used to check whether the application process is alive.

Readiness endpoint:

```text
/ready
```

Used to check whether the application is ready to receive traffic.

Metrics endpoint:

```text
/metrics
```

Used by Prometheus scraping.

Important project observation:

```text
catalog-service exposes Prometheus metrics properly. cart-service and payment-service expose health/readiness but do not expose full /metrics in the same way. If Prometheus tries to scrape them, they may show as down targets. This is a real improvement point and a strong interview discussion.
```

Interview answer:

```text
Liveness tells Kubernetes whether to restart a container. Readiness tells Kubernetes whether to send traffic to it. Metrics give operational visibility. In this project, catalog has stronger metrics support, and I would improve cart and payment by adding /metrics consistently.
```

## 9. Observability Layer

Observability means understanding system behavior from outside the application.

This project includes:

- Prometheus for metrics
- Grafana for dashboards
- Kubernetes events for cluster lifecycle issues
- Application logs for runtime debugging
- OpenTelemetry collector foundation for tracing

Local URLs from `log.txt`:

```text
Grafana: http://localhost:3000
Prometheus: http://localhost:9090
ArgoCD: https://localhost:8080
Frontend: https://localhost/
```

What to check in Prometheus:

```promql
up
up{job="ecommerce-services"}
container_cpu_usage_seconds_total
container_memory_working_set_bytes
kube_pod_status_phase
kube_deployment_status_replicas_available
```

What to check in Grafana:

- Kubernetes cluster dashboard
- Namespace dashboard
- Pod dashboard
- Workload dashboard
- Node exporter dashboard
- Prometheus overview

Interview answer:

```text
I use ArgoCD for deployment state, Kubernetes events for scheduling and lifecycle issues, logs for application errors, Prometheus for metrics, and Grafana for dashboards. Together they help me move from symptom to root cause.
```

## 10. Security Layer

Security controls in this project are represented under `k8s/security`.

Main areas:

- RBAC: controls who can do what in Kubernetes
- NetworkPolicy: controls allowed network traffic
- Pod security: reduces container runtime risk
- TLS: secures ingress traffic
- Secrets management: handles sensitive values

Good production practices:

- Do not store real secrets in Git
- Use Secret Manager, External Secrets, Sealed Secrets, or SOPS
- Disable default ArgoCD admin after setup
- Use SSO and RBAC for ArgoCD
- Use least privilege for service accounts
- Restrict container privileges
- Scan images in CI
- Sign images where possible
- Use NetworkPolicies to reduce lateral movement

GCP to AWS mapping:

| GCP Security Concept | AWS Equivalent |
|---|---|
| IAM service account | IAM role |
| Workload Identity | IRSA / EKS Pod Identity |
| Secret Manager | AWS Secrets Manager / SSM Parameter Store |
| Artifact Registry scanning | ECR image scanning |
| Cloud Armor | AWS WAF |
| GKE Network Policy | EKS Network Policy with compatible CNI |

Interview answer:

```text
I apply defense in depth. IAM controls cloud access, RBAC controls Kubernetes API access, NetworkPolicies limit pod-to-pod traffic, pod security settings reduce runtime risk, and secrets should be managed outside plain Git.
```

## 11. Scaling And Reliability

Scaling mechanisms:

- Deployment replicas
- Horizontal Pod Autoscaler
- Kubernetes Service load balancing
- GKE node pool scaling if configured

Reliability mechanisms:

- Health probes
- Readiness probes
- Rolling updates
- Resource requests and limits
- ArgoCD self-heal
- Monitoring and alerting
- Disaster recovery planning

Important ArgoCD/HPA point:

```text
ArgoCD ignores Deployment replica drift because HPA may change replicas dynamically. This prevents ArgoCD from fighting autoscaling.
```

Interview answer:

```text
For reliability, I use readiness probes so traffic only reaches ready Pods, rolling updates to avoid downtime, HPA for scaling, resource limits to protect nodes, and ArgoCD self-heal to correct manual drift.
```

## 12. Disaster Recovery And Backup Story

A strong interview answer should include recovery thinking.

What can fail:

- Cluster deleted or corrupted
- Bad deployment released
- Database unavailable
- Image missing
- GitOps app misconfigured
- Ingress or DNS broken
- Monitoring unavailable

Recovery approach:

- Recreate infrastructure with Terraform
- Restore database from backup
- Reinstall ArgoCD and point to Git
- ArgoCD resyncs Kubernetes manifests
- Validate ingress, services, health, metrics
- Roll back bad Git commits if needed

Interview answer:

```text
My recovery strategy is Git plus Terraform plus backups. Terraform recreates cloud infrastructure, Git stores Kubernetes desired state, ArgoCD resyncs workloads, and database backups restore stateful data.
```

## 13. Testing Strategy

Testing levels:

- Unit tests for service logic
- Docker build validation
- Container startup validation
- Kubernetes manifest validation
- Health endpoint tests
- API endpoint tests
- Smoke tests after deployment
- Monitoring target checks

Useful smoke tests:

```powershell
curl http://localhost:8080/health
curl http://localhost:8080/ready
curl http://localhost:8080/products
curl http://localhost:9090/api/v1/targets
```

Cluster checks:

```powershell
kubectl get pods -n ecommerce
kubectl get svc -n ecommerce
kubectl get ingress -n ecommerce
kubectl get hpa -n ecommerce
kubectl get events -n ecommerce --sort-by=.lastTimestamp
```

Interview answer:

```text
I test at multiple layers: service tests before image build, Docker build validation, Kubernetes health checks after deployment, endpoint smoke tests, and Prometheus target checks for operational readiness.
```

## 14. Common Failure Scenarios

### Scenario 1: ImagePullBackOff

Likely causes:

- Wrong image path
- Image tag does not exist
- Artifact Registry permission missing
- Cloud Build did not push image

Check:

```powershell
kubectl describe pod <pod> -n ecommerce
kubectl get events -n ecommerce --sort-by=.lastTimestamp
```

AWS mapping:

```text
In AWS EKS, this usually maps to ECR image path or node IAM role/ECR permission issues.
```

### Scenario 2: CrashLoopBackOff

Likely causes:

- Bad environment variable
- Missing config/secret
- Application bug
- Wrong command
- Dependency unavailable

Check:

```powershell
kubectl logs <pod> -n ecommerce
kubectl describe pod <pod> -n ecommerce
```

### Scenario 3: Service Unreachable

Likely causes:

- Service selector mismatch
- Pod not ready
- Wrong service port
- NetworkPolicy blocking traffic
- API Gateway config wrong

Check:

```powershell
kubectl get endpoints -n ecommerce
kubectl describe svc <service> -n ecommerce
```

### Scenario 4: ArgoCD OutOfSync

Likely causes:

- Git changed but not synced
- Manual cluster drift
- Generated field changed
- Resource deleted manually

Check:

```text
ArgoCD UI -> ecommerce-catalog -> Diff
```

### Scenario 5: Prometheus Target Down

Likely causes:

- App does not expose `/metrics`
- Wrong scrape annotation
- Wrong port
- ServiceMonitor mismatch
- Pod not ready

Check:

```promql
up{job="ecommerce-services"}
```

Project-specific note:

```text
catalog-service exposes metrics. cart-service and payment-service need metrics endpoint improvement.
```

## 15. AWS Migration Explanation

If asked to migrate this GCP project to AWS, explain by layers.

| Layer | GCP Current | AWS Equivalent |
|---|---|---|
| Kubernetes | GKE | EKS |
| Image registry | Artifact Registry | ECR |
| CI | Cloud Build | CodeBuild, CodePipeline, or GitHub Actions |
| GitOps | ArgoCD | ArgoCD on EKS |
| Database | Cloud SQL | RDS |
| Network | GCP VPC | AWS VPC |
| Private outbound | Cloud NAT | NAT Gateway |
| Load balancing | GCLB / ingress-nginx | ALB/NLB with AWS Load Balancer Controller |
| DNS | Cloud DNS | Route 53 |
| Secrets | Secret Manager | Secrets Manager / SSM |
| Metrics | Prometheus/Grafana, Cloud Monitoring | AMP, CloudWatch, Grafana |
| Logs | Cloud Logging | CloudWatch Logs |
| IAM to workload | Workload Identity | IRSA / EKS Pod Identity |

Strong interview answer:

```text
The application and Kubernetes manifests remain mostly portable. The main migration work is infrastructure and integrations: GKE to EKS, Artifact Registry image paths to ECR, Cloud Build to CodeBuild or GitHub Actions, Cloud SQL to RDS, GCP IAM to AWS IAM roles, and ingress/load balancer integration to AWS Load Balancer Controller.
```

## 16. Cost Optimization Story

Cost areas:

- GKE node size and count
- Idle load balancers
- Cloud SQL instance size
- Artifact storage
- NAT gateway/data transfer
- Logging and metrics retention

Optimization actions:

- Right-size resource requests and limits
- Use HPA for workload scaling
- Use cluster autoscaler where appropriate
- Use smaller non-prod nodes
- Delete unused load balancers and disks
- Set log retention carefully
- Use budgets and alerts

AWS mapping:

```text
In AWS, I would optimize EKS node groups, ECR lifecycle policies, ALB/NAT Gateway usage, RDS sizing, CloudWatch retention, and Savings Plans or Spot where appropriate.
```

## 17. Resume Bullet Options

Use these as resume bullets after adjusting numbers only if true.

```text
Built a GCP-based ecommerce microservices platform using GKE, Docker, Terraform, Cloud Build, Artifact Registry, ArgoCD, Prometheus, and Grafana.
```

```text
Implemented GitOps deployment with ArgoCD automated sync, prune, self-heal, and Kubernetes manifest management across frontend and backend microservices.
```

```text
Provisioned cloud infrastructure using Terraform modules for VPC, GKE, and Cloud SQL with environment-based structure and remote-state-ready design.
```

```text
Designed Kubernetes workloads with Deployments, Services, Ingress, HPA, probes, resource limits, RBAC, NetworkPolicies, and pod security controls.
```

```text
Mapped GCP-native architecture to AWS equivalents including EKS, ECR, CodeBuild, RDS, Route 53, CloudWatch, and IAM roles for interview and migration readiness.
```

## 18. Project Interview Questions

### 1. Explain your project end to end.

Use:

```text
This is an ecommerce microservices DevOps project on GCP. Terraform provisions infrastructure like VPC, GKE, and Cloud SQL. Cloud Build builds Docker images and pushes them to Artifact Registry. Kubernetes manifests define Deployments, Services, Ingress, HPA, monitoring, and security controls. ArgoCD watches the Git repository and syncs the k8s folder to GKE. Prometheus and Grafana provide observability. The project is designed to show CI/CD, GitOps, Kubernetes operations, and cloud mapping to AWS.
```

### 2. Why did you use Kubernetes?

Use:

```text
Kubernetes gives a standard way to run microservices with self-healing, rolling updates, service discovery, autoscaling, and declarative configuration. It also makes the architecture portable between GKE and EKS.
```

### 3. Why did you use ArgoCD?

Use:

```text
ArgoCD gives GitOps deployment. Git is the source of truth, ArgoCD detects drift, syncs the desired state, supports rollback visibility, and improves deployment auditability.
```

### 4. How does traffic flow?

Use:

```text
Traffic enters through ingress, reaches the frontend service and Pod, then frontend calls API Gateway. API Gateway routes to catalog, cart, and payment services using Kubernetes service discovery.
```

### 5. How do you debug production issues?

Use:

```text
I start with user impact and recent changes. Then I check ArgoCD health/sync, Kubernetes Pods and events, service endpoints, application logs, Prometheus metrics, and Grafana dashboards. Based on the symptom, I isolate whether it is deployment, networking, application, resource, image, or dependency related.
```

### 6. How do you explain this project to an AWS interviewer?

Use:

```text
Although I built it on GCP, the design is cloud-portable. GKE maps to EKS, Artifact Registry to ECR, Cloud Build to CodeBuild or GitHub Actions, Cloud SQL to RDS, Cloud Monitoring to CloudWatch or AMP, and Cloud DNS to Route 53. The Kubernetes and ArgoCD concepts stay almost the same.
```

### 7. What are the weak points you would improve?

Use:

```text
I would improve metrics consistency for cart and payment services, remove plain-text local credentials, add SSO/RBAC for ArgoCD, add image scanning and signing, add progressive delivery, add stronger alert rules, and create separate dev/stage/prod promotion workflows.
```

### 8. What is your strongest DevOps learning from this project?

Use:

```text
The strongest learning is that DevOps is not only CI/CD. A reliable platform needs infrastructure as code, secure image supply chain, GitOps deployment, Kubernetes runtime design, monitoring, troubleshooting, cost awareness, and recovery planning.
```

## 19. VERDICT Master Troubleshooting Answer

Question:

```text
The ecommerce application is down after deployment. How will you troubleshoot?
```

Answer:

```text
V - Verify:
I verify the user-facing symptom, affected endpoint, time of issue, and whether a deployment happened recently.

E - Examine:
I check ArgoCD sync and health, then Kubernetes Pods, Services, Ingress, events, logs, and Prometheus/Grafana dashboards.

R - Reason:
I classify the issue as deployment drift, image pull failure, application crash, readiness failure, service routing issue, ingress problem, resource exhaustion, or dependency failure.

D - Decide:
If it is a bad release, I rollback or revert Git. If it is config or infrastructure, I fix the manifest or Terraform. If it is app-level, I fix code/config and redeploy.

I - Implement:
I apply the fix through Git, let CI build if needed, and let ArgoCD sync the desired state.

C - Confirm:
I confirm Pods are ready, Services have endpoints, Ingress works, metrics are healthy, and the user-facing endpoint returns success.

T - Tell:
I document root cause, timeline, fix, prevention, and monitoring improvements.
```

## 20. Seven-Day Final Revision Plan

Day 1:

```text
Explain architecture, folder structure, service flow, and request path.
```

Day 2:

```text
Practice Docker, Cloud Build, Artifact Registry, and CI questions.
```

Day 3:

```text
Practice Kubernetes Deployments, Services, Ingress, HPA, probes, and troubleshooting.
```

Day 4:

```text
Practice ArgoCD GitOps, sync, health, diff, rollback, drift, and self-heal.
```

Day 5:

```text
Practice Terraform, VPC, GKE, Cloud SQL, remote state, and module questions.
```

Day 6:

```text
Practice Prometheus, Grafana, logs, events, tracing, alerts, and incident response.
```

Day 7:

```text
Practice AWS mapping, resume explanation, HR questions, and VERDICT troubleshooting stories.
```

## 21. Final Interview Pitch

```text
My project is a production-style ecommerce DevOps platform built primarily on GCP. I containerized frontend and backend microservices, provisioned cloud infrastructure with Terraform, used Cloud Build and Artifact Registry for CI and image management, deployed to GKE using Kubernetes manifests, and managed deployments through ArgoCD GitOps. The system includes ingress routing, health and readiness probes, HPA, RBAC, network policies, pod security, Prometheus, Grafana, and tracing foundations. I can troubleshoot it using ArgoCD, kubectl, logs, events, metrics, and dashboards. Since the platform is Kubernetes-based, I can map the same design to AWS using EKS, ECR, CodeBuild, RDS, Route 53, CloudWatch, IAM roles, and AWS Load Balancer Controller.
```

