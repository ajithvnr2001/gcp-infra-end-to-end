#!/bin/bash
# scripts/setup-backend.sh
# Run this ONCE before terraform init — creates GCS bucket for remote state

set -e

PROJECT_ID=$1
REGION=${2:-asia-south1}
BUCKET_NAME="tf-state-ecommerce-prod-$PROJECT_ID"

if [ -z "$PROJECT_ID" ]; then
  echo "Usage: ./setup-backend.sh <project-id> [region]"
  exit 1
fi

echo "📦 Creating GCS bucket for Terraform state..."
gcloud storage buckets create gs://$BUCKET_NAME \
  --project=$PROJECT_ID \
  --location=$REGION \
  --uniform-bucket-level-access || echo "Bucket might already exist"

echo "🔒 Enabling versioning on state bucket..."
gcloud storage buckets update gs://$BUCKET_NAME --versioning

echo "✅ Backend bucket ready: gs://$BUCKET_NAME"
echo ""
echo "Next step:"
echo "  cd terraform/envs/prod && terraform init"
