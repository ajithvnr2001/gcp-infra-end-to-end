# Day 09 Project + AWS Focus

## Project Connection

The project has Kubernetes Deployments for frontend, catalog, cart, payment, and API gateway.

## GCP To AWS Mapping

GKE maps to EKS. The Kubernetes YAML remains mostly reusable, but AWS-specific ingress, IAM, storage, and load balancer annotations may change.

## Project Question

What does a Kubernetes Deployment give this project?

Answer:

```text
It manages desired replicas, rolling updates, pod template, self-healing, and rollout history for each microservice.
```

