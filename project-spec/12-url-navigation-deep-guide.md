# 12 - Deep URL Navigation Guide

This guide explains how to open each URL from `log.txt`, what options to click, what each screen means, how it relates to this project, and what to say in interviews.

## Live Curl Findings

These checks were performed against the current local port-forwarded endpoints.

| URL | Curl Result | Meaning |
|---|---|---|
| `http://localhost:3000` | `302 /login` | Grafana is reachable and requires login. |
| `http://localhost:3000/api/health` | `database: ok`, `version: 13.0.1` | Grafana backend is healthy. |
| `http://localhost:3000/api/datasources` | Prometheus + Alertmanager | Grafana has monitoring datasources configured. |
| `http://localhost:3000/api/search` | Kubernetes, Prometheus, Node Exporter dashboards | Grafana dashboards are provisioned. |
| `http://localhost:9090` | Prometheus responds; `/graph` redirects to `/query` | Prometheus is reachable. |
| `http://localhost:9090/api/v1/label/job/values` | jobs include `ecommerce-services`, `kubelet`, `node-exporter`, `apiserver`, etc. | Prometheus is scraping Kubernetes and app targets. |
| `http://localhost:9090/api/v1/query?query=up{job="ecommerce-services"}` | catalog targets up; api-gateway/cart/payment down | Catalog exposes `/metrics`; other app services are annotated for `/metrics` but currently return 404. |
| `http://localhost:8080` | `307` redirect to HTTPS | ArgoCD server is reachable via HTTP redirect. |
| `https://localhost:8080` | Windows curl TLS error | Browser should still be used; curl failed due local TLS/Schannel handling. |
| `http://localhost/` | `308` redirect to HTTPS | Ingress-nginx is reachable and forces HTTPS. |
| `https://localhost/` | Windows curl TLS error | Browser should still be used; curl failed due local TLS/Schannel handling. |

Important real observation:

```text
Prometheus target health shows catalog-service is up for /metrics, but api-gateway, cart-service, and payment-service are down for /metrics because their pods are annotated for Prometheus scraping but their apps do not currently expose /metrics.
```

Interview-ready explanation:

```text
The services may be functionally healthy through /health and /ready, but Prometheus scraping can still show down if the configured metrics endpoint returns 404. That means monitoring configuration and application instrumentation must match.
```

## URL 1 - ArgoCD

URL:

```text
https://localhost:8080
```

Port-forward:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Login:

```text
User: admin
Password: from argocd-initial-admin-secret or log.txt
```

Security note:

```text
If a password is visible in log.txt, treat it as exposed and rotate it in real production.
```

### What To Click

After login, you should see an application card:

```text
ecommerce-catalog
```

Click it.

### What Each Option Means

Sync Status:

```text
Synced means cluster state matches Git.
OutOfSync means Git and cluster differ.
```

Health Status:

```text
Healthy means resources are running correctly.
Progressing means rollout is still happening.
Degraded means one or more resources failed.
```

Tree View:

```text
Shows Kubernetes resources created from k8s/ folder: namespace, deployments, services, HPA, configmaps, security resources.
```

Diff:

```text
Shows difference between desired Git state and live cluster state.
Use this when someone manually edited the cluster or a generated field changed.
```

Sync Button:

```text
Manually applies Git desired state to cluster.
```

Refresh Button:

```text
Forces ArgoCD to re-check Git and cluster state.
```

App Details:

```text
Shows repo URL, path k8s, target revision main, destination cluster, sync policy.
```

Events:

```text
Useful for sync errors, missing CRDs, RBAC errors, invalid manifests, prune errors.
```

### How It Relates To This Project

ArgoCD reads:

```text
argocd/apps.yaml
```

It points to:

```text
repoURL: https://github.com/ajithvnr2001/gcp-infra-end-to-end
path: k8s
targetRevision: main
```

So any Kubernetes YAML under `k8s/` becomes desired state.

### What To Check Daily

```text
Application = ecommerce-catalog
Sync = Synced
Health = Healthy
No failed resources
No unexpected diff
No stuck sync operation
```

### Interview Explanation

```text
ArgoCD is the GitOps controller. Cloud Build updates image tags in Git, then ArgoCD detects the Git change and syncs the Kubernetes manifests to GKE. This gives auditability, rollback through Git, and drift detection.
```

### Common Problems

OutOfSync:

```text
Someone changed cluster manually, generated field differs, or Git has new changes not synced.
```

Degraded:

```text
Deployment failed, pods not ready, image pull issue, invalid config, or service dependency problem.
```

Sync failed:

```text
Invalid YAML, missing namespace, missing CRD, RBAC issue, or immutable field change.
```

## URL 2 - Grafana

URL:

