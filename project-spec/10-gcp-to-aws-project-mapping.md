# 10 - GCP To AWS Project Mapping

Use this when interviewers ask AWS questions.

## Full Project Mapping

| Current GCP Project | AWS Equivalent |
|---|---|
| GCP Project | AWS Account |
| GKE | EKS |
| GKE alternative | ECS Fargate |
| Artifact Registry | ECR |
| Cloud Build | CodeBuild |
| Cloud Build pipeline | CodePipeline + CodeBuild |
| Cloud SQL | RDS / Aurora |
| Cloud Load Balancer / Ingress | ALB |
| Cloud DNS | Route 53 |
| Cloud Monitoring | CloudWatch Metrics |
| Cloud Logging | CloudWatch Logs |
| Cloud Audit Logs | CloudTrail |
| Secret Manager | Secrets Manager / SSM Parameter Store |
| Cloud NAT | NAT Gateway |
| GCP Firewall Rules | Security Groups + NACLs |
| Terraform GCP provider | Terraform AWS provider |
| ArgoCD on GKE | ArgoCD on EKS |

## AWS Version Architecture

```text
Browser
  -> Route 53
  -> ALB
  -> EKS Ingress or ECS Service
      -> frontend
      -> api-gateway
      -> catalog
      -> cart
      -> payment
  -> RDS
  -> CloudWatch
  -> CloudTrail
  -> Secrets Manager
```

## EKS Migration

Use EKS if:

- You want to reuse Kubernetes manifests.
- You want ArgoCD GitOps.
- Team already knows Kubernetes.
- You need Kubernetes ecosystem/tools.

Changes needed:

- Change image paths from Artifact Registry to ECR.
- Configure AWS Load Balancer Controller.
- Configure IAM Roles for Service Accounts / EKS Pod Identity.
- Configure EBS CSI if storage needed.
- Configure CloudWatch/Container Insights.
- Update ingress annotations for ALB.

Interview answer:

```text
EKS is the closest AWS mapping because this project already uses Kubernetes. Most manifests transfer, but AWS-specific changes are image registry, IAM, ingress, storage, and observability integrations.
```

## ECS Fargate Migration

Use ECS Fargate if:

- Kubernetes is not required.
- You want simpler AWS-native operations.
- You want no node management.

Changes needed:

- Create ECR repositories.
- Create ECS task definitions for each service.
- Create ECS services.
- Attach services to ALB target groups.
- Configure task execution role.
- Configure task role.
- Send logs to CloudWatch.

Interview answer:

```text
ECS Fargate is a good AWS-native alternative if the company does not need Kubernetes. It reduces operational overhead but requires converting Kubernetes manifests into ECS task definitions and services.
```

## AWS CI/CD Equivalent

GCP:

```text
Cloud Build -> Artifact Registry -> Git manifest update -> ArgoCD -> GKE
```

AWS:

```text
CodeBuild/CodePipeline -> ECR -> Git manifest update -> ArgoCD -> EKS
```

Or ECS:

```text
CodeBuild/CodePipeline -> ECR -> ECS deploy new task definition -> ALB health check
```

## AWS Monitoring Equivalent

GCP project monitoring:

```text
Prometheus/Grafana + Cloud Logging/Monitoring + Cloud Trace pattern
```

AWS monitoring:

```text
CloudWatch Logs
CloudWatch Metrics
CloudWatch Alarms
CloudTrail
Container Insights
ALB access logs
X-Ray or OpenTelemetry tracing
Managed Prometheus/Grafana optional
```

## AWS Interview Answer For This Project

```text
Although I implemented the project on GCP, I can map the same architecture to AWS. I would use EKS if I want to keep Kubernetes and ArgoCD, or ECS Fargate if I want simpler AWS-native container operations. I would replace Artifact Registry with ECR, Cloud Build with CodeBuild/CodePipeline, Cloud SQL with RDS, GCP Load Balancer with ALB, Cloud Monitoring with CloudWatch, and Cloud Audit Logs with CloudTrail. The main AWS-specific areas I would handle carefully are IAM roles, VPC route tables, security groups, NAT Gateway, ALB target groups, and ECR permissions.
```

