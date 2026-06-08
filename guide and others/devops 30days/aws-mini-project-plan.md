# AWS Mini Project Plan - Map Your GCP Ecommerce Platform To AWS

Purpose: give you credible AWS interview confidence without rebuilding everything immediately.

## Target AWS Architecture

```text
Browser
  -> Route 53
  -> ALB
  -> ECS Fargate services or EKS services
      -> frontend
      -> api-gateway
      -> catalog
      -> cart
      -> payment
  -> RDS PostgreSQL / MySQL for persistence
  -> CloudWatch Logs/Metrics
  -> CloudTrail audit
  -> ECR image registry
  -> Secrets Manager
```

## Option A - ECS Fargate Mini Project

Choose this if you want the easiest AWS hands-on story.

### Services

- ECR repositories for each service.
- ECS cluster.
- Fargate task definitions.
- ECS services.
- ALB listener and target groups.
- CloudWatch log groups.
- Secrets Manager for DB/app secrets.
- RDS in private subnets.

### Learning Value

- ECS task definition.
- Task role vs execution role.
- ECR image pull.
- ALB target group health.
- CloudWatch logging.
- VPC public/private subnet design.

### Interview Story

```text
To strengthen AWS, I mapped my GCP/GKE ecommerce project to ECS Fargate. I used ECR for images, ECS services for containers, ALB for routing, RDS for database, CloudWatch for logs, and IAM roles for secure access.
```

## Option B - EKS Mini Project

Choose this if you want Kubernetes continuity.

### Services

- ECR repositories.
- EKS cluster.
- Managed node group.
- AWS Load Balancer Controller.
- Kubernetes manifests updated with ECR image URLs.
- ArgoCD installed on EKS.
- RDS for database.
- CloudWatch Container Insights.

### Learning Value

- EKS cluster setup.
- IAM Roles for Service Accounts / Pod Identity.
- EKS node groups.
- ALB Ingress.
- ECR image pulls.
- ArgoCD on AWS.

### Interview Story

```text
Since my project already uses Kubernetes on GKE, I designed the AWS version on EKS. The Kubernetes manifests mostly transfer, but AWS requires ECR image paths, AWS Load Balancer Controller, IAM roles for workloads, and AWS-specific networking.
```

## Recommended Path

For fastest interview readiness:

```text
Week 1 after this 30-day plan: ECS Fargate design + commands
Week 2: EKS design + Kubernetes mapping
```

Reason:

- ECS gives AWS-native confidence quickly.
- EKS shows you can map existing Kubernetes/GKE knowledge.

## AWS Mini Project Day Plan

### Day A1 - AWS Account And IAM

Learn:

- IAM admin/user/role basics.
- MFA.
- AWS CLI config.
- Least privilege.

Deliverable:

```text
Architecture note: which roles are needed for CodeBuild, ECS task execution, ECS task app role, and human admin access.
```

### Day A2 - VPC Design

Learn:

- VPC.
- Public/private subnets.
- Route tables.
- IGW.
- NAT Gateway.
- Security Groups.

Deliverable:

```text
Draw: Route 53 -> ALB public subnet -> ECS private subnet -> RDS private subnet.
```

### Day A3 - ECR And Image Workflow

Learn:

- ECR repository.
- Docker login.
- Tag/push image.
- Lifecycle policy.

Deliverable:

```text
Map each GCP Artifact Registry image to an ECR image URL.
```

### Day A4 - ECS Fargate

Learn:

- Cluster.
- Task definition.
- Service.
- Execution role.
- Task role.
- CloudWatch logs.

Deliverable:

```text
Explain why a task may stop and how to debug stopped reason.
```

### Day A5 - ALB And Route 53

Learn:

- ALB.
- Listener.
- Target group.
- Health checks.
- DNS alias.

Deliverable:

```text
Debug playbook for ALB 502 and 503.
```

### Day A6 - RDS And Secrets

Learn:

- RDS subnet group.
- Security group from app to DB.
- Secrets Manager.
- Backup and Multi-AZ.

Deliverable:

```text
Debug playbook for RDS connection timeout.
```

### Day A7 - Monitoring And Final Story

Learn:

- CloudWatch logs.
- Metrics.
- Alarms.
- CloudTrail.
- Budget alert.

Deliverable:

```text
Final AWS version interview story in 2 minutes.
```

## AWS Commands To Know

You do not need to memorize all commands, but recognize them:

```bash
aws sts get-caller-identity
aws ecr create-repository --repository-name catalog-service
aws ecr get-login-password --region us-east-1
aws ecs list-clusters
aws ecs describe-services --cluster <cluster> --services <service>
aws ecs describe-tasks --cluster <cluster> --tasks <task-id>
aws logs tail /ecs/api-gateway --follow
aws elbv2 describe-target-health --target-group-arn <arn>
aws rds describe-db-instances
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=AuthorizeSecurityGroupIngress
```

## AWS Mini Project Interview Questions

### 1. Why ECS Fargate instead of EKS?

Answer:

```text
ECS Fargate reduces operational overhead because I do not manage Kubernetes control plane or worker nodes. It is good when the application only needs containers and AWS-native integration.
```

### 2. Why EKS instead of ECS?

Answer:

```text
EKS is better if the team already uses Kubernetes manifests, ArgoCD, Helm, operators, or needs portability across clouds.
```

### 3. What role pulls images from ECR in ECS?

Answer:

```text
The task execution role pulls images from ECR, writes CloudWatch logs, and reads secrets needed at startup.
```

### 4. What role does app use to call AWS APIs?

Answer:

```text
The ECS task role is used by the application code to call AWS APIs.
```

### 5. How do you debug ECS task stopped?

Answer:

```text
Check stopped reason, exit code, CloudWatch logs, image pull, env/secrets, CPU/memory, task execution role, and health check failures.
```

### 6. How do you debug ALB unhealthy target?

Answer:

```text
Check target group health reason, health check path/port, security group from ALB to service, container port, app readiness, and logs.
```

### 7. How do you debug ECR pull denied?

Answer:

```text
Check image URL, repo region/account, execution role permissions, ECR auth, VPC endpoint/NAT access, and whether image tag exists.
```

### 8. How do you debug RDS timeout?

Answer:

```text
Check app SG to RDS SG, subnet routing, RDS status, endpoint/port, NACL, credentials, and connection count.
```

### 9. How do you monitor ECS app?

Answer:

```text
Use CloudWatch logs, ECS service metrics, ALB metrics, target health, RDS metrics, alarms, and CloudTrail for change audit.
```

### 10. How does this compare to your GCP project?

Answer:

```text
The architecture is the same at a high level. GKE maps to EKS/ECS, Artifact Registry to ECR, Cloud Build to CodeBuild, Cloud SQL to RDS, Cloud Monitoring to CloudWatch, and Cloud Audit Logs to CloudTrail.
```

