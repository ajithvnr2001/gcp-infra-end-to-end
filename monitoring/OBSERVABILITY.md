# Observability Stack — Full Guide

## What's Included

```
Metrics  → Prometheus (scrape) → Grafana (visualize) → Alertmanager (notify Slack)
Logs     → Promtail (collect)  → Loki (store)        → Grafana (search & query)
Traces   → OpenTelemetry SDK   → OTel Collector       → GCP Cloud Trace
SLOs     → Burn-rate rules     → Prometheus alerts    → Slack / PagerDuty
```

---

## Setup (one command)

```bash
chmod +x scripts/setup-observability.sh
./scripts/setup-observability.sh YOUR_GCP_PROJECT_ID
```

---

## Accessing the Stack

```bash
# Grafana (dashboards + logs via Loki)
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
# Open: http://localhost:3000   (admin / admin)

# Prometheus (raw metrics + alert rules)
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
# Open: http://localhost:9090

# Alertmanager (active alerts + silences)
kubectl port-forward svc/kube-prometheus-stack-alertmanager -n monitoring 9093:9093
# Open: http://localhost:9093
```

GCP Cloud Trace → https://console.cloud.google.com/traces
GCP Cloud Logging → https://console.cloud.google.com/logs

---

## Metrics Available (what Prometheus collects)

### From your services (custom /metrics endpoint):
| Metric | Type | What it tells you |
|--------|------|-------------------|
| `http_requests_total` | Counter | Request rate, error rate by service |
| `http_request_duration_seconds` | Histogram | P50/P95/P99 latency |

### From kube-state-metrics (auto):
| Metric | What it tells you |
|--------|-------------------|
| `kube_pod_status_phase` | Pod running/failed/pending |
| `kube_deployment_status_replicas` | Desired vs available |
| `kube_horizontalpodautoscaler_status_current_replicas` | HPA live replica count |
| `container_cpu_usage_seconds_total` | CPU per container |
| `container_memory_working_set_bytes` | Memory per container |

---

## SLO Burn Rate — How to Explain in Interviews

> "We defined SLOs for each service — for example, payment at 99.9% availability.
> We used multi-window multi-burn-rate alerting from the Google SRE book.
> If payment is burning the error budget at 14x the normal rate, we get an immediate
> critical alert. At 6x burn rate sustained over 6 hours, we get a warning.
> This way we catch issues before the full error budget is exhausted."

**Payment SLO example:**
- SLO target: 99.9% availability = 0.1% error budget
- Monthly error budget: ~43 minutes of downtime/errors
- 14x fast burn alert: 1.4% error rate sustained → budget gone in ~2 hours → PAGE NOW
- 6x slow burn alert:  0.6% error rate sustained → budget gone in ~5 days → investigate

---

## Structured Logging — How it works

Every service emits JSON logs like:
```json
{
  "timestamp": "2024-01-01T10:30:00",
  "severity": "INFO",
  "message": "products listed count=5 category=electronics",
  "service": "catalog-service",
  "environment": "production",
  "logging.googleapis.com/trace": "projects/my-project/traces/abc123...",
  "logging.googleapis.com/spanId": "def456..."
}
```

The `trace` and `spanId` fields are magic — GCP Cloud Logging automatically
**links each log line to its Cloud Trace span**. So you can:
1. See a slow request in Cloud Trace
2. Click it → jump directly to all logs for that exact request
3. See the full path: api-gateway → catalog → DB query

---

## Distributed Tracing — Request Flow

A request to `GET /products` creates spans like:

```
api-gateway (50ms)
  └── catalog-service (35ms)
        └── list_products (30ms)
              └── DB query (25ms)   ← Cloud SQL
```

You can view this waterfall in GCP Cloud Trace console.
It shows you exactly where latency is coming from.

---

## Grafana Dashboard Panels

| Panel | What to look for |
|-------|-----------------|
| Request Rate | Spikes during flash sale |
| Error Rate % | Should stay < 0.1% |
| P99 Latency | Should stay < 1s |
| Active Pods | Watch HPA scale up |
| Payment SLO | Should stay > 99.9% |
| HPA Replicas | Watch current vs max |
| CPU by Service | Identify hotspots |
| Memory by Service | Detect memory leaks |

---

## Practice Scenarios

```bash
# 1. Trigger a CPU alert → watch Grafana spike, Alertmanager fire
./scripts/load-test.sh http://localhost:8080 100 120

# 2. Break payment service → watch error rate climb, SLO breach alert fire
kubectl exec -n ecommerce deploy/payment-service -- kill 1

# 3. Watch HPA scale during load test
kubectl get hpa -n ecommerce -w

# 4. View traces in Cloud Trace after load test
# https://console.cloud.google.com/traces

# 5. Query logs in Grafana Loki
# {service="payment-service"} | json | severity="ERROR"

# 6. Check remaining error budget
kubectl exec -n monitoring deploy/kube-prometheus-stack-prometheus -- \
  promtool query instant http://localhost:9090 \
  'payment:error_budget_remaining:ratio'
```
