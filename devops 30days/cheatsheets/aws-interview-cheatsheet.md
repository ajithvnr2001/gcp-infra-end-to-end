# AWS Interview Cheat Sheet

## IAM

```text
Role = temporary assumable identity.
Trust policy = who can assume.
Permission policy = what it can do.
STS = temporary credentials.
```

## VPC

```text
Public subnet: default route to Internet Gateway.
Private subnet: default route to NAT Gateway.
Security Group: stateful resource firewall.
NACL: stateless subnet firewall.
```

## ECS

```text
Execution role: pull image, write logs, read startup secrets.
Task role: app's AWS API permissions.
```

## EKS

```text
Managed Kubernetes control plane.
Worker nodes run on EC2 or Fargate.
Use IAM Roles for Service Accounts / Pod Identity for AWS API access.
```

## ALB

```text
Layer 7 HTTP/HTTPS load balancer.
Debug 502/503 through listener, target group, health check, SG, app logs.
```

## RDS

```text
Managed relational database.
Debug connection through endpoint, port, SG, subnet, credentials, status, connection limits.
```

## CloudWatch vs CloudTrail

```text
CloudWatch = logs, metrics, alarms.
CloudTrail = who changed what in AWS API.
```

