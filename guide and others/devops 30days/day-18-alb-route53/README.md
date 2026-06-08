# Day 18 - AWS Load Balancing And Route 53

## Target

Trace external traffic in AWS.

## Learn Deeply

- ALB vs NLB.
- Listener.
- Listener rule.
- Target group.
- Health check.
- Route 53 hosted zone.
- A, CNAME, Alias records.
- ACM certificates.

## Hands-On Lab

Trace:

```text
User DNS -> Route 53 -> ALB Listener -> Rule -> Target Group -> EC2/ECS Pod/App
```

Write what can fail at each layer.

## Interview Angle

Say:

```text
For ALB 502/503 I check listener rules, target group health, app port, health check path, and security group from ALB to target.
```

## AWS/GCP Mapping

GCP Load Balancer is more global/integrated. AWS separates ALB and NLB by layer 7 vs layer 4.

## Daily Motivation

Traffic debugging is a high-frequency interview topic. Master the request path.

## Practice

Use `interview-question-bank.md` Day 18 questions 1-10.

