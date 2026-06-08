# Day 29 Project + AWS Focus

## Project Connection

Mock interview project deep dive:

Prepare to answer:

- Why this architecture?
- Why GKE?
- Why ArgoCD?
- Why Terraform?
- How CI/CD works?
- How rollback works?
- What failed and how did you debug?
- How would AWS version look?

## GCP To AWS Mapping

When AWS comes up, do not apologize. Map confidently.

```text
GCP implementation: Terraform + GKE + Artifact Registry + Cloud Build + Cloud SQL + ArgoCD.
AWS implementation: Terraform + EKS/ECS + ECR + CodeBuild/CodePipeline + RDS + ArgoCD/CodeDeploy.
```

## Project Question

What if interviewer asks an AWS service you have not used?

Answer:

```text
I have not implemented that exact service in this project, but I understand the equivalent pattern from GCP. I would learn the AWS-specific IAM, networking, logging, and limits, then validate with a small lab.
```

