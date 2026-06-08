# Day 15 - AWS IAM For A GCP-Native Engineer

## Target

Understand AWS IAM through GCP service account thinking.

## Learn Deeply

- IAM user.
- IAM group.
- IAM role.
- Policy.
- Trust policy.
- Permission policy.
- STS.
- Instance profile.
- OIDC federation.

## Hands-On Lab

Draw this flow:

```text
EC2/ECS/EKS workload -> assumes IAM Role -> receives temporary STS credentials -> calls AWS API
```

Compare it with:

```text
GCE/GKE workload -> uses Service Account -> calls GCP API
```

## Interview Angle

Say:

```text
In AWS, the trust policy controls who can assume the role; the permission policy controls what the role can do.
```

## AWS/GCP Mapping

Service Account is the closest mental equivalent to IAM Role, but AWS separates trust and permission more explicitly.

## Daily Motivation

AWS IAM looks complex because it has more policy types. The goal is still least privilege identity.

## Practice

Use `interview-question-bank.md` Day 15 questions 1-10.

