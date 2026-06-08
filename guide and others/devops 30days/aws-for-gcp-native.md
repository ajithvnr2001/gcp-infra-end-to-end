# AWS For A GCP-Native Engineer

This file maps AWS concepts to GCP concepts so you can learn AWS faster.

## Core Mapping

| Area | GCP | AWS | Interview Mental Model |
|---|---|---|---|
| Account boundary | Project | Account | AWS account is closer to a GCP project plus billing/security boundary. |
| Organization | Organization/Folders | AWS Organizations/OUs | Used for multi-account governance. |
| IAM principal | Service Account | IAM Role | In AWS, workloads usually assume roles instead of using long-lived keys. |
| VM | Compute Engine | EC2 | Same basic idea: instance, image, disk, network, metadata. |
| Managed Kubernetes | GKE | EKS | EKS manages control plane; nodes are usually EC2/node groups/Fargate. |
| Serverless containers | Cloud Run | ECS Fargate / App Runner | Cloud Run is simpler; ECS has more VPC/task/service concepts. |
| Object storage | Cloud Storage | S3 | Bucket, object, lifecycle, versioning, IAM/policies. |
| SQL | Cloud SQL | RDS/Aurora | Managed relational database. |
| NoSQL | Firestore/Bigtable | DynamoDB | DynamoDB is key-value/document with capacity/index design. |
| Load balancer | Cloud Load Balancing | ALB/NLB/CLB | ALB is HTTP layer 7; NLB is TCP layer 4. |
| Firewall | VPC Firewall Rules | Security Groups + NACLs | SG is stateful attached to ENI; NACL is stateless subnet layer. |
| VPC routes | VPC routes | Route Tables | In AWS, route tables attach to subnets. |
| NAT | Cloud NAT | NAT Gateway | Private subnets use NAT Gateway for outbound internet. |
| Logs | Cloud Logging | CloudWatch Logs | Central log storage/query. |
| Metrics | Cloud Monitoring | CloudWatch Metrics | Alarms, dashboards, service metrics. |
| Audit | Cloud Audit Logs | CloudTrail | Who did what, when, from where. |
| Registry | Artifact Registry | ECR | Docker image registry. |
| Build | Cloud Build | CodeBuild | Build execution. |
| Deploy pipeline | Cloud Deploy | CodePipeline/CodeDeploy | AWS has multiple services for CI/CD. |
| Secrets | Secret Manager | Secrets Manager / SSM Parameter Store | Secrets Manager supports rotation; SSM often used for config. |
| DNS | Cloud DNS | Route 53 | Hosted zones and records. |

## AWS Networking Explained Through GCP

In GCP you often think:

```text
VPC -> subnet -> firewall -> route -> Cloud NAT -> LB
```

In AWS think:

```text
VPC -> public/private subnets -> route tables -> IGW/NAT Gateway -> security groups -> ALB/NLB
```

Public subnet:

```text
Subnet route table has 0.0.0.0/0 -> Internet Gateway
```

Private subnet:

```text
Subnet route table has 0.0.0.0/0 -> NAT Gateway
```

Security group:

```text
Stateful instance/task-level firewall. If inbound is allowed, response outbound is automatically allowed.
```

NACL:

```text
Stateless subnet-level firewall. Must allow both inbound and outbound explicitly.
```

## AWS IAM Explained Through GCP

GCP service account:

```text
Workload runs as service account with IAM roles.
```

AWS role:

```text
Workload assumes IAM role and receives temporary credentials from STS.
```

Interview line:

```text
I avoid static AWS access keys for workloads. I use IAM roles with least privilege, and for CI/CD I prefer OIDC federation where possible.
```

## AWS Container Choices

Use this in interviews:

```text
If the team already uses Kubernetes or needs Kubernetes APIs/operators, I choose EKS.
If the app only needs containers with less operational overhead, I choose ECS Fargate.
If the app is simple HTTP and wants near serverless developer experience, I evaluate App Runner.
```

GCP comparison:

```text
GKE -> EKS
Cloud Run -> ECS Fargate/App Runner
Artifact Registry -> ECR
Cloud Build -> CodeBuild
```

## AWS Debugging Quick Checks

EC2 not reachable:

```text
Check instance state, status checks, security group inbound, NACL, route table, public IP, key pair, OS firewall.
```

ALB 502:

```text
Check target group health, app port, health check path, security group from ALB to target, app logs.
```

ECS task not starting:

```text
Check task stopped reason, image pull from ECR, IAM execution role, env/secrets, CPU/memory, CloudWatch logs.
```

RDS connection failing:

```text
Check security group, subnet group, public/private access, credentials, DNS endpoint, max connections, app connection string.
```

S3 access denied:

```text
Check IAM policy, bucket policy, object ownership, block public access, KMS key policy if encrypted.
```

