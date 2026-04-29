# Kubernetes Debug Cheat Sheet

## First Commands

```bash
kubectl get pods -n <ns>
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous
kubectl get events -n <ns> --sort-by=.lastTimestamp
```

## Deployment

```bash
kubectl rollout status deployment/<deploy> -n <ns>
kubectl rollout history deployment/<deploy> -n <ns>
kubectl rollout undo deployment/<deploy> -n <ns>
```

## Service Networking

```bash
kubectl get svc -n <ns>
kubectl get endpoints -n <ns>
kubectl get pods --show-labels -n <ns>
```

## Common Issues

CrashLoopBackOff:

```text
App crash, bad command, missing env/secret, dependency failure, permission issue.
```

ImagePullBackOff:

```text
Wrong image/tag, registry permission, repo missing, network to registry.
```

Pending:

```text
Insufficient resources, taints, node selector, PVC, quota.
```

Service no endpoints:

```text
Selector labels mismatch or pods not ready.
```

