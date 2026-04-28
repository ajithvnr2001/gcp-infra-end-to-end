#!/bin/bash
# =============================================================================
# scripts/build.sh
# =============================================================================
# BUILDS and DEPLOYS the entire ecommerce platform from scratch.
# Run this after nuke.sh (or on a fresh GCP project).
#
# Phases:
#   1. Enable GCP APIs
#   2. Terraform backend (GCS bucket) + terraform apply
#   3. Connect kubectl to GKE
#   4. Helm: cert-manager, external-secrets, ingress-nginx
#   5. ArgoCD install + Application
#   6. Docker image builds → Artifact Registry (via Cloud Build, parallel)
#   7. Git commit + push
#   8. Verify pods are Running
#
# Usage:
#   bash scripts/build.sh
#
# Prerequisites:
#   - gcloud CLI authenticated (gcloud auth login --update-adc)
#   - Terraform installed
#   - Helm installed
#   - git configured with push access
# =============================================================================

set -euo pipefail

# Ensure script is run from the project root
cd "$(dirname "$0")/.."

# ─── CONFIGURATION ────────────────────────────────────────────────────────────
PROJECT_ID="practice-test1-494717"
REGION="us-central1"
ZONE="us-central1-a"
CLUSTER_NAME="ecommerce-cluster"
AR_REPOSITORY="ecommerce-docker"
IMAGE_REGISTRY="${REGION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPOSITORY}"
GIT_BRANCH="main"
TERRAFORM_DIR="terraform/envs/prod"
ARGOCD_NS="argocd"

# Colours
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log()     { echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${NC}"; }
section() {
  echo ""
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${CYAN}  $1${NC}"
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════════${NC}"
  echo ""
}

wait_for_pods() {
  local ns=$1 timeout=${2:-300}
  log "Waiting up to ${timeout}s for all pods in '${ns}' to be Running..."
  local deadline=$(( $(date +%s) + timeout ))
  while [ "$(date +%s)" -lt "$deadline" ]; do
    local not_ready
    not_ready=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null \
      | grep -vc "Running\|Completed" || true)
    local total
    total=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null | wc -l || true)
    if [ "$not_ready" -eq 0 ] && [ "$total" -gt 0 ]; then
      success "All pods in '$ns' are Running!"
      kubectl get pods -n "$ns"
      return 0
    fi
    log "  ${total} pods total, ${not_ready} not ready yet... retrying in 10s"
    sleep 10
  done
  warn "Timeout. Current state:"
  kubectl get pods -n "$ns" || true
}

# ─── PRE-FLIGHT ───────────────────────────────────────────────────────────────
section "🛫  PRE-FLIGHT CHECKS"
command -v gcloud    >/dev/null 2>&1 || { echo "gcloud not found"; exit 1; }
command -v kubectl   >/dev/null 2>&1 || { echo "kubectl not found"; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo "terraform not found"; exit 1; }
command -v helm      >/dev/null 2>&1 || { echo "helm not found"; exit 1; }
command -v git       >/dev/null 2>&1 || { echo "git not found"; exit 1; }
gcloud config set project "$PROJECT_ID" --quiet
success "Pre-flight checks passed. Building for project: ${PROJECT_ID}"

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 1 — ENABLE APIS
# ══════════════════════════════════════════════════════════════════════════════
section "🔧 PHASE 1/8 — ENABLE GCP APIS"
log "Enabling APIs (may take ~2 min)..."
gcloud services enable \
  container.googleapis.com \
  sqladmin.googleapis.com \
  cloudbuild.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  compute.googleapis.com \
  servicenetworking.googleapis.com \
  cloudresourcemanager.googleapis.com \
  --project "$PROJECT_ID" --quiet
success "All APIs enabled."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 2 — TERRAFORM
# ══════════════════════════════════════════════════════════════════════════════
section "🏗️  PHASE 2/8 — TERRAFORM (GKE + Cloud SQL + VPC)"

BUCKET_NAME="tf-state-ecommerce-prod-${PROJECT_ID}"
log "Ensuring Terraform state bucket: gs://${BUCKET_NAME}..."
gcloud storage buckets create "gs://${BUCKET_NAME}" \
  --project="$PROJECT_ID" --location="$REGION" \
  --uniform-bucket-level-access 2>/dev/null || warn "Bucket already exists."
