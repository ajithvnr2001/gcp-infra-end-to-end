#!/bin/bash
# scripts/setup-gcp.sh
# Run this FIRST — enables APIs and creates a service account for GitHub Actions

set -e

PROJECT_ID=$1
if [ -z "$PROJECT_ID" ]; then
  echo "Usage: ./setup-gcp.sh <project-id>"
  exit 1
fi

echo "🔧 Setting project: $PROJECT_ID"
gcloud config set project $PROJECT_ID

echo ""
echo "🚀 Enabling required GCP APIs..."
gcloud services enable \
  container.googleapis.com \
  sqladmin.googleapis.com \
  cloudbuild.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  artifactregistry.googleapis.com \
  compute.googleapis.com \
  servicenetworking.googleapis.com \
  cloudresourcemanager.googleapis.com

echo ""
echo "📦 Creating Artifact Registry Docker repository..."
gcloud artifacts repositories create ecommerce-docker \
  --repository-format=docker \
  --location=us-central1 \
  --description="Docker images for ecommerce services" \
  --project="$PROJECT_ID" \
  --quiet 2>/dev/null || echo "Repository already exists, continuing."

echo ""
echo "👤 Creating GitHub Actions service account..."
SA_NAME="github-actions-sa"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud iam service-accounts create $SA_NAME \
  --display-name="GitHub Actions CI/CD" \
  --project=$PROJECT_ID

echo "🔑 Granting required roles..."
for ROLE in \
  roles/container.admin \
  roles/storage.admin \
  roles/iam.serviceAccountUser \
  roles/monitoring.editor \
  roles/logging.logWriter; do
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="$ROLE" --quiet
done

echo ""
echo "⚙️  Configuring default Service Account permissions..."
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

# Grant Cloud Build SA permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.builder" --quiet

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/artifactregistry.writer" --quiet

# Grant Compute Engine SA permissions (required for Cloud Build source staging)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/storage.admin" --quiet

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/artifactregistry.reader" --quiet

echo ""
echo "📄 Generating service account key..."
gcloud iam service-accounts keys create github-sa-key.json \
  --iam-account=$SA_EMAIL

echo ""
echo "✅ Done! Next steps:"
echo "  1. Go to GitHub repo → Settings → Secrets → Actions"
echo "  2. Add secret GCP_PROJECT_ID = $PROJECT_ID"
echo "  3. Add secret GCP_SA_KEY = \$(base64 -w 0 github-sa-key.json)"
echo "  4. Delete github-sa-key.json after uploading!"
echo ""
echo "⚠️  NEVER commit github-sa-key.json to git"
