# Day 16 - AWS VPC For A GCP-Native Engineer

## Target

Understand AWS networking clearly.

## Learn Deeply

- VPC.
- Public subnet.
- Private subnet.
- Route table.
- Internet Gateway.
- NAT Gateway.
- Security Group.
- NACL.
- VPC Flow Logs.

## Hands-On Lab

Draw a 2-tier VPC:

```text
Public subnet: ALB + NAT Gateway
Private subnet: EC2/ECS/EKS workloads + RDS
Routes: public -> IGW, private -> NAT
```

## Interview Angle

Say:

```text
For AWS network issues I trace route table, security group, NACL, DNS, and target health.
```

## AWS/GCP Mapping

GCP firewall rules are VPC-level with targets. AWS Security Groups attach to ENIs/resources and are stateful.

## Daily Motivation

AWS networking becomes manageable when you trace one packet at a time.

## Practice

Use `interview-question-bank.md` Day 16 questions 1-10.

