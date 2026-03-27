#!/bin/bash
# disaster-recovery/dr_restore.sh
# Full cluster restore from backup
# Use when: region goes down, cluster corrupted, major incident
# RTO target: < 1 hour

set -e

BACKUP_TIMESTAMP=$1
PROJECT_ID=$2
REGION=${3:-"asia-south1"}
DR_BUCKET="gs://ecommerce-dr-backups"

if [ -z "$BACKUP_TIMESTAMP" ] || [ -z "$PROJECT_ID" ]; then
  echo "Usage: ./dr_restore.sh <backup-timestamp> <project-id> [region]"
  echo ""
  echo "List available backups:"
  echo "  gcloud storage ls gs://ecommerce-dr-backups/cloudsql/"
  exit 1
fi

echo "================================================"
echo "  DISASTER RECOVERY RESTORE"
echo "  Backup: $BACKUP_TIMESTAMP"
echo "  Project: $PROJECT_ID"
echo "  Region: $REGION"
echo "================================================"
echo ""
read -p "⚠️  This will restore from backup. Continue? (yes/no): " confirm
[ "$confirm" != "yes" ] && echo "Aborted." && exit 1

# Step 1: Restore Cloud SQL
echo ""
echo "Step 1/4: Restoring Cloud SQL databases..."
for db in catalog orders; do
  BACKUP_URI="$DR_BUCKET/cloudsql/$BACKUP_TIMESTAMP/$db.sql.gz"
  echo "  Importing $db from $BACKUP_URI..."
  gcloud sql import sql ecommerce-postgres $BACKUP_URI \
    --database=$db \
    --project=$PROJECT_ID \
    --quiet
  echo "  ✅ $db restored"
done

# Step 2: Reconnect to GKE (or spin up new cluster via Terraform)
echo ""
echo "Step 2/4: Connecting to GKE cluster..."
gcloud container clusters get-credentials ecommerce-cluster \
  --region=$REGION --project=$PROJECT_ID

# Step 3: Restore Kubernetes state
echo ""
echo "Step 3/4: Restoring Kubernetes resources..."
STATE_URI="$DR_BUCKET/k8s-state/$BACKUP_TIMESTAMP/state.json"
gcloud storage cp $STATE_URI /tmp/k8s_restore_state.json

python3 - << 'PYEOF'
import json, subprocess

with open('/tmp/k8s_restore_state.json') as f:
    state = json.load(f)

# Apply resources in correct order
ORDER = ['configmaps', 'serviceaccounts', 'roles', 'rolebindings',
         'services', 'deployments', 'ingresses', 'horizontalpodautoscalers']

for resource in ORDER:
    if resource not in state:
        continue
    items = state[resource].get('items', [])
    for item in items:
        # Strip runtime fields
        for field in ['resourceVersion', 'uid', 'creationTimestamp', 'generation',
                      'selfLink', 'managedFields']:
            item['metadata'].pop(field, None)
        item.pop('status', None)

        name = item['metadata']['name']
        ns   = item['metadata'].get('namespace', 'ecommerce')
        kind = item['kind']

        import tempfile, os
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as tmp:
            json.dump(item, tmp)
            tmp_path = tmp.name

        result = subprocess.run(
            f"kubectl apply -f {tmp_path} -n {ns}",
            shell=True, capture_output=True, text=True
        )
        status = "✅" if result.returncode == 0 else "❌"
        print(f"  {status} {kind}/{name}")
        os.remove(tmp_path)
PYEOF

# Step 4: Verify all services are healthy
echo ""
echo "Step 4/4: Verifying restoration..."
sleep 30   # give pods time to start

kubectl get pods -n ecommerce
echo ""
kubectl get deployments -n ecommerce

READY=$(kubectl get deployments -n ecommerce -o jsonpath='{.items[*].status.readyReplicas}' | tr ' ' '\n' | grep -v '^0$' | wc -l)
TOTAL=$(kubectl get deployments -n ecommerce --no-headers | wc -l)

if [ "$READY" -eq "$TOTAL" ]; then
  echo ""
  echo "================================================"
  echo "✅ RESTORE COMPLETE — All $TOTAL services ready"
  echo "================================================"
else
  echo ""
  echo "⚠️  $READY/$TOTAL services ready — check pod logs"
fi
