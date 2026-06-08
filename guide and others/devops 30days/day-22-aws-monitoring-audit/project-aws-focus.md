# Day 22 Project + AWS Focus

## Project Connection

The project needs visibility into CI/CD, Kubernetes, service health, and cloud changes.

## GCP To AWS Mapping

Cloud Build logs -> CodeBuild logs in CloudWatch.

GKE logs -> EKS logs / Container Insights / CloudWatch.

Cloud Audit Logs -> CloudTrail.

## Project Question

How do you find who changed AWS security group rules?

Answer:

```text
Use CloudTrail and search for AuthorizeSecurityGroupIngress, RevokeSecurityGroupIngress, or related EC2 security group API events.
```

