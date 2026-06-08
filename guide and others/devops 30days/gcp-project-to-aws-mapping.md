# Mapping This GCP Project To AWS

This file helps you answer AWS questions even though the project is currently GCP-native.

## One-Line Interview Answer

```text
I built this project on GCP, but the same architecture maps cleanly to AWS: GKE becomes EKS or ECS, Artifact Registry becomes ECR, Cloud Build becomes CodeBuild/CodePipeline, Cloud SQL becomes RDS, Cloud Load Balancing becomes ALB, Cloud Monitoring/Logging becomes CloudWatch, and Cloud Audit Logs becomes CloudTrail.
```

## Full Mapping Table

| Current GCP Project Component | AWS Equivalent | What To Say In Interview |
|---|---|---|
| GCP Project | AWS Account | Both are isolation/billing/IAM boundaries. |
| Terraform for GCP | Terraform for AWS | Same workflow; provider/resources change. |
| VPC | VPC | Same network boundary concept. |
| GCP Subnet | AWS Subnet | AWS subnets are tied to one AZ; route tables attach to subnets. |
| GCP Firewall Rules | Security Groups + NACLs | SG is stateful resource-level firewall; NACL is stateless subnet-level. |
| Cloud NAT | NAT Gateway | Private workloads use NAT for outbound internet. |
| GKE | EKS | Managed Kubernetes control plane. |
| GKE alternative | ECS Fargate | If Kubernetes is not required, ECS Fargate reduces ops overhead. |
| Artifact Registry | ECR | Docker image registry. |
| Cloud Build | CodeBuild | Build execution. |
| Cloud Build pipeline | CodePipeline + CodeBuild | Pipeline orchestration plus build. |
| ArgoCD on GKE | ArgoCD on EKS | GitOps works the same. |
| Cloud SQL | RDS/Aurora | Managed relational database. |
| Secret Manager | AWS Secrets Manager / SSM Parameter Store | Managed secrets/config. |
| Cloud Logging | CloudWatch Logs | Centralized logs. |
| Cloud Monitoring | CloudWatch Metrics/Alarms | Metrics and alerting. |
| Cloud Audit Logs | CloudTrail | Audit trail of API activity. |
| GCP Load Balancer / Ingress | ALB / AWS Load Balancer Controller | HTTP routing to Kubernetes or ECS targets. |
| Cloud DNS | Route 53 | DNS hosted zones and records. |
| IAM Service Account | IAM Role | Workload identity with least privilege. |

## AWS Version Of This Architecture

### Option 1 - EKS Version

```text
Developer push
  -> CodePipeline / GitHub Actions
  -> CodeBuild builds Docker images
  -> ECR stores images
  -> Git manifest update
  -> ArgoCD sync
  -> EKS deploys services
  -> ALB Ingress routes traffic
  -> RDS stores persistent data
  -> CloudWatch observes logs/metrics
  -> CloudTrail audits changes
```

Use when:

- Team already knows Kubernetes.
- Need Kubernetes CRDs/controllers/operators.
- Need portability across clouds.
- Existing manifests can be reused with AWS-specific ingress/IAM changes.

### Option 2 - ECS Fargate Version

```text
Developer push
  -> CodePipeline / GitHub Actions
  -> CodeBuild builds Docker images
  -> ECR stores images
  -> ECS service deploys task definition
  -> ALB routes traffic to ECS service
  -> RDS stores persistent data
  -> CloudWatch logs/metrics
  -> CloudTrail audit
```

Use when:

- You do not need Kubernetes.
- You want less cluster/node management.
- App is straightforward containerized microservices.
- AWS-native simplicity is preferred.

Interview line:

```text
If I migrate this exact project, EKS gives the easiest Kubernetes manifest migration. If the company wants lower operational overhead and does not require Kubernetes APIs, ECS Fargate is a strong alternative.
```

## GCP To AWS IAM Explanation

Current GCP model:

```text
GKE workload -> Kubernetes Service Account -> GCP Service Account / IAM permissions -> GCP APIs
```

AWS EKS model:

```text
EKS pod -> Kubernetes Service Account -> IAM Role for Service Account / Pod Identity -> AWS APIs
```

AWS ECS model:

```text
ECS task -> Task Role -> AWS APIs
ECS agent -> Execution Role -> pull ECR image, write CloudWatch logs, read secrets
```

Interview line:

```text
In AWS I would avoid static access keys. For EKS I would use IAM Roles for Service Accounts or EKS Pod Identity. For ECS I would separate task role and execution role.
```

## GCP To AWS Networking Explanation

Current GCP mental model:

```text
VPC -> subnets -> firewall rules -> Cloud NAT -> Load Balancer -> GKE services
```

AWS mental model:

```text
VPC -> public/private subnets -> route tables -> IGW/NAT Gateway -> Security Groups/NACLs -> ALB -> ECS/EKS services
```

Public subnet:

```text
Route 0.0.0.0/0 -> Internet Gateway
```

Private subnet:

```text
Route 0.0.0.0/0 -> NAT Gateway
```

Interview line:

