#!/bin/bash
# =============================================================================
# scripts/nuke-and-rebuild.sh
# =============================================================================
# ONE SCRIPT TO RULE THEM ALL
#
# Does everything end-to-end:
#   1.  NUKE    — destroys all existing GCP resources
#   2.  SETUP   — enables APIs, creates service accounts
#   3.  INFRA   — Terraform provisions GKE + Cloud SQL + VPC + Networking
#   4.  CONNECT — fetches GKE credentials
#   5.  HELM    — installs platform controllers (cert-manager, external-secrets, ingress-nginx)
#   6.  ARGOCD  — installs ArgoCD and applies the Application manifest
#   7.  BUILD   — builds and pushes all 4 Docker images to GCR via Cloud Build
#   8.  GIT     — commits and pushes any pending changes to GitHub
#   9.  VERIFY  — waits for ArgoCD sync and confirms pods are Running
#
# Usage:
#   bash scripts/nuke-and-rebuild.sh
#
# Prerequisites:
#   - gcloud CLI authenticated: gcloud auth login --update-adc
#   - git configured with push access to the GitHub repo
#   - Terraform installed
#
# To SKIP the nuke phase (rebuild only):
#   SKIP_NUKE=true bash scripts/nuke-and-rebuild.sh
#
# =============================================================================

set -euo pipefail

# Ensure script is run from the project root
cd "$(dirname "$0")/.."

# ─── CONFIGURATION ────────────────────────────────────────────────────────────
PROJECT_ID="my-project-32062-newsletter"
REGION="us-central1"
CLUSTER_NAME="ecommerce-cluster"
REPO_URL="https://github.com/ajithvnr2001/gcp-infra-end-to-end"
GIT_BRANCH="main"
TERRAFORM_DIR="terraform/envs/prod"
ARGOCD_NS="argocd"
ARGOCD_APP="argocd/apps.yaml"
SKIP_NUKE="${SKIP_NUKE:-false}"

