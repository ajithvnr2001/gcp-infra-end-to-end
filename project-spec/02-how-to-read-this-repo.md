# 02 - How To Read This Repo

Read this project layer by layer. Do not start randomly.

## Layer 1 - Application Services

Path:

```text
services/
```

Services:

```text
services/frontend
services/api-gateway
services/catalog
services/cart
services/payment
```

What to check:

- `main.py` for backend routes.
- `Dockerfile` for container build.
- `requirements.txt` for Python dependencies.
- `tests/` for unit/API tests.
- `frontend/nginx.conf` for API proxying.

## Layer 2 - Local Development

Path:

```text
local-dev/docker-compose.yaml
```

What it does:

- Runs postgres.
- Runs all backend services.
- Runs frontend.
- Runs Prometheus.
- Runs Grafana.
- Runs Loki.
- Runs OpenTelemetry Collector.
- Runs Jaeger.

Why it matters:

```text
It lets you explain how to test the full system without GCP.
```

## Layer 3 - Kubernetes

Path:

```text
k8s/
```

Important files:

```text
k8s/deployments/
k8s/services/services.yaml
k8s/hpa/hpa.yaml
k8s/configmaps/configmaps.yaml
k8s/security/
k8s/tracing/otel-collector.yaml
```

What to check:

- Deployment replica count.
- Container image.
- Ports.
- Env vars.
- Resource requests/limits.
- Liveness/readiness probes.
- Service selectors and target ports.
- HPA scaling rules.
- Security context.

## Layer 4 - Infrastructure

Path:

```text
terraform/
```

Important files:

```text
terraform/envs/prod/main.tf
terraform/modules/vpc/
terraform/modules/gke/
terraform/modules/cloudsql/
```

What it does:

- Configures GCS backend for Terraform state.
- Provisions VPC.
- Provisions GKE.
- Provisions Cloud SQL.

Interview line:

```text
Terraform separates infrastructure from manual console work and makes the environment reproducible.
```

## Layer 5 - CI/CD

File:

```text
cloudbuild.yaml
```

What to check:

- Artifact Registry repository creation.
- Docker build steps.
- Image tags.
- Image push list.
- Manifest update step.
- Git push step.

Important:

```text
The image registry is Artifact Registry, not legacy gcr.io.
```

## Layer 6 - GitOps

File:

```text
argocd/apps.yaml
```

What it does:

- Points ArgoCD to GitHub repo.
- Uses path `k8s`.
- Enables automated sync.
- Enables prune and self-heal.

Interview line:

```text
ArgoCD makes Git the source of truth and prevents manual drift.
```

## Layer 7 - Observability

Path:

```text
monitoring/
```

What to read:

```text
monitoring/OBSERVABILITY.md
monitoring/prometheus/values.yaml
monitoring/grafana/
monitoring/slo/
monitoring/alerts/
```

What to explain:

- Metrics: Prometheus.
- Dashboards: Grafana.
- Logs: structured logs / Loki locally / Cloud Logging pattern.
- Traces: OpenTelemetry.
- SLOs: error budget and burn-rate alerts.

## Best Reading Order For Interviews

```text
README.md
services/api-gateway/main.py
services/catalog/main.py
services/cart/main.py
services/payment/main.py
services/frontend/nginx.conf
local-dev/docker-compose.yaml
k8s/deployments/
k8s/services/services.yaml
k8s/hpa/hpa.yaml
cloudbuild.yaml
argocd/apps.yaml
terraform/envs/prod/main.tf
monitoring/OBSERVABILITY.md
```

