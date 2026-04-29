# Day 10 Project + AWS Focus

## Project Connection

The request path is:

```text
Browser -> frontend -> API gateway -> internal services
```

In Kubernetes:

```text
Ingress/LB -> frontend service -> API gateway service -> catalog/cart/payment services
```

## GCP To AWS Mapping

GKE Ingress/GCP LB maps to EKS AWS Load Balancer Controller + ALB.

## Project Question

If frontend cannot reach API gateway, what do you check?

Answer:

```text
Check frontend config, API gateway service name, service endpoints, ports, pod readiness, network policy, and API gateway logs.
```

