# 06 - Monitoring And Observability Guide

## What To Monitor

Use the four golden signals:

```text
Latency
Traffic
Errors
Saturation
```

For this project:

| Signal | What To Watch |
|---|---|
| Latency | API gateway latency, catalog/product latency, payment/order latency |
| Traffic | Requests per second per service |
| Errors | 4xx/5xx rate, upstream failures |
| Saturation | CPU, memory, pod count, HPA scaling, DB connections |

## Access Grafana

Command from log:

```bash
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
```

Open:

```text
http://localhost:3000
```

Check:

- Request rate.
- Error rate.
- P95/P99 latency.
- CPU by pod.
- Memory by pod.
- HPA scaling.
- Pod restarts.
- Payment SLO.

## Access Prometheus

Command from log:

```bash
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
```

Open:

```text
http://localhost:9090
```

Queries:

```promql
up
http_requests_total
rate(http_requests_total[5m])
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
kube_deployment_status_replicas
kube_pod_status_phase
container_cpu_usage_seconds_total
container_memory_working_set_bytes
```

## Catalog Metrics

Catalog service exposes:

```text
GET /metrics
```

Metrics:

```text
http_requests_total
http_request_duration_seconds
```

Check manually:

```bash
kubectl port-forward svc/catalog-service -n ecommerce 8000:8000
curl http://localhost:8000/metrics
```

## Logs

Check Kubernetes logs:

```bash
kubectl logs deploy/api-gateway -n ecommerce
kubectl logs deploy/catalog-service -n ecommerce
kubectl logs deploy/cart-service -n ecommerce
kubectl logs deploy/payment-service -n ecommerce
kubectl logs deploy/frontend-service -n ecommerce
```

Previous crashed container logs:

```bash
kubectl logs <pod> -n ecommerce --previous
```

## Tracing

Catalog includes OpenTelemetry setup.

Local stack includes:

- OpenTelemetry Collector.
- Jaeger.

Local Jaeger:

```text
http://localhost:16686
```

Production-style explanation:

```text
Tracing lets me follow one request from gateway to backend service and identify where latency is introduced.
```

## SLO Explanation

From project monitoring guide:

```text
Payment service can have 99.9% availability SLO. Error budget is 0.1%. Burn-rate alerts detect when errors consume the budget too quickly.
```

Interview answer:

```text
I would define SLOs for critical flows like checkout/payment, then alert on burn rate instead of only raw CPU. This connects alerts to user impact.
```

## What To Say In Interviews

```text
I monitor the platform at three levels: application metrics from services, Kubernetes metrics from cluster state, and infrastructure metrics from cloud services. For incidents, I start with golden signals and then drill into logs, traces, pod events, and recent deployments.
```

