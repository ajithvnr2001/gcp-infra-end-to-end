#!/bin/bash
# scripts/setup-cloudbuild-trigger.sh
# ─────────────────────────────────────────────────────────────────────────────
# Sets up an automated Cloud Build Trigger so every `git push` to `main`
# automatically builds Docker images and kicks off an ArgoCD deployment.
#
# Run once: ./scripts/setup-cloudbuild-trigger.sh
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

PROJECT_ID="practice-test1-494717"
REPO_NAME="gcp-infra-end-to-end"
REPO_OWNER="ajithvnr2001"
BRANCH="main"

echo "=== Setting up Cloud Build CI/CD Trigger ==="

# 1. Connect GitHub repo to Cloud Build (one-time step)
# This links your GitHub account to GCP Cloud Build
echo "Step 1: Connecting GitHub repository to Cloud Build..."
echo "  → Open the Cloud Console to connect: https://console.cloud.google.com/cloud-build/triggers/connect"
echo "  → Choose GitHub, authorize, and select: $REPO_OWNER/$REPO_NAME"
echo ""
echo "  (Press ENTER after connecting the repo in the Console)"
read -r

# 2. Create the trigger
echo "Step 2: Creating the Cloud Build trigger..."
gcloud builds triggers create github \
  --project="$PROJECT_ID" \
  --repo-name="$REPO_NAME" \
  --repo-owner="$REPO_OWNER" \
  --branch-pattern="^$BRANCH$" \
  --build-config="cloudbuild.yaml" \
  --name="ecommerce-ci-pipeline" \
  --description="Auto-build and push all microservice images on push to main"

echo "✅ Trigger created!"
echo ""

# 3. Grant Cloud Build permission to push to GitHub (for the manifest update step)
echo "Step 3: Granting Cloud Build service account access to push to GitHub..."
BUILD_SA="$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com"
echo "  Cloud Build SA: $BUILD_SA"
echo "  → Add this email as a collaborator or deploy key to your GitHub repo"
echo "  → Or use a GitHub Secret stored in GCP Secret Manager for the push step"
echo ""

# 4. Test the trigger
echo "Step 4: Manually triggering the pipeline to test..."
gcloud builds triggers run ecommerce-ci-pipeline \
  --project="$PROJECT_ID" \
  --branch="$BRANCH"

echo ""
echo "=== DONE ==="
echo "From now on, every 'git push' to 'main' will automatically:"
echo "  1. Build all 5 Docker images in parallel (~45-60 seconds)"
echo "  2. Push them to Artifact Registry with commit SHA tag"
echo "  3. Update k8s/deployments/ manifests with the new tag"
echo "  4. ArgoCD detects the git change and rolls out new pods (~30 seconds)"
echo ""
echo "Total time from code push to pods running: ~2 minutes"
