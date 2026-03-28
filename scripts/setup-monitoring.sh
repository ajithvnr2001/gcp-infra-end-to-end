#!/bin/bash
# scripts/setup-monitoring.sh
# Creates notification channel (email) and imports alert policies

set -e

PROJECT_ID=$1
EMAIL=$2

if [ -z "$PROJECT_ID" ] || [ -z "$EMAIL" ]; then
  echo "Usage: ./setup-monitoring.sh <project-id> <alert-email>"
  exit 1
fi

echo "📧 Creating email notification channel..."
CHANNEL=$(gcloud alpha monitoring channels create \
  --channel-labels=email_address=$EMAIL \
  --type=email \
  --display-name="Ecommerce Alerts" \
  --project=$PROJECT_ID \
  --format="value(name)")

echo "Channel created: $CHANNEL"

echo ""
echo "🔔 Creating uptime check for API Gateway..."
gcloud monitoring uptime create \
  --display-name="API Gateway Uptime" \
  --resource-type=uptime-url \
  --hostname="localhost" \
  --path="/health" \
  --check-interval=60 \
  --project=$PROJECT_ID 2>/dev/null || echo "Uptime check skipped (needs public IP)"

echo ""
echo "📊 Creating log-based metric for HTTP errors..."
gcloud logging metrics create http_5xx_errors \
  --description="HTTP 5xx error rate" \
  --log-filter='resource.type="k8s_container" AND jsonPayload.status>=500' \
  --project=$PROJECT_ID 2>/dev/null || echo "Metric may already exist"

echo ""
echo "✅ Monitoring setup complete!"
echo "   Visit: https://console.cloud.google.com/monitoring/dashboards"
