#!/bin/bash
# security/secrets-management/seed-secrets.sh
# Creates all secrets in GCP Secret Manager.
# Run ONCE during initial setup. After this, all secrets are managed in Secret Manager.
#
# Usage: ./seed-secrets.sh <project-id>

set -e

PROJECT_ID=$1
if [ -z "$PROJECT_ID" ]; then
  echo "Usage: ./seed-secrets.sh <project-id>"
  exit 1
fi

echo "🔐 Seeding secrets into GCP Secret Manager..."
echo "   Project: $PROJECT_ID"
echo ""

# Enable Secret Manager API
gcloud services enable secretmanager.googleapis.com --project=$PROJECT_ID

create_secret() {
  local SECRET_NAME=$1
  local SECRET_VALUE=$2
  echo -n "$SECRET_VALUE" | gcloud secrets create "$SECRET_NAME" \
    --data-file=- \
    --replication-policy=automatic \
    --project="$PROJECT_ID" 2>/dev/null || \
  echo -n "$SECRET_VALUE" | gcloud secrets versions add "$SECRET_NAME" \
    --data-file=- \
    --project="$PROJECT_ID"
  echo "  ✅ $SECRET_NAME"
}

# ── Database credentials ───────────────────────────────────────────────────
echo "Database credentials:"
create_secret "ecommerce-catalog-db-user" "appuser"
create_secret "ecommerce-catalog-db-pass" "$(openssl rand -base64 32)"
create_secret "ecommerce-payment-db-user" "appuser"
create_secret "ecommerce-payment-db-pass" "$(openssl rand -base64 32)"

# ── Payment gateway (replace with real Razorpay keys) ─────────────────────
echo ""
echo "Payment gateway:"
create_secret "ecommerce-razorpay-key-id"     "rzp_test_REPLACE_ME"
create_secret "ecommerce-razorpay-key-secret" "REPLACE_WITH_REAL_SECRET"

# ── Session secrets ────────────────────────────────────────────────────────
echo ""
echo "Session secrets:"
create_secret "ecommerce-cart-session-secret" "$(openssl rand -base64 64)"

echo ""
echo "✅ All secrets created in GCP Secret Manager"
echo ""
echo "View secrets:"
echo "  gcloud secrets list --project=$PROJECT_ID"
echo ""
echo "Grant ESO service account access:"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:ecommerce-workload@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor" --quiet
echo "  ✅ IAM binding added"
