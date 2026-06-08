# 05 - Kubernetes And GitOps Deployment Guide

## Namespace

Application namespace:

```text
ecommerce
```

Check:

```bash
kubectl get ns
kubectl get all -n ecommerce
```

## Deployments

Files:

```text
k8s/deployments/catalog-deployment.yaml
k8s/deployments/other-deployments.yaml
k8s/deployments/frontend-deployment.yaml
```

Check:

```bash
kubectl get deploy -n ecommerce
kubectl get pods -n ecommerce
kubectl describe deploy api-gateway -n ecommerce
```

Important deployment features:

- 2 replicas for services.
- Rolling update strategy.
- Readiness probes.
- Liveness probes.
- Resource requests/limits.
- Security context.
- Prometheus scrape annotations.

## Services

File:

```text
k8s/services/services.yaml
```

Service type:

```text
ClusterIP
```

Meaning:

```text
Services are internal to the cluster. Public access goes through ingress/load balancer.
```

Check:

```bash
kubectl get svc -n ecommerce
kubectl get endpoints -n ecommerce
```

If service has no endpoints:

```text
Check selector labels and pod readiness.
```

## HPA

File:

```text
k8s/hpa/hpa.yaml
```

Scaling rules:

- Catalog: min 2, max 20, CPU 60%, memory 70%.
- Cart: min 2, max 15, CPU 60%.
- Payment: min 2, max 10, CPU 50%.
- API gateway: min 2, max 20, CPU 55%.
- Frontend HPA is also defined in frontend deployment YAML.

Check:

```bash
kubectl get hpa -n ecommerce
kubectl describe hpa catalog-hpa -n ecommerce
```

Interview line:

```text
HPA scales pods based on resource metrics. Payment has a lower CPU threshold because it is more critical.
```

## ArgoCD

File:

```text
argocd/apps.yaml
```

What it watches:

```text
repoURL: https://github.com/ajithvnr2001/gcp-infra-end-to-end
targetRevision: main
path: k8s
```

Sync policy:

```text
automated
prune: true
selfHeal: true
```

Meaning:

- Automated: ArgoCD applies Git changes.
- Prune: deleted Git resources are deleted from cluster.
- Self-heal: manual cluster drift is reverted.

Check:

```bash
kubectl get application -n argocd
kubectl describe application ecommerce-catalog -n argocd
```

Access UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open:

```text
https://localhost:8080
```

## Cloud Build Deployment Flow

File:

```text
cloudbuild.yaml
```

Steps:

1. Ensure Artifact Registry repo exists.
2. Build catalog image.
3. Build cart image.
4. Build payment image.
5. Build API gateway image.
6. Build frontend image.
7. Push all images to Artifact Registry.
8. Update Kubernetes manifest image tags.
9. Commit and push manifest changes.
10. ArgoCD syncs the updated manifests.

Important image path:

```text
us-central1-docker.pkg.dev/$PROJECT_ID/ecommerce-docker/<service>:<tag>
```

Interview line:

```text
Cloud Build creates the artifact, ArgoCD deploys the desired state. This separates CI from CD.
```

## Rollback

Rollback options:

```bash
kubectl rollout history deployment/api-gateway -n ecommerce
kubectl rollout undo deployment/api-gateway -n ecommerce
```

GitOps rollback:

```text
Revert manifest image tag in Git and let ArgoCD sync.
```

Best answer:

```text
For GitOps, rollback should happen through Git when possible so desired state remains consistent.
```

