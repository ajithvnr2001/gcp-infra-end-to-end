#!/bin/bash
# scripts/setup-observability.sh
# Installs the full observability stack in order:
#   1. Prometheus + Grafana                 (kube-prometheus-stack free-trial profile)
#   2. Loki + Promtail                      (log aggregation)
#   3. OpenTelemetry Collector              (distributed tracing -> Cloud Trace)
#   4. Deploys SLO burn-rate alert rules
#   5. Sets up GCP Cloud Trace service account

set -e

PROJECT_ID=$1
if [ -z "$PROJECT_ID" ]; then
  echo "Usage: ./setup-observability.sh <gcp-project-id>"
  exit 1
fi

echo "=================================================="
echo " Full Observability Stack Setup"
echo " Project: $PROJECT_ID"
echo "=================================================="
echo ""

# ── Step 1: Prometheus + Grafana ──────────────────────────────────────────────
echo "📊 Step 1: Installing kube-prometheus-stack..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values monitoring/prometheus/values.yaml \
  --wait --timeout 10m

echo "✅ Prometheus + Grafana installed"

# ── Step 2: Loki log aggregation ─────────────────────────────────────────────
echo ""
echo "📋 Step 2: Installing Loki + Promtail (log aggregation)..."
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring \
  --values monitoring/loki/loki-values.yaml \
  --wait --timeout 5m

echo "✅ Loki + Promtail installed"

# ── Step 3: OpenTelemetry Collector ──────────────────────────────────────────
echo ""
echo "🔭 Step 3: Setting up OpenTelemetry Collector for Cloud Trace..."

# Create GCP service account for Cloud Trace
SA_NAME="otel-collector"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud iam service-accounts create $SA_NAME \
  --display-name="OTel Collector — Cloud Trace" \
  --project=$PROJECT_ID 2>/dev/null || echo "SA already exists"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/cloudtrace.agent" --quiet

# Bind GCP SA to K8s SA (Workload Identity)
gcloud iam service-accounts add-iam-policy-binding $SA_EMAIL \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:${PROJECT_ID}.svc.id.goog[monitoring/otel-collector-sa]" --quiet

# Replace project ID placeholder in otel config
sed -i "s/YOUR_GCP_PROJECT_ID/$PROJECT_ID/g" k8s/tracing/otel-collector.yaml

# Deploy OTel collector
kubectl apply -f k8s/tracing/otel-collector.yaml
echo "✅ OpenTelemetry Collector deployed"

# ── Step 4: Apply SLO burn-rate alert rules ───────────────────────────────────
echo ""
echo "🎯 Step 4: Applying SLO burn-rate alert rules..."
kubectl apply -f monitoring/slo/burn-rate-alerts.yaml -n monitoring 2>/dev/null || \
  kubectl create configmap slo-alerts \
    --from-file=monitoring/slo/burn-rate-alerts.yaml \
    -n monitoring --dry-run=client -o yaml | kubectl apply -f -
echo "✅ SLO alerts configured"

# ── Step 5: Apply Prometheus scrape annotations ───────────────────────────────
echo ""
echo "🏷️  Step 5: Patching deployments with Prometheus scrape annotations..."
kubectl apply -f k8s/monitoring/prometheus-scrape-patch.yaml
echo "✅ Scrape annotations applied"

# ── Step 6: Import Grafana dashboard ─────────────────────────────────────────
echo ""
echo "📈 Step 6: Importing Grafana dashboard..."
GRAFANA_POD=$(kubectl get pod -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath="{.items[0].metadata.name}")
kubectl cp monitoring/grafana/dashboards/ecommerce-overview.json \
  monitoring/$GRAFANA_POD:/var/lib/grafana/dashboards/ 2>/dev/null || \
  echo "  (Dashboard will auto-load via provisioning)"
echo "✅ Dashboard ready"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "=================================================="
echo " ✅ Observability Stack COMPLETE!"
echo "=================================================="
echo ""
echo "Access Grafana:"
echo "  kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80"
echo "  Open: http://localhost:3000  (admin / admin)"
echo ""
echo "Access Prometheus:"
echo "  kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090"
echo "  Open: http://localhost:9090"
echo ""
echo "Alertmanager:"
echo "  Disabled in monitoring/prometheus/values.yaml for the free-trial profile."
echo "  Enable it for production clusters with enough capacity."
echo ""
echo "View Cloud Trace:"
echo "  https://console.cloud.google.com/traces?project=$PROJECT_ID"
echo ""
echo "View Cloud Logging (structured JSON):"
echo "  https://console.cloud.google.com/logs?project=$PROJECT_ID"
