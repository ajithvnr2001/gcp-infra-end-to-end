# Day 18 Project + AWS Focus

## Project Connection

The project frontend/API needs public entry through an ingress/load balancer.

## GCP To AWS Mapping

GCP Load Balancer maps to AWS ALB. Cloud DNS maps to Route 53.

## Project Question

How would you expose this app on AWS EKS?

Answer:

```text
Install AWS Load Balancer Controller, create Kubernetes Ingress, provision ALB, configure target groups to services/pods, attach ACM certificate, and point Route 53 DNS to ALB.
```

