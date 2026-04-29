# Day 10 - Kubernetes Networking

## Target

Trace traffic from user to pod.

## Learn Deeply

- ClusterIP, NodePort, LoadBalancer.
- Ingress.
- Service selectors.
- Endpoints.
- Pod DNS.
- Readiness and traffic routing.
- NetworkPolicy basics.

## Hands-On Lab

Trace this path:

```text
User -> Load Balancer -> Ingress Controller -> Ingress Rule -> Service -> Endpoint -> Pod -> Container Port
```

For each layer, write one command/check.

## Interview Angle

Say:

```text
If a pod works but service fails, I check labels, selectors, targetPort, endpoints, and readiness first.
```

## AWS/GCP Mapping

GKE Ingress often maps to GCP Load Balancer. EKS commonly uses AWS Load Balancer Controller to create ALB/NLB.

## Daily Motivation

Most Kubernetes networking bugs are labels, ports, DNS, or readiness.

## Practice

Use `interview-question-bank.md` Day 10 questions 1-10.

