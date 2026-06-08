# 08 - Troubleshooting Runbook

Use VERDICT:

```text
V - Version/change
E - Environment
R - Resources
D - Dependencies
I - Infra health
C - Connectivity
T - Telemetry
```

## 1. Frontend Not Loading

Check:

```bash
kubectl get pods -n ecommerce
kubectl get svc frontend-service -n ecommerce
kubectl logs deploy/frontend-service -n ecommerce
kubectl get ingress -n ecommerce
kubectl get svc ingress-nginx-controller -n ingress-nginx
```

Likely causes:

- Frontend pod crash.
- NGINX config issue.
- Ingress issue.
- Service selector mismatch.
- Image pull failure.

Fix:

- Check pod events.
- Validate image exists.
- Validate service endpoints.
- Rollback if new image broke frontend.

## 2. Products Not Loading

Flow:

```text
Frontend -> API Gateway -> Catalog Service
```

Check:

```bash
kubectl logs deploy/api-gateway -n ecommerce
kubectl logs deploy/catalog-service -n ecommerce
kubectl port-forward svc/api-gateway -n ecommerce 8080:8080
curl http://localhost:8080/products
kubectl port-forward svc/catalog-service -n ecommerce 8000:8000
curl http://localhost:8000/products
```

Likely causes:

- API gateway cannot reach catalog.
- Catalog pod not ready.
- Service DNS/port mismatch.
- Catalog app error.

## 3. Cart Not Working

Flow:

```text
Frontend -> API Gateway -> Cart Service
```

Check:

```bash
kubectl logs deploy/api-gateway -n ecommerce
kubectl logs deploy/cart-service -n ecommerce
curl http://localhost:8080/cart/test-user
```

Likely causes:

- Wrong request payload.
- Cart service in-memory state reset after pod restart.
- API gateway upstream failure.

Production note:

```text
Cart should use Redis/database in production, not in-memory state.
```

## 4. Checkout / Payment Failing

Flow:

```text
Frontend -> API Gateway -> Payment Service -> Cart clear
```

Check:

```bash
kubectl logs deploy/api-gateway -n ecommerce
kubectl logs deploy/payment-service -n ecommerce
kubectl logs deploy/cart-service -n ecommerce
```

Likely causes:

- Invalid order payload.
- Payment service not ready.
- Payment resource exhaustion.
- Cart clear failed after order.

Production note:

```text
Payment/order creation should be idempotent and persisted to Cloud SQL.
```

## 5. Pod CrashLoopBackOff

Check:

```bash
kubectl describe pod <pod> -n ecommerce
kubectl logs <pod> -n ecommerce
kubectl logs <pod> -n ecommerce --previous
kubectl get events -n ecommerce --sort-by=.lastTimestamp
```

Likely causes:

- App startup error.
- Missing env/config.
- Permission issue.
- Bad image.
- Dependency unavailable.

## 6. ImagePullBackOff

Check:

```bash
kubectl describe pod <pod> -n ecommerce
gcloud artifacts docker images list us-central1-docker.pkg.dev/<PROJECT_ID>/ecommerce-docker
```

Likely causes:

- Wrong image path.
- Image tag missing.
- GKE node lacks Artifact Registry reader permission.
- Repository missing.

Project-specific lesson:

```text
The project previously hit registry push issues due to legacy GCR usage. Artifact Registry should be created explicitly and IAM should be configured.
```

## 7. ArgoCD OutOfSync

Check:

```bash
kubectl get application ecommerce-catalog -n argocd
kubectl describe application ecommerce-catalog -n argocd
```

In UI:

- Check diff.
- Check sync errors.
- Check resource health.

Likely causes:

- Manual cluster change.
- Invalid manifest.
- Missing namespace/CRD.
- Resource conflict.

## 8. Cloud Build Failure

Check:

```bash
gcloud builds list --project <PROJECT_ID>
gcloud builds log <BUILD_ID> --project <PROJECT_ID>
```

If build fails:

- Read failing Docker step.
- Check Dockerfile.
- Check dependencies.
- Check network/package registry.

If push fails:

- Check Artifact Registry repo exists.
- Check Cloud Build service account writer permission.
- Check image path.
- Check project/region.

## 9. Terraform Failure

Check:

```bash
cd terraform/envs/prod
terraform init
terraform plan
terraform apply
```

If plan wants destroy:

```text
Stop. Review variable changes, state, provider changes, resource rename, module changes.
```

If state issue:

```text
Check GCS backend and locking/state consistency.
```

## 10. Monitoring Not Showing Metrics

Check:

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl get pods -n ecommerce -o yaml | findstr prometheus
```

Prometheus:

```promql
up
```

Likely causes:

- Prometheus not running.
- Service not annotated/scraped.
- Metrics endpoint missing.
- Network policy blocking scrape.

