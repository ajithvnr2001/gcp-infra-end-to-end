# AWS-GCP Service Map Cheat Sheet

| GCP | AWS |
|---|---|
| Project | Account |
| IAM Service Account | IAM Role |
| GCE | EC2 |
| MIG | Auto Scaling Group |
| GKE | EKS |
| Cloud Run | ECS Fargate / App Runner |
| Artifact Registry | ECR |
| Cloud Build | CodeBuild |
| Cloud Deploy | CodePipeline / CodeDeploy |
| Cloud SQL | RDS / Aurora |
| GCS | S3 |
| Cloud CDN | CloudFront |
| Cloud Load Balancer | ALB / NLB |
| Cloud DNS | Route 53 |
| Cloud NAT | NAT Gateway |
| VPC Firewall | Security Group + NACL |
| Secret Manager | Secrets Manager / SSM |
| Cloud Logging | CloudWatch Logs |
| Cloud Monitoring | CloudWatch Metrics/Alarms |
| Cloud Audit Logs | CloudTrail |

## Interview Line

```text
I built this on GCP, but the cloud layers map directly to AWS. The biggest AWS-specific areas are IAM role assumption and VPC networking with route tables, security groups, and NACLs.
```

