# Day 21 - AWS Containers: ECS, EKS, Fargate

## Target

Choose and debug AWS container platforms.

## Learn Deeply

- ECS cluster.
- Task definition.
- ECS service.
- Task role vs execution role.
- Fargate.
- EKS control plane.
- Node groups.
- ECR integration.
- ALB integration.

## Hands-On Lab

Decision exercise:

```text
Microservice app with no Kubernetes requirement -> ECS Fargate
App needs Kubernetes operators/portability -> EKS
Simple HTTP app with minimal ops -> App Runner/Cloud Run style
```

## Interview Angle

Say:

```text
If Kubernetes ecosystem is required, I choose EKS. If the goal is simpler AWS-native containers, ECS Fargate is often more operationally efficient.
```

## AWS/GCP Mapping

GKE maps to EKS. Cloud Run maps closer to ECS Fargate/App Runner.

## Daily Motivation

Good cloud engineers choose platforms by operational tradeoff, not popularity.

## Practice

Use `interview-question-bank.md` Day 21 questions 1-10.