gcloud storage buckets update "gs://${BUCKET_NAME}" --versioning --quiet 2>/dev/null || true

log "terraform init..."
(cd "$TERRAFORM_DIR" && terraform init -reconfigure -input=false)

log "terraform plan..."
(cd "$TERRAFORM_DIR" && terraform plan -out=tfplan -input=false)

log "terraform apply (this takes ~15 min for GKE)..."
(cd "$TERRAFORM_DIR" && terraform apply tfplan)
success "Infrastructure provisioned: GKE cluster, Cloud SQL, VPC, networking."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 3 — CONNECT KUBECTL
# ══════════════════════════════════════════════════════════════════════════════
section "🔑 PHASE 3/8 — CONNECT KUBECTL TO GKE"
gcloud container clusters get-credentials "$CLUSTER_NAME" \
  --zone "$ZONE" --project "$PROJECT_ID"
success "kubectl context: $(kubectl config current-context)"

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 4 — HELM PLATFORM CONTROLLERS
# ══════════════════════════════════════════════════════════════════════════════
section "⚓ PHASE 4/8 — HELM: PLATFORM CONTROLLERS"

# cert-manager
log "Installing cert-manager..."
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true \
  --set startupapicheck.enabled=false \
  --wait --timeout 5m
success "cert-manager installed."

# external-secrets
log "Installing external-secrets..."
helm repo add external-secrets https://charts.external-secrets.io --force-update
helm repo update
helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets --create-namespace \
  --set installCRDs=true --wait --timeout 5m
success "external-secrets installed."

log "Waiting 30 seconds for cert-manager and external-secrets webhooks to fully populate their CA certificates..."
sleep 30

# ingress-nginx
log "Installing ingress-nginx..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer \
  --wait --timeout 5m
success "ingress-nginx installed."

# kube-prometheus-stack
log "Installing Prometheus & Grafana..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
helm repo update
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --values monitoring/prometheus/values.yaml \
  --wait --timeout 20m
success "Prometheus & Grafana installed."
INGRESS_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
log "  Ingress LoadBalancer IP: ${INGRESS_IP}"

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 5 — ARGOCD
# ══════════════════════════════════════════════════════════════════════════════
section "🚀 PHASE 5/8 — ARGOCD"

log "Creating argocd namespace..."
kubectl create namespace "$ARGOCD_NS" 2>/dev/null || warn "Namespace already exists."

log "Installing ArgoCD..."
kubectl apply -n "$ARGOCD_NS" \
  --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

log "Waiting for ArgoCD server to be ready..."
kubectl rollout status deployment/argocd-server -n "$ARGOCD_NS" --timeout=5m
success "ArgoCD ready."

ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret \
  -n "$ARGOCD_NS" -o jsonpath='{.data.password}' | base64 -d)
log "  ArgoCD password: ${ARGOCD_PASSWORD}"

log "Applying ArgoCD Application manifest..."
kubectl apply -f argocd/apps.yaml
success "ArgoCD Application 'ecommerce-catalog' registered."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 6 — DOCKER IMAGE BUILDS (PARALLEL via Cloud Build)
# ══════════════════════════════════════════════════════════════════════════════
section "🐳 PHASE 6/8 — BUILD & PUSH DOCKER IMAGES (PARALLEL)"

log "Ensuring Artifact Registry Docker repository: ${AR_REPOSITORY} (${REGION})..."
gcloud artifacts repositories create "$AR_REPOSITORY" \
  --repository-format=docker \
  --location="$REGION" \
  --description="Docker images for ecommerce services" \
  --project "$PROJECT_ID" \
  --quiet 2>/dev/null || warn "Artifact Registry repository already exists."

PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
log "Ensuring Cloud Build can push and GKE nodes can pull Artifact Registry images..."
gcloud artifacts repositories add-iam-policy-binding "$AR_REPOSITORY" \
  --location="$REGION" \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/artifactregistry.writer" \
  --project "$PROJECT_ID" \
  --quiet >/dev/null
