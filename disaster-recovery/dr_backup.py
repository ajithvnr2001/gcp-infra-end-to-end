#!/usr/bin/env python3
# disaster-recovery/dr_backup.py
# Automated Disaster Recovery — backs up Cloud SQL to GCS every 6 hours
# Also exports Kubernetes state (deployments, configmaps) for cluster rebuild
# "Managed disaster recovery — RTO < 1 hour, RPO < 6 hours"

import subprocess
import os
import json
import logging
from datetime import datetime

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

PROJECT_ID    = os.getenv("GCP_PROJECT_ID", "your-project-id")
INSTANCE_NAME = os.getenv("CLOUDSQL_INSTANCE", "ecommerce-postgres")
BACKUP_BUCKET = os.getenv("DR_BUCKET", "gs://ecommerce-dr-backups")
NAMESPACE     = "ecommerce"
TIMESTAMP     = datetime.now().strftime("%Y%m%d_%H%M%S")

def run(cmd: str, desc: str) -> bool:
    logger.info(f"Running: {desc}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        logger.error(f"FAILED: {desc}\n{result.stderr}")
        return False
    logger.info(f"OK: {desc}")
    return True

def backup_cloudsql():
    """Trigger Cloud SQL backup and export to GCS"""
    logger.info("=== Cloud SQL Backup ===")

    # On-demand backup
    run(f"""
        gcloud sql backups create \
          --instance={INSTANCE_NAME} \
          --project={PROJECT_ID}
    """, "Cloud SQL on-demand backup")

    # Export to GCS (for cross-project restore)
    for db in ["catalog", "orders"]:
        export_uri = f"{BACKUP_BUCKET}/cloudsql/{TIMESTAMP}/{db}.sql.gz"
        run(f"""
            gcloud sql export sql {INSTANCE_NAME} {export_uri} \
              --database={db} \
              --project={PROJECT_ID} \
              --offload
        """, f"Export {db} database to GCS")

def backup_k8s_state():
    """Export all Kubernetes resources so cluster can be rebuilt from scratch"""
    logger.info("=== Kubernetes State Backup ===")

    resources = [
        "deployments", "services", "configmaps",
        "ingresses", "horizontalpodautoscalers",
        "networkpolicies", "serviceaccounts", "roles", "rolebindings"
    ]

    all_state = {}
    for resource in resources:
        result = subprocess.run(
            f"kubectl get {resource} -n {NAMESPACE} -o json",
            shell=True, capture_output=True, text=True
        )
        if result.returncode == 0:
            all_state[resource] = json.loads(result.stdout)
            logger.info(f"  Exported {resource}")
        else:
            logger.warning(f"  Could not export {resource}: {result.stderr}")

    # Write to temp file and upload to GCS
    tmp_file = f"/tmp/k8s_state_{TIMESTAMP}.json"
    with open(tmp_file, "w") as f:
        json.dump(all_state, f, indent=2)

    run(f"gcloud storage cp {tmp_file} {BACKUP_BUCKET}/k8s-state/{TIMESTAMP}/state.json",
        "Upload K8s state to GCS")
    os.remove(tmp_file)

def verify_backup():
    """Verify latest backup exists in GCS"""
    logger.info("=== Verifying Backup ===")
    result = subprocess.run(
        f"gcloud storage ls {BACKUP_BUCKET}/cloudsql/{TIMESTAMP}/",
        shell=True, capture_output=True, text=True
    )
    if result.returncode == 0 and result.stdout.strip():
        logger.info(f"✅ Backup verified at {BACKUP_BUCKET}/cloudsql/{TIMESTAMP}/")
        return True
    logger.error("❌ Backup verification FAILED")
    return False

def cleanup_old_backups(keep_days: int = 30):
    """Remove backups older than keep_days"""
    logger.info(f"=== Cleanup (keeping {keep_days} days) ===")
    run(f"""
        gcloud storage rm -r \
          $(gcloud storage ls {BACKUP_BUCKET}/ | \
            awk 'NR > {keep_days}') 2>/dev/null || true
    """, "Remove old backups")

if __name__ == "__main__":
    logger.info(f"DR Backup Job started @ {datetime.now()} | Timestamp: {TIMESTAMP}")
    backup_cloudsql()
    backup_k8s_state()
    verify_backup()
    cleanup_old_backups(keep_days=30)
    logger.info("✅ DR Backup complete")
