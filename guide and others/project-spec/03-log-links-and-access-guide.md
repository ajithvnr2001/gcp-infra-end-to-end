# 03 - log.txt Links And Access Guide

The links in `log.txt` are not normal public URLs. They are local URLs created by Kubernetes port-forwarding.

## Links Found

| Tool | URL | Purpose |
|---|---|---|
| ArgoCD | `https://localhost:8080` | GitOps app sync/status |
| Grafana | `http://localhost:3000` | Dashboards |
| Prometheus | `http://localhost:9090` | Metrics/query engine |
| Frontend ingress | `https://localhost/` | Ecommerce UI through ingress-nginx |

## ArgoCD

From log:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open:

```text
https://localhost:8080
```

What to check:

- Application name: `ecommerce-catalog`.
- Sync status: `Synced` or `OutOfSync`.
- Health status: `Healthy`, `Progressing`, `Degraded`.
- Resources created from `k8s/`.
- Diff if live cluster differs from Git.
- Events and sync errors.

Interview explanation:

```text
ArgoCD compares desired state in Git with live Kubernetes state. If someone manually changes the cluster, ArgoCD detects drift and can self-heal.
```

Security note:

```text
The password shown in log.txt is sensitive. In real production, do not commit or share it. Rotate it if exposed.
```

## Grafana

From log:

```bash
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
```

Then open:

```text
http://localhost:3000
```

Default shown in log:

```text
User: admin
Password: admin
```

What to check:

- Request rate.
- Error rate.
- Latency.
- CPU per service.
- Memory per service.
- Pod count.
- HPA scaling.
- Payment service SLO.
- Kubernetes pod health.

Interview explanation:

```text
Grafana is the visualization layer. I use it to check golden signals: latency, traffic, errors, and saturation.
```

## Prometheus

From log:

```bash
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
```

Then open:

```text
http://localhost:9090
```

Useful queries:

```promql
up
http_requests_total
rate(http_requests_total[5m])
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
kube_pod_status_phase
container_cpu_usage_seconds_total
container_memory_working_set_bytes
```

What to check:

- Is Prometheus scraping services?
- Are pods up?
- Are request/error metrics present?
- Is latency increasing?
- Is CPU/memory high?

Interview explanation:

```text
Prometheus stores time-series metrics. Grafana visualizes those metrics. Alerts are usually based on PromQL expressions.
```

## Frontend Ingress

From log:

```bash
kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 80:80 443:443
```

Then open:

```text
https://localhost/
```

What to check:

- Storefront loads.
- Products load.
- Cart operations work.
- Checkout works.
- Order history works.
- Browser network tab shows `/api/*` calls.

If frontend does not work:

```bash
kubectl get pods -n ecommerce
kubectl get svc -n ecommerce
kubectl logs deploy/frontend-service -n ecommerce
kubectl logs deploy/api-gateway -n ecommerce
kubectl get ingress -n ecommerce
```

## Ingress Public IP

From log:

```text
Ingress Public IP: 34.122.91.208
```

Meaning:

```text
This was the external IP assigned to ingress-nginx at that time. It can change if the LoadBalancer is recreated.
```

Check current value:

```bash
kubectl get svc ingress-nginx-controller -n ingress-nginx
```