```text
http://localhost:3000
```

Port-forward:

```bash
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
```

Login:

```text
User: admin
Password: admin
```

Live curl confirmed:

```json
{
  "database": "ok",
  "version": "13.0.1",
  "commit": "a100054f"
}
```

### What To Click

1. Login.
2. Open left menu.
3. Go to Dashboards.
4. Search dashboards.
5. Open Kubernetes dashboards first.
6. Open Explore for ad-hoc Prometheus queries.
7. Open Alerting to inspect alert rules.
8. Open Connections / Data sources if checking Prometheus datasource.

### Datasources Found

Curl confirmed:

```text
Prometheus
Alertmanager
```

Prometheus datasource:

```text
http://kube-prometheus-stack-prometheus.monitoring:9090/
```

Alertmanager datasource:

```text
http://kube-prometheus-stack-alertmanager.monitoring:9093/
```

### Dashboards Found

Curl found dashboards including:

```text
Kubernetes / Compute Resources / Cluster
Kubernetes / Compute Resources / Namespace (Pods)
Kubernetes / Compute Resources / Namespace (Workloads)
Kubernetes / Compute Resources / Pod
Kubernetes / Compute Resources / Workload
Kubernetes / Networking / Cluster
Kubernetes / Networking / Namespace (Pods)
Kubernetes / Networking / Workload
Kubernetes / API server
Kubernetes / Kubelet
Kubernetes / Persistent Volumes
CoreDNS
Prometheus / Overview
Alertmanager / Overview
Node Exporter / Nodes
Grafana Overview
```

### Which Dashboard To Use For What

Kubernetes / Compute Resources / Namespace (Pods):

```text
Use this for pod CPU/memory in namespace ecommerce.
```

Kubernetes / Compute Resources / Workload:

```text
Use this to check deployment-level CPU/memory for api-gateway, catalog, cart, payment, frontend.
```

Kubernetes / Networking / Namespace (Pods):

```text
Use this for network traffic by pod.
```

Kubernetes / Pod:

```text
Use this when one specific pod is slow or restarting.
```

Prometheus / Overview:

```text
Use this to check Prometheus health and scrape performance.
```

Alertmanager / Overview:

```text
Use this to check active alerts, silences, and notification health.
```

CoreDNS:

```text
Use this when service DNS resolution fails inside cluster.
```

### How To Read Grafana Panels

CPU:

```text
High CPU means service may need scaling, optimization, or resource request/limit tuning.
```

Memory:

```text
Increasing memory without drop may indicate leak. OOMKilled means limit too low or app memory issue.
```

Network:

```text
Traffic spike can explain CPU and latency spike.
```

Restarts:

```text
Restarts indicate app crash, OOM, liveness probe failure, node issue, or deployment rollout.
```

Latency:

```text
High P95/P99 means users are affected even if average looks fine.
```

Error rate:

```text
5xx means server/upstream issue. 4xx may be user/client/API contract issue.
```

### Project-Specific Grafana Reality

Prometheus target data shows:

```text
catalog-service = up for /metrics
api-gateway = down for /metrics
cart-service = down for /metrics
payment-service = down for /metrics
```

Why:

```text
catalog-service exposes /metrics.
api-gateway, cart-service, and payment-service are annotated for /metrics scraping but code currently does not define /metrics endpoints.
```

What this means:

```text
The services can still be healthy through /health and /ready, but Prometheus will mark scrape targets down if /metrics returns 404.
```

Fix options:

```text
Add Prometheus /metrics endpoint to api-gateway, cart, payment.
Or remove prometheus scrape annotations from services that do not expose /metrics.
```

Interview line:

```text
Monitoring configuration must match application instrumentation. A healthy app can still show as a failed scrape if the metrics endpoint is misconfigured.
```

## URL 3 - Prometheus

URL:

```text
http://localhost:9090
```

Port-forward:

```bash
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
```

### What To Click

Prometheus newer UI may redirect `/graph` to:

```text
/query
```

Main areas:

```text
Query
Alerts
Status -> Targets
Status -> Service Discovery
Status -> Configuration
Status -> Runtime & Build Information
```

### Query Page

Use it to run PromQL.

Start with:

```promql
up
```

Project-specific:

```promql
up{job="ecommerce-services"}
```

Meaning:

```text
1 = target scrape healthy
0 = target scrape failed
```

Live observation:

```text
catalog-service targets returned 1.
api-gateway, cart-service, payment-service returned 0 because /metrics returns 404.
```

### Targets Page

Navigation:

```text
Status -> Targets
```

What to check:

```text
Job name
Endpoint URL
Last scrape
Scrape duration
Health
Last error
Labels
```

Important job found:

```text
ecommerce-services
```