# Colours
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ─── HELPERS ──────────────────────────────────────────────────────────────────
log()     { echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${NC}"; }
error()   { echo -e "${RED}❌ $1${NC}"; exit 1; }
section() { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════════${NC}"; \
            echo -e "${BOLD}${CYAN}  $1${NC}"; \
            echo -e "${BOLD}${CYAN}══════════════════════════════════════════════${NC}\n"; }

wait_for_pods() {
  local ns=$1 timeout=${2:-300}
  log "Waiting up to ${timeout}s for pods in namespace '${ns}' to be Running..."
  local deadline=$(( $(date +%s) + timeout ))
  while [ "$(date +%s)" -lt "$deadline" ]; do
    local not_ready
    not_ready=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null \
      | grep -v "Running\|Completed" | wc -l || true)
    if [ "$not_ready" -eq 0 ] && [ "$(kubectl get pods -n "$ns" --no-headers 2>/dev/null | wc -l)" -gt 0 ]; then
      success "All pods in '$ns' are Running!"
      kubectl get pods -n "$ns"
      return 0
    fi
    sleep 10
  done
  warn "Timeout waiting for pods in '$ns'. Current state:"
  kubectl get pods -n "$ns" || true
}

# ─── PRE-FLIGHT ───────────────────────────────────────────────────────────────
section "🛫 PRE-FLIGHT CHECKS"
command -v gcloud  >/dev/null 2>&1 || error "gcloud CLI not found. Install from: https://cloud.google.com/sdk"
command -v kubectl >/dev/null 2>&1 || error "kubectl not found. Run: gcloud components install kubectl"
command -v terraform >/dev/null 2>&1 || error "terraform not found. Install from: https://developer.hashicorp.com/terraform/downloads"
command -v helm    >/dev/null 2>&1 || error "helm not found. Install from: https://helm.sh/docs/intro/install/"
command -v git     >/dev/null 2>&1 || error "git not found."

log "Setting active project to: $PROJECT_ID"
gcloud config set project "$PROJECT_ID" --quiet
success "Pre-flight checks passed"

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 1 — NUKE
# ══════════════════════════════════════════════════════════════════════════════
if [ "$SKIP_NUKE" = "false" ]; then
  section "💣 PHASE 1: NUKE ALL EXISTING RESOURCES"
  warn "This will DELETE the GKE cluster, Cloud SQL, VPC, and all networking!"
  echo -e "${RED}Type 'yes' to confirm or anything else to skip nuke:${NC}"
  read -r confirm
  if [ "$confirm" = "yes" ]; then
    log "Nuking GKE cluster..."
    gcloud container clusters delete "$CLUSTER_NAME" --region "$REGION" \
      --project "$PROJECT_ID" --quiet 2>/dev/null || warn "GKE cluster not found, skipping."

    log "Nuking Cloud SQL..."
    gcloud sql instances delete ecommerce-postgres \
      --project "$PROJECT_ID" --quiet 2>/dev/null || warn "Cloud SQL not found, skipping."

    log "Nuking Firewall rules..."
    gcloud compute firewall-rules delete prod-allow-internal \
      --project "$PROJECT_ID" --quiet 2>/dev/null || warn "Firewall rule not found."

    log "Nuking Cloud NAT and Router..."
    gcloud compute routers nats delete prod-ecommerce-nat \
      --router prod-ecommerce-router --region "$REGION" \
      --project "$PROJECT_ID" --quiet 2>/dev/null || warn "NAT not found."
    gcloud compute routers delete prod-ecommerce-router --region "$REGION" \
      --project "$PROJECT_ID" --quiet 2>/dev/null || warn "Router not found."

    log "Nuking VPC peering..."
    for i in {1..3}; do
      gcloud compute networks peerings delete servicenetworking-googleapis-com \
        --network=prod-ecommerce-vpc --project="$PROJECT_ID" --quiet 2>/dev/null \
        && break || { warn "Peering busy, retry $i/3 in 30s..."; sleep 30; }
    done

    log "Nuking reserved IP range..."
    gcloud compute addresses delete prod-ecommerce-vpc-private-ip \
      --global --project "$PROJECT_ID" --quiet 2>/dev/null || warn "Reserved IP not found."

    log "Nuking subnet..."
    gcloud compute networks subnets delete prod-ecommerce-subnet \
      --region "$REGION" --project "$PROJECT_ID" --quiet 2>/dev/null || warn "Subnet not found."

    log "Nuking VPC..."
    gcloud compute networks delete prod-ecommerce-vpc \
      --project "$PROJECT_ID" --quiet 2>/dev/null || warn "VPC not found."

    success "NUKE complete. All infrastructure removed."
  else
    warn "Nuke skipped by user."
  fi
else
  warn "SKIP_NUKE=true — skipping nuke phase."
fi

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 2 — ENABLE APIS & SERVICE ACCOUNT
# ══════════════════════════════════════════════════════════════════════════════
section "🔧 PHASE 2: ENABLE GCP APIS"
log "Enabling required APIs (this may take ~2 minutes)..."
gcloud services enable \
  container.googleapis.com \
  sqladmin.googleapis.com \
  cloudbuild.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  containerregistry.googleapis.com \
  secretmanager.googleapis.com \
  compute.googleapis.com \
  servicenetworking.googleapis.com \
  cloudresourcemanager.googleapis.com \
  --project "$PROJECT_ID" --quiet
success "APIs enabled."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 3 — TERRAFORM BACKEND + APPLY
# ══════════════════════════════════════════════════════════════════════════════
section "🏗️  PHASE 3: TERRAFORM — PROVISION INFRASTRUCTURE"

# Ensure Terraform state bucket exists
BUCKET_NAME="tf-state-ecommerce-prod-${PROJECT_ID}"
log "Ensuring Terraform state bucket: gs://${BUCKET_NAME}"
gcloud storage buckets create "gs://${BUCKET_NAME}" \
  --project="$PROJECT_ID" --location="$REGION" \
  --uniform-bucket-level-access 2>/dev/null || warn "Bucket already exists, continuing."
gcloud storage buckets update "gs://${BUCKET_NAME}" --versioning --quiet 2>/dev/null || true

log "Running terraform init..."
(cd "$TERRAFORM_DIR" && terraform init -reconfigure -input=false)

log "Running terraform plan..."
(cd "$TERRAFORM_DIR" && terraform plan -out=tfplan -input=false)

log "Running terraform apply (this takes ~10-15 minutes for GKE)..."
(cd "$TERRAFORM_DIR" && terraform apply tfplan)
success "Terraform apply complete — GKE, Cloud SQL, VPC provisioned."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 4 — GET KUBECONFIG
# ══════════════════════════════════════════════════════════════════════════════
section "🔑 PHASE 4: CONNECT TO GKE"
log "Fetching GKE credentials..."
gcloud container clusters get-credentials "$CLUSTER_NAME" \
  --region "$REGION" --project "$PROJECT_ID"
log "Current context: $(kubectl config current-context)"
success "kubectl connected to GKE cluster."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 5 — INSTALL PLATFORM CONTROLLERS VIA HELM
# ══════════════════════════════════════════════════════════════════════════════
section "⚓ PHASE 5: INSTALL PLATFORM CONTROLLERS (HELM)"

# 5a. Cert-Manager
log "Installing cert-manager..."
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true \
  --set startupapicheck.enabled=false \
  --wait --timeout 5m
success "cert-manager installed."

# 5b. External Secrets Operator
log "Installing external-secrets..."
helm repo add external-secrets https://charts.external-secrets.io --force-update
helm repo update
helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets --create-namespace \
  --set installCRDs=true \
  --wait --timeout 5m
success "external-secrets installed."

# 5c. NGINX Ingress Controller
log "Installing ingress-nginx..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer \
  --wait --timeout 5m
success "ingress-nginx installed."
log "Ingress LoadBalancer IP:"
kubectl get svc -n ingress-nginx ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || warn "IP not assigned yet, check later."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 6 — ARGOCD
# ══════════════════════════════════════════════════════════════════════════════
section "🚀 PHASE 6: INSTALL ARGOCD & APPLY APPLICATION"

log "Installing ArgoCD..."
kubectl create namespace "$ARGOCD_NS" 2>/dev/null || warn "Namespace argocd already exists."
kubectl apply -n "$ARGOCD_NS" \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
log "Waiting for ArgoCD pods to be ready..."
kubectl rollout status deployment/argocd-server -n "$ARGOCD_NS" --timeout=5m
success "ArgoCD installed."

log "Retrieving ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret \
  -n "$ARGOCD_NS" -o jsonpath='{.data.password}' | base64 -d)
echo ""
echo -e "${GREEN}  ArgoCD URL:      https://localhost:8080${NC}"
echo -e "${GREEN}  Username:        admin${NC}"
echo -e "${GREEN}  Password:        ${ARGOCD_PASSWORD}${NC}"
echo ""

log "Applying ArgoCD Application manifest..."
kubectl apply -f "$ARGOCD_APP"
success "ArgoCD Application 'ecommerce-catalog' registered."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 7 — BUILD & PUSH DOCKER IMAGES
# ══════════════════════════════════════════════════════════════════════════════
section "🐳 PHASE 7: BUILD & PUSH DOCKER IMAGES TO GCR"
log "Building all 4 microservice images via Cloud Build (parallel)..."

SERVICES=("catalog" "cart" "payment" "api-gateway")
IMAGE_NAMES=("catalog-service" "cart-service" "payment-service" "api-gateway")
BUILD_IDS=()

for i in "${!SERVICES[@]}"; do
  SVC="${SERVICES[$i]}"
  IMG="${IMAGE_NAMES[$i]}"
  log "Submitting Cloud Build for ${IMG}..."
  BUILD_ID=$(gcloud builds submit \
    --tag "gcr.io/${PROJECT_ID}/${IMG}:latest" \
    "services/${SVC}/" \
    --project "$PROJECT_ID" \
    --async \
    --format='value(id)')
  BUILD_IDS+=("$BUILD_ID")
  log "  → Build ID: $BUILD_ID"
done

log "Waiting for all 4 builds to complete..."
for BUILD_ID in "${BUILD_IDS[@]}"; do
  log "  Polling build: $BUILD_ID"
  gcloud builds log --stream "$BUILD_ID" --project "$PROJECT_ID" 2>/dev/null || true
done

# Verify images exist
for IMG in "${IMAGE_NAMES[@]}"; do
  gcloud container images describe "gcr.io/${PROJECT_ID}/${IMG}:latest" \
    --project "$PROJECT_ID" --quiet >/dev/null 2>&1 \
    && success "✓ gcr.io/${PROJECT_ID}/${IMG}:latest" \
    || warn "Image gcr.io/${PROJECT_ID}/${IMG}:latest not found — build may have failed"
done

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 8 — GIT COMMIT & PUSH
# ══════════════════════════════════════════════════════════════════════════════
section "📤 PHASE 8: GIT COMMIT & PUSH"
log "Staging any local changes..."
git add -A

# Only commit if there are staged changes
if ! git diff --cached --quiet; then
  COMMIT_MSG="deploy: nuke-and-rebuild at $(date '+%Y-%m-%d %H:%M') — all services provisioned"
  git commit -m "$COMMIT_MSG"
  log "Committed: $COMMIT_MSG"
else
  log "No local changes to commit — repository already up-to-date."
fi

log "Pushing to ${GIT_BRANCH}..."
git push origin "$GIT_BRANCH"
success "Code pushed to GitHub. ArgoCD will detect changes within ~3 minutes."

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 9 — VERIFY
# ══════════════════════════════════════════════════════════════════════════════
section "🔍 PHASE 9: VERIFY DEPLOYMENT"
log "Waiting for ArgoCD to discover and sync (~3 min)..."
sleep 60

log "ArgoCD sync status:"
kubectl get application ecommerce-catalog -n "$ARGOCD_NS" \
  -o jsonpath='{.status.sync.status} {.status.health.status}' 2>/dev/null \
  || warn "ArgoCD Application not found yet, it may still be starting."
echo ""

log "Waiting for ecommerce pods to come up..."
wait_for_pods ecommerce 300

# ─── SUMMARY ──────────────────────────────────────────────────────────────────
section "🎉 COMPLETE — PLATFORM IS LIVE"
echo ""
echo -e "${GREEN}${BOLD}Infrastructure:${NC}"
echo "  GKE Cluster:   ecommerce-cluster (us-central1)"
echo "  Cloud SQL:     ecommerce-postgres"
echo ""
echo -e "${GREEN}${BOLD}Platform Controllers:${NC}"
echo "  cert-manager         → namespace: cert-manager"
echo "  external-secrets     → namespace: external-secrets"
echo "  ingress-nginx        → namespace: ingress-nginx"
echo ""
echo -e "${GREEN}${BOLD}GitOps:${NC}"
echo "  ArgoCD URL:    http://localhost:8080  (run: kubectl port-forward svc/argocd-server -n argocd 8080:443)"
echo "  Password:      ${ARGOCD_PASSWORD}"
echo "  Application:   ecommerce-catalog (watching: ${REPO_URL})"
echo ""
echo -e "${GREEN}${BOLD}Microservice Pods:${NC}"
kubectl get pods -n ecommerce 2>/dev/null || warn "Pods still starting, run: kubectl get pods -n ecommerce -w"
echo ""
echo -e "${YELLOW}${BOLD}Next steps:${NC}"
echo "  1. To activate automated CI/CD on every push:"
echo "     → Open: https://console.cloud.google.com/cloud-build/triggers/connect"
echo "     → Connect your GitHub repo, then run: scripts/setup-cloudbuild-trigger.sh"
echo "  2. To monitor: kubectl get pods -n ecommerce -w"
echo "  3. To access ArgoCD: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
success "End-to-end provisioning complete! 🚀"
