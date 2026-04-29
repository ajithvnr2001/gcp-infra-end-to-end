# Day 06 Project + AWS Focus

## Project Connection

The project includes local Docker Compose to run the full stack before Kubernetes deployment.

## GCP To AWS Mapping

Compose is local. Production maps to GKE/EKS/ECS. The idea of service DNS names maps to Kubernetes service names or ECS service discovery.

## Project Question

Why does frontend call `api-gateway` instead of localhost inside Compose?

Answer:

```text
Inside a container, localhost means the same container. For another service, Compose DNS uses the service name like api-gateway.
```