```text
In AWS, I always trace traffic through route table, security group, NACL, DNS, and target health. That is the equivalent of checking GCP routes, firewall rules, Cloud NAT, and load balancer health.
```

## Migration Plan From This GCP Project To AWS EKS

### Step 1 - Container Registry

GCP:

```text
Artifact Registry
```

AWS:

```text
ECR
```

Actions:

- Create ECR repositories for each service.
- Update image names in Kubernetes manifests.
- Grant CodeBuild push permissions.
- Grant EKS nodes/pods pull permissions.

### Step 2 - CI/CD

GCP:

```text
Cloud Build
```

AWS:

```text
CodeBuild + CodePipeline or GitHub Actions
```

Actions:

- Build Docker images.
- Tag images with commit SHA.
- Push to ECR.
- Update manifests.
- Let ArgoCD sync.

### Step 3 - Kubernetes

GCP:

```text
GKE
```

AWS:

```text
EKS
```

Actions:

- Create EKS cluster with node groups.
- Install AWS Load Balancer Controller.
- Configure EBS CSI driver if persistent volumes needed.
- Configure IAM roles for service accounts.
- Apply manifests after AWS-specific changes.

### Step 4 - Networking

GCP:

```text
VPC + Cloud NAT + firewall rules
```

AWS:

```text
VPC + public/private subnets + NAT Gateway + Security Groups
```

Actions:

- Put ALB in public subnets.
- Put worker nodes/services in private subnets.
- Put RDS in private subnets.
- Allow only required SG flows.

### Step 5 - Database

GCP:

```text
Cloud SQL
```

AWS:

```text
RDS or Aurora
```

Actions:

- Create RDS subnet group.
- Configure security group from app workloads to DB.
- Store credentials in Secrets Manager.
- Plan migration using dump/restore or DMS if real data exists.

### Step 6 - Observability

GCP:

```text
Cloud Logging, Cloud Monitoring, Prometheus/Grafana
```

AWS:

```text
CloudWatch Logs, CloudWatch Metrics, CloudWatch Alarms, AMP/Grafana optional
```

Actions:

- Send app logs to CloudWatch.
- Add ALB metrics.
- Add EKS/container insights.
- Add RDS metrics.
- Create alarms for latency, errors, CPU, memory, restarts.

## AWS Interview Questions Based On This Project

### 1. If this project was deployed on AWS, what services would you use?

Answer:

```text
I would use EKS or ECS Fargate for containers, ECR for image registry, CodeBuild/CodePipeline for CI/CD, RDS for relational database, ALB for ingress, VPC with public/private subnets, NAT Gateway for private outbound access, CloudWatch for logs/metrics, CloudTrail for audit, Route 53 for DNS, and Secrets Manager for secrets.
```

### 2. Would you choose ECS or EKS?

Answer:

```text
If I want to reuse Kubernetes manifests and GitOps with ArgoCD, I would choose EKS. If the company does not need Kubernetes complexity, I would choose ECS Fargate because it reduces node management.
```

### 3. How would you replace Artifact Registry?

Answer:

```text
I would create ECR repositories for each service. CodeBuild would authenticate to ECR, build Docker images, tag them with commit SHA, and push them. EKS/ECS execution roles would need permission to pull from ECR.
```

### 4. How would you expose the app publicly in AWS?

Answer:

```text
For EKS I would use AWS Load Balancer Controller to create an ALB from Kubernetes Ingress. For ECS I would attach ECS services to an ALB target group. Route 53 would point DNS to the ALB.
```

### 5. How would you handle private workloads?

Answer:

```text
I would place application workloads and RDS in private subnets. The ALB would be in public subnets. Private subnets would use NAT Gateway for outbound internet access, and security groups would allow only required traffic.
```

### 6. How would you store secrets?

Answer:

```text
I would use AWS Secrets Manager or SSM Parameter Store. For ECS, secrets can be injected into task definitions. For EKS, External Secrets Operator can sync from Secrets Manager to Kubernetes Secrets.
```

### 7. How would you monitor this project on AWS?

Answer:

```text
I would use CloudWatch Logs for service logs, CloudWatch metrics and alarms for ALB/ECS/EKS/RDS, Container Insights for containers, CloudTrail for audit, and optionally Prometheus/Grafana for Kubernetes metrics.
```

### 8. How would rollback work on AWS?

Answer:

```text
With EKS and ArgoCD, rollback is similar to GCP: revert the manifest or image tag and let ArgoCD sync. With ECS, deploy the previous task definition revision or previous image tag.
```

### 9. How would you debug AWS deployment failure?

Answer:

```text
I would check CodeBuild logs, ECR image existence, IAM permissions, ECS/EKS events, ALB target health, CloudWatch logs, security groups, and application health checks.
```

### 10. What is the biggest AWS learning area for a GCP-native engineer?

Answer:

```text
IAM and networking. AWS IAM has trust policies, resource policies, permission boundaries, and STS. AWS networking uses route tables per subnet, security groups, NACLs, NAT Gateway, and ALB target groups. Once those are clear, the rest maps well from GCP.
```

