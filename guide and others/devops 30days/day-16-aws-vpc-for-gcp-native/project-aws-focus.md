# Day 16 Project + AWS Focus

## Project Connection

This project uses GCP VPC concepts. In production, nodes/services should avoid unnecessary public exposure.

## GCP To AWS Mapping

AWS equivalent:

```text
Public subnets: ALB, NAT Gateway
Private subnets: EKS nodes/ECS tasks, RDS
Security groups: ALB -> app, app -> DB
```

## Project Question

How would traffic flow in AWS?

Answer:

```text
User hits Route 53 DNS, traffic goes to ALB in public subnets, ALB forwards to EKS/ECS workloads in private subnets, workloads access RDS privately, and outbound internet goes through NAT Gateway.
```

