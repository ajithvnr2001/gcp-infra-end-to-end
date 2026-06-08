# Day 26 Project + AWS Focus

## Project Connection

Cost drivers in this project:

- GKE nodes.
- Cloud SQL.
- Load balancer.
- NAT.
- Logs/metrics.
- Artifact storage.

## GCP To AWS Mapping

AWS cost drivers:

- EKS control plane and nodes or ECS Fargate tasks.
- RDS.
- ALB.
- NAT Gateway.
- CloudWatch logs.
- ECR storage.

## Project Question

How would you reduce cost safely?

Answer:

```text
Right-size requests/nodes, autoscale, schedule non-prod down, reduce log retention/noise, use lifecycle policies for images/artifacts, clean unused disks/IPs/load balancers, and review database sizing.
```

