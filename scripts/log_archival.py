#!/usr/bin/env python3
# scripts/log_archival.py
# Archives old pod logs to GCS — reduces disk pressure on nodes
# "Built Python scripts for log archival saving 5+ man-hours/week"

import subprocess
import os
import gzip
import json
import logging
from datetime import datetime, timedelta

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

NAMESPACE   = "ecommerce"
GCS_BUCKET  = os.getenv("LOG_ARCHIVE_BUCKET", "gs://ecommerce-logs-archive")
RETENTION_DAYS = int(os.getenv("LOG_RETENTION_DAYS", "7"))

def get_pods(namespace: str) -> list:
    result = subprocess.run(
        ["kubectl", "get", "pods", "-n", namespace,
         "-o", "jsonpath={.items[*].metadata.name}"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        logger.error(f"Failed to get pods: {result.stderr}")
        return []
    return result.stdout.strip().split()

def fetch_pod_logs(pod: str, namespace: str, since_hours: int = 24) -> str:
    result = subprocess.run(
        ["kubectl", "logs", pod, "-n", namespace,
         f"--since={since_hours}h", "--timestamps=true"],
        capture_output=True, text=True, timeout=30
    )
    if result.returncode != 0:
        logger.warning(f"Could not fetch logs for {pod}: {result.stderr}")
        return ""
    return result.stdout

def archive_logs_to_gcs(pod: str, logs: str, bucket: str):
    if not logs.strip():
        logger.info(f"  No logs to archive for {pod}")
        return

    date_str  = datetime.now().strftime("%Y/%m/%d")
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename  = f"/tmp/{pod}_{timestamp}.log.gz"
    gcs_path  = f"{bucket}/{date_str}/{pod}_{timestamp}.log.gz"

    # Compress locally
    with gzip.open(filename, 'wt', encoding='utf-8') as f:
        f.write(logs)

    # Upload to GCS
    result = subprocess.run(
        ["gcloud", "storage", "cp", filename, gcs_path],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        size_kb = os.path.getsize(filename) / 1024
        logger.info(f"  ✅ Archived {pod}: {size_kb:.1f} KB → {gcs_path}")
    else:
        logger.error(f"  ❌ Failed to upload {pod}: {result.stderr}")

    os.remove(filename)

def delete_old_archives(bucket: str, retention_days: int):
    cutoff = datetime.now() - timedelta(days=retention_days)
    logger.info(f"Deleting archives older than {retention_days} days ({cutoff.date()})...")
    result = subprocess.run(
        ["gcloud", "storage", "rm", "-r",
         f"{bucket}/{cutoff.strftime('%Y/%m/%d')}/**"],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        logger.info("Old archives deleted")

def main():
    logger.info(f"📦 Log Archival Job started @ {datetime.now()}")
    logger.info(f"   Namespace : {NAMESPACE}")
    logger.info(f"   Bucket    : {GCS_BUCKET}")
    logger.info(f"   Retention : {RETENTION_DAYS} days")

    pods = get_pods(NAMESPACE)
    if not pods:
        logger.warning("No pods found — exiting")
        return

    logger.info(f"\nArchiving logs from {len(pods)} pods...")
    archived = 0
    for pod in pods:
        logs = fetch_pod_logs(pod, NAMESPACE)
        archive_logs_to_gcs(pod, logs, GCS_BUCKET)
        archived += 1

    delete_old_archives(GCS_BUCKET, RETENTION_DAYS)
    logger.info(f"\n✅ Archival complete — {archived} pods processed")

if __name__ == "__main__":
    main()
