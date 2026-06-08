# Day 13 - Secrets And IAM

## Target

Handle credentials and permissions safely.

## Learn Deeply

- Principle of least privilege.
- Static keys vs temporary credentials.
- GCP Service Accounts.
- AWS IAM Roles.
- Secret Manager / Secrets Manager.
- Kubernetes Secrets limitations.
- CI/CD secret handling.

## Hands-On Lab

Create a comparison table:

```text
GCP Service Account -> AWS IAM Role
GCP IAM Binding -> AWS Policy Attachment
GCP Secret Manager -> AWS Secrets Manager / SSM
Cloud Audit Logs -> CloudTrail
```

## Interview Angle

Say:

```text
I avoid long-lived static keys for workloads. I prefer service accounts or IAM roles with least privilege and audit logs.
```

## AWS/GCP Mapping

AWS role assumption via STS is the main concept to master as a GCP-native engineer.

## Daily Motivation

Security maturity makes you stand out at 3 years experience.

## Practice

Use `interview-question-bank.md` Day 13 questions 1-10.

