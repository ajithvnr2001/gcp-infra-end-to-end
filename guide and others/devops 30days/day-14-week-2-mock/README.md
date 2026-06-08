# Day 14 - Week 2 Mock And Revision

## Target

Combine CI/CD, Kubernetes, Terraform, observability, and IAM.

## Deep Revision

You should now explain:

- How a deployment pipeline works.
- How Kubernetes deploys and routes traffic.
- How Terraform manages infra.
- How logs/metrics/traces help debugging.
- How IAM and secrets affect deployments.

## Hands-On Lab

Write a production deployment checklist:

- Plan reviewed.
- CI passed.
- Image tag immutable.
- Secrets available.
- Probes configured.
- Rollback ready.
- Dashboard open.
- Smoke test command ready.

## Interview Angle

Prepare this answer:

```text
If deployment fails after CI success, I check image tag, registry, manifest, cluster permissions, rollout status, pod events, and logs.
```

## AWS/GCP Mapping

This is where cloud differences appear: GCP Artifact Registry/GKE/IAM vs AWS ECR/EKS/IAM Roles.

## Daily Motivation

Checklists are not beginner tools. They are production safety tools.

## Practice

Use `interview-question-bank.md` Day 14 questions 1-10.

