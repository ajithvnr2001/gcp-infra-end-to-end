#!/bin/bash
# =============================================================================
# scripts/nuke.sh
# =============================================================================
# DESTROYS all GCP resources for the ecommerce platform.
# Run this before a fresh rebuild.
#
# Usage:
#   bash scripts/nuke.sh
#
# After this completes, run:
#   bash scripts/build.sh
# =============================================================================

set -euo pipefail

# Ensure script is run from the project root
cd "$(dirname "$0")/.."

PROJECT_ID="my-project-32062-newsletter"
REGION="us-central1"
ENV="prod"

# Colours
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

log()     { echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${NC}"; }

echo -e "${BOLD}${RED}"
echo "  ███╗   ██╗██╗   ██╗██╗  ██╗███████╗"
echo "  ████╗  ██║██║   ██║██║ ██╔╝██╔════╝"
echo "  ██╔██╗ ██║██║   ██║█████╔╝ █████╗  "
echo "  ██║╚██╗██║██║   ██║██╔═██╗ ██╔══╝  "
echo "  ██║ ╚████║╚██████╔╝██║  ██╗███████╗"
echo "  ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝"
echo -e "${NC}"
echo -e "${RED}${BOLD}WARNING: This will permanently DELETE all infrastructure!${NC}"
echo -e "  Project : ${BOLD}${PROJECT_ID}${NC}"
echo -e "  Region  : ${BOLD}${REGION}${NC}"
echo ""
echo -e "${RED}Type 'nuke' to confirm, or anything else to abort:${NC}"
read -r confirm
[ "$confirm" = "nuke" ] || { echo "Aborted. Nothing was deleted."; exit 0; }

echo ""
log "Starting nuke sequence..."
echo ""

# 1. GKE Cluster (biggest resource, start first — takes longest)
log "🗑️  [1/9] Deleting GKE cluster: ecommerce-cluster..."
gcloud container clusters delete ecommerce-cluster \
  --region "$REGION" --project "$PROJECT_ID" --quiet 2>/dev/null \
  && success "GKE cluster deleted." \
  || warn "GKE cluster not found, skipping."

# 2. Cloud SQL
log "🗑️  [2/9] Deleting Cloud SQL: ecommerce-postgres..."
gcloud sql instances delete ecommerce-postgres \
  --project "$PROJECT_ID" --quiet 2>/dev/null \
  && success "Cloud SQL deleted." \
  || warn "Cloud SQL not found, skipping."

# 3. Firewall Rules
log "🗑️  [3/9] Deleting firewall rules..."
gcloud compute firewall-rules delete "${ENV}-allow-internal" \
  --project "$PROJECT_ID" --quiet 2>/dev/null \
  && success "Firewall rules deleted." \
  || warn "Firewall rules not found, skipping."

# 4. Cloud NAT
log "🗑️  [4/9] Deleting Cloud NAT..."
gcloud compute routers nats delete "${ENV}-ecommerce-nat" \
  --router "${ENV}-ecommerce-router" \
  --region "$REGION" --project "$PROJECT_ID" --quiet 2>/dev/null \
  && success "Cloud NAT deleted." \
  || warn "Cloud NAT not found, skipping."

# 5. Cloud Router
log "🗑️  [5/9] Deleting Cloud Router..."
gcloud compute routers delete "${ENV}-ecommerce-router" \
  --region "$REGION" --project "$PROJECT_ID" --quiet 2>/dev/null \
  && success "Cloud Router deleted." \
  || warn "Cloud Router not found, skipping."

# 6. VPC Peering (retry logic — must wait for dependent resources to release)
log "🗑️  [6/9] Deleting VPC Peering (may retry up to 3x)..."
for i in 1 2 3; do
  if gcloud compute networks peerings delete servicenetworking-googleapis-com \
      --network="${ENV}-ecommerce-vpc" \
      --project="$PROJECT_ID" --quiet 2>/dev/null; then
    success "VPC Peering deleted."
    break
  else
    [ "$i" -lt 3 ] && { warn "Peering busy, retry $i/3 in 30s..."; sleep 30; } \
      || warn "VPC Peering not found or could not be deleted, skipping."
  fi
done

# 7. Reserved Private IP Range
log "🗑️  [7/9] Deleting Reserved IP Range..."
gcloud compute addresses delete "${ENV}-ecommerce-vpc-private-ip" \
  --global --project "$PROJECT_ID" --quiet 2>/dev/null \
  && success "Reserved IP deleted." \
  || warn "Reserved IP not found, skipping."

# 8. Subnet
log "🗑️  [8/9] Deleting subnet..."
gcloud compute networks subnets delete "${ENV}-ecommerce-subnet" \
  --region "$REGION" --project "$PROJECT_ID" --quiet 2>/dev/null \
  && success "Subnet deleted." \
  || warn "Subnet not found, skipping."

# 9. VPC
log "🗑️  [9/9] Deleting VPC..."
gcloud compute networks delete "${ENV}-ecommerce-vpc" \
  --project "$PROJECT_ID" --quiet 2>/dev/null \
  && success "VPC deleted." \
  || warn "VPC not found, skipping."

echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  💥 NUKE COMPLETE — All infrastructure removed${NC}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════${NC}"
echo ""
echo "  Next step → rebuild everything:"
echo -e "  ${BOLD}bash scripts/build.sh${NC}"
echo ""
