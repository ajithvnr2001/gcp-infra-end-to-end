# AWS VPC Diagram Lab

Draw this and explain it out loud.

```text
Internet
  -> Route 53
  -> ALB in public subnets
      -> ECS/EKS workloads in private subnets
          -> RDS in private subnets

Public route table:
  0.0.0.0/0 -> Internet Gateway

Private route table:
  0.0.0.0/0 -> NAT Gateway

Security Groups:
  ALB SG allows 80/443 from internet
  App SG allows app port from ALB SG
  DB SG allows DB port from App SG
```

Interview line:

```text
I keep only the load balancer public. App and database stay private.
```

