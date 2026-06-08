# Day 08 Project + AWS Focus

## Project Connection

The project uses Cloud Build to build five images in parallel and push them to Artifact Registry.

## GCP To AWS Mapping

Cloud Build maps to CodeBuild. A full AWS pipeline can use CodePipeline + CodeBuild + ECR + ArgoCD/EKS.

## Project Question

What are CI and CD in this project?

Answer:

```text
CI is Cloud Build building and pushing images. CD is ArgoCD syncing Kubernetes manifests to GKE.
```