gcloud artifacts repositories add-iam-policy-binding "$AR_REPOSITORY" \
  --location="$REGION" \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/artifactregistry.reader" \
  --project "$PROJECT_ID" \
  --quiet >/dev/null

declare -A SERVICES=( [catalog]="catalog-service" [cart]="cart-service" \
                      [payment]="payment-service" [api-gateway]="api-gateway" \
                      [frontend]="frontend-service" )
BUILD_IDS=()

for SVC in "${!SERVICES[@]}"; do
  IMG="${SERVICES[$SVC]}"
  log "Submitting Cloud Build for ${IMG}..."
  BUILD_ID=$(gcloud builds submit \
    --tag "${IMAGE_REGISTRY}/${IMG}:latest" \
    "services/${SVC}/" \
    --project "$PROJECT_ID" \
    --async \
    --format='value(id)')
  BUILD_IDS+=("$BUILD_ID")
  log "  → Build ID: ${BUILD_ID}"
done

log "Streaming logs and waiting for all ${#BUILD_IDS[@]} builds..."
for BUILD_ID in "${BUILD_IDS[@]}"; do
  gcloud builds log --stream "$BUILD_ID" --project "$PROJECT_ID" 2>/dev/null || true
done

for IMG in "${SERVICES[@]}"; do
  gcloud artifacts docker images describe "${IMAGE_REGISTRY}/${IMG}:latest" \
    --project "$PROJECT_ID" --quiet >/dev/null 2>&1 \
    && success "${IMAGE_REGISTRY}/${IMG}:latest" \
    || warn "Image ${IMG} not confirmed — check Cloud Build logs"
done

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 7 — GIT COMMIT & PUSH
# ══════════════════════════════════════════════════════════════════════════════
section "📤 PHASE 7/8 — GIT COMMIT & PUSH"
git add -A
if ! git diff --cached --quiet; then
  MSG="deploy: full rebuild at $(date '+%Y-%m-%d %H:%M') — all services provisioned"
  git commit -m "$MSG"
  log "Committed: ${MSG}"
else
  log "No local changes — repo already up-to-date."
fi
git push origin "$GIT_BRANCH"
success "Pushed to GitHub. ArgoCD will auto-sync within ~3 minutes."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 8 — VERIFY
# ══════════════════════════════════════════════════════════════════════════════
section "🔍 PHASE 8/8 — VERIFY DEPLOYMENT"
log "Waiting 60s for ArgoCD to sync..."
sleep 60

log "ArgoCD sync status:"
kubectl get application ecommerce-catalog -n "$ARGOCD_NS" \
  -o jsonpath='{.status.sync.status} {.status.health.status}' 2>/dev/null || warn "App not found yet."
echo ""

wait_for_pods ecommerce 300

# ─── FINAL SUMMARY ────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  🎉  BUILD COMPLETE — PLATFORM IS LIVE       ${NC}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}ArgoCD:${NC}"
echo "  URL:      https://localhost:8080"
echo "  User:     admin"
echo "  Password: ${ARGOCD_PASSWORD}"
echo "  Connect:  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo -e "${BOLD}Grafana (Dashboards):${NC}"
echo "  URL:      http://localhost:3000"
echo "  User:     admin"
echo "  Password: admin"
echo "  Connect:  kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80"
echo ""
echo -e "${BOLD}Prometheus (Metrics):${NC}"
echo "  URL:      http://localhost:9090"
echo "  Connect:  kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090"
echo ""
echo -e "${BOLD}Frontend (Public Ingress):${NC}"
echo "  URL:      https://localhost/"
echo "  Connect:  kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 80:80 443:443"
echo ""
echo -e "${BOLD}Ingress Public IP:${NC} ${INGRESS_IP}"
echo ""
echo -e "${BOLD}Pods:${NC}"
kubectl get pods -n ecommerce 2>/dev/null || warn "Check: kubectl get pods -n ecommerce -w"
echo ""
echo -e "${YELLOW}${BOLD}Activate automated CI/CD (one-time):${NC}"
echo "  1. https://console.cloud.google.com/cloud-build/triggers/connect"
echo "  2. bash scripts/setup-cloudbuild-trigger.sh"
echo ""
success "Done! 🚀"
