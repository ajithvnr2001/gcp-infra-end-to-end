#!/bin/bash
# scripts/cleanup-gcp.sh
# Deletes all resources in the correct order to allow a clean terraform apply

set -e

PROJECT_ID=$1
REGION=${2:-us-central1} # Using us-central1 as seen in user logs
ENV="prod"

if [ -z "$PROJECT_ID" ]; then
  echo "Usage: ./cleanup-gcp.sh <project-id> [region]"
  exit 1
fi

echo "🧹 Starting deep cleanup for project: $PROJECT_ID in region: $REGION"

# 1. Delete GKE Cluster
echo "☸️ Deleting GKE cluster..."
gcloud container clusters delete ecommerce-cluster --region $REGION --project $PROJECT_ID --quiet || echo "⚠️ GKE cluster not found or already deleted."

# 2. Delete Cloud SQL Instance
echo "🐘 Deleting Cloud SQL instance..."
gcloud sql instances delete ecommerce-postgres --project $PROJECT_ID --quiet || echo "⚠️ Cloud SQL instance not found."

# 3. Delete Firewall Rules
echo "🔥 Deleting firewall rules..."
gcloud compute firewall-rules delete ${ENV}-allow-internal --project $PROJECT_ID --quiet || echo "⚠️ Firewall rule not found."

# 4. Delete Cloud NAT
echo "🌐 Deleting Cloud NAT..."
gcloud compute routers nats delete ${ENV}-ecommerce-nat --router ${ENV}-ecommerce-router --region $REGION --project $PROJECT_ID --quiet || echo "⚠️ Cloud NAT not found."

# 5. Delete Cloud Router
echo "🛣️ Deleting Cloud Router..."
gcloud compute routers delete ${ENV}-ecommerce-router --region $REGION --project $PROJECT_ID --quiet || echo "⚠️ Cloud Router not found."

# 6. Delete Private Service Connection (VPC Peering)
echo "🔗 Attempting to delete VPC Peering..."
for i in {1..5}; do
  if gcloud compute networks peerings delete servicenetworking-googleapis-com \
      --network=${ENV}-ecommerce-vpc \
      --project=$PROJECT_ID --quiet; then
    echo "✅ Peering deleted successfully."
    break
  else
    echo "⏳ Peering is still in use or being processed. Waiting 45s before retry $i/5..."
    sleep 45
  fi
done

# 7. Delete Reserved IP Range for Private Services
echo "🏷️ Deleting Reserved IP range..."
# Note: The name is derived from the VPC name + -private-ip in terraform
gcloud compute addresses delete ${ENV}-ecommerce-vpc-private-ip \
    --global \
    --project=$PROJECT_ID --quiet || echo "⚠️ Reserved IP not found."

# 8. Delete Subnet
echo "📍 Deleting Subnet..."
gcloud compute networks subnets delete ${ENV}-ecommerce-subnet --region $REGION --project $PROJECT_ID --quiet || echo "⚠️ Subnet not found."

# 9. Finally, Delete VPC
echo "🏗️ Deleting VPC..."
gcloud compute networks delete ${ENV}-ecommerce-vpc --project $PROJECT_ID --quiet || echo "⚠️ VPC not found."

echo ""
echo "✅ Cleanup complete! All infrastructure has been removed."
echo "   You can now safely run: cd terraform/envs/prod && terraform apply"
