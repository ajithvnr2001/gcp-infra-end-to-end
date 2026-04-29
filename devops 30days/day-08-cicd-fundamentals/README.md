# Day 08 - CI/CD Fundamentals

## Target

Understand pipelines as safe change delivery.

## Learn Deeply

- CI: lint, test, build.
- CD: deploy, verify, rollback.
- Artifacts and image tags.
- Pipeline secrets.
- Caching and parallelism.
- Manual approvals and environments.

## Hands-On Lab

Draw the pipeline for this ecommerce project:

```text
Git push -> Cloud Build -> Docker build -> Artifact Registry -> Kubernetes manifest -> ArgoCD/K8s deploy -> verify
```

Add failure points for each stage.

## Interview Angle

Say:

```text
CI/CD is not just YAML. It is a controlled system for making every production change testable, traceable, deployable, and rollback-ready.
```

## AWS/GCP Mapping

GCP Cloud Build maps to AWS CodeBuild. Cloud Deploy/ArgoCD maps partly to CodePipeline/CodeDeploy or GitOps controllers.

## Daily Motivation

Good pipelines reduce fear of deployment.

## Practice

Use `interview-question-bank.md` Day 8 questions 1-10.

