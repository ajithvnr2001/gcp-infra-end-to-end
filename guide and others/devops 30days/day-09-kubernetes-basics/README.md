# Day 09 - Kubernetes Basics

## Target

Understand core Kubernetes objects and debugging commands.

## Learn Deeply

- Pod, Deployment, ReplicaSet.
- Service.
- ConfigMap and Secret.
- Namespace.
- Labels and selectors.
- Rollout and rollback.
- Events and logs.

## Hands-On Lab

Open this repo's deployment YAML and explain:

- Metadata.
- Replicas.
- Selector.
- Pod template.
- Container image.
- Ports.
- Env/config.
- Probes.
- Resources.

## Interview Angle

Say:

```text
Kubernetes works by desired state. Controllers continuously reconcile actual state to match YAML.
```

## AWS/GCP Mapping

GKE and EKS share Kubernetes concepts. Differences are IAM, networking, ingress, node management, and integrations.

## Daily Motivation

Kubernetes becomes simpler when you stop memorizing and start tracing desired state.

## Practice

Use `interview-question-bank.md` Day 9 questions 1-10.