Other jobs found:

```text
apiserver
coredns
kubelet
kube-state-metrics
node-exporter
kube-prometheus-stack-grafana
kube-prometheus-stack-prometheus
kube-prometheus-stack-operator
kube-proxy
```

### Useful PromQL Queries

All target health:

```promql
up
```

Only ecommerce services:

```promql
up{job="ecommerce-services"}
```

Catalog request rate:

```promql
rate(http_requests_total{service="catalog-service"}[5m])
```

Catalog P95 latency:

```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{service="catalog-service"}[5m]))
```

Pod phase:

```promql
kube_pod_status_phase{namespace="ecommerce"}
```

Deployment replicas:

```promql
kube_deployment_status_replicas{namespace="ecommerce"}
```

Container CPU:

```promql
rate(container_cpu_usage_seconds_total{namespace="ecommerce"}[5m])
```

Container memory:

```promql
container_memory_working_set_bytes{namespace="ecommerce"}
```

### How Prometheus Relates To This Project

Prometheus reads Kubernetes labels/annotations and scrapes metrics endpoints.

In deployment YAML:

```yaml
prometheus.io/scrape: "true"
prometheus.io/path: "/metrics"
prometheus.io/port: "8000"
```

For catalog this works because `/metrics` exists.

For cart/payment/api-gateway this currently fails because `/metrics` is not implemented in code.

### Interview Explanation

```text
Prometheus is the metrics backend. I use the Targets page to verify scrape health, Query page for PromQL, and Alerts page for alert state. In this project, Prometheus clearly shows which app services expose metrics correctly and which need instrumentation fixes.
```

## URL 4 - Frontend / Ingress

URL from log:

```text
https://localhost/
```

Port-forward:

```bash
kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 80:80 443:443
```

Live curl:

```text
http://localhost/ returns 308 Permanent Redirect to https://localhost
```

Windows curl issue:

```text
https://localhost/ failed from curl due Schannel local TLS handling.
Use browser for this URL.
```

### What To Click In Frontend

Open:

```text
https://localhost/
```

Then test:

1. Product list loads.
2. Search product.
3. Filter category.
4. Sort product.
5. Add item to cart.
6. Open cart drawer.
7. Update quantity.
8. Remove item.
9. Fill checkout form.
10. Place order.
11. Check order confirmation/history.

### Browser DevTools Checks

Open DevTools -> Network.

Watch API calls:

```text
GET /api/products
POST /api/cart/{user_id}/add
PUT /api/cart/{user_id}/items/{product_id}
POST /api/orders
GET /api/orders/user/{user_id}
```

What good looks like:

```text
2xx responses
JSON response body
No CORS error
No 502/503 from gateway/ingress
```

What bad looks like:

```text
404 = wrong route/path
502 = ingress/gateway/backend failure
503 = upstream unavailable
500 = app error
CORS error = frontend/API origin/header issue
```

### How Frontend Relates To Services

Frontend does not directly call catalog/cart/payment. It goes through API gateway.

```text
Frontend -> API Gateway -> internal services
```

Why:

```text
Frontend stays simple.
Internal service topology is hidden.
Gateway can centralize auth/routing/rate limiting/tracing later.
```

### If Frontend Page Loads But Products Do Not

Check in order:

```bash
kubectl logs deploy/frontend-service -n ecommerce
kubectl logs deploy/api-gateway -n ecommerce
kubectl logs deploy/catalog-service -n ecommerce
kubectl get endpoints -n ecommerce
```

Then:

```bash
kubectl port-forward svc/api-gateway -n ecommerce 8080:8080
curl http://localhost:8080/products
```

### Interview Explanation

```text
The frontend is the user entry point. I validate it from browser behavior, network requests, ingress routing, gateway logs, and backend service logs. If UI loads but data fails, I trace /api calls from frontend to gateway to backend service.
```

## How To Use These URLs During Interview Preparation

Daily 15-minute routine:

```text
1. Open ArgoCD and check app sync/health.
2. Open Grafana and check Kubernetes namespace/workload dashboards.
3. Open Prometheus Targets and check ecommerce-services target health.
4. Open frontend and complete one checkout flow.
5. If something fails, use VERDICT and write the root cause.
```

## Current Monitoring Gap To Mention Honestly

Observation:

```text
Only catalog-service currently exposes /metrics correctly. Other ecommerce services are configured for scraping but do not expose /metrics, so Prometheus marks them down.
```

How to phrase:

```text
This is a good observability improvement item. I would either add Prometheus middleware and /metrics endpoints to api-gateway, cart, and payment, or remove scrape annotations until they are instrumented.
```

This is a strong interview point because it shows you can read monitoring correctly instead of assuming "service down" means "application down."

