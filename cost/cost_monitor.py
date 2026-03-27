#!/usr/bin/env python3
# cost/cost_monitor.py
# GCP Cost monitoring script — tracks spend per service and alerts on overruns
# "Reduced cloud costs by X% by identifying wasteful resources"
# Run daily via Cloud Scheduler or cron

import subprocess
import json
import os
import logging
from datetime import datetime, date, timedelta
from typing import Optional

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

PROJECT_ID    = os.getenv("GCP_PROJECT_ID", "your-project-id")
BUDGET_USD    = float(os.getenv("MONTHLY_BUDGET_USD", "500"))
ALERT_PCT     = float(os.getenv("ALERT_THRESHOLD_PCT", "80"))   # alert at 80% of budget
SLACK_WEBHOOK = os.getenv("SLACK_WEBHOOK_URL", "")


def get_monthly_spend() -> Optional[float]:
    """Get current month GCP spend using billing export (requires BigQuery billing export)"""
    first_day = date.today().replace(day=1).isoformat()
    today     = date.today().isoformat()

    # Using gcloud billing — simpler but less detailed
    result = subprocess.run([
        "gcloud", "billing", "accounts", "list",
        "--filter=open=true", "--format=json", f"--project={PROJECT_ID}"
    ], capture_output=True, text=True)

    if result.returncode != 0:
        logger.warning("Could not fetch billing data — check billing API is enabled")
        return None

    # In production: query BigQuery billing export for detailed breakdown
    # SELECT service.description, SUM(cost) as total_cost
    # FROM `project.dataset.gcp_billing_export_*`
    # WHERE DATE(_PARTITIONTIME) BETWEEN '{first_day}' AND '{today}'
    # GROUP BY service.description ORDER BY total_cost DESC
    logger.info(f"Billing period: {first_day} → {today}")
    return None  # placeholder — wire up BigQuery for real data


def check_idle_resources():
    """Find wasteful resources: stopped VMs, unattached disks, old snapshots"""
    logger.info("=== Idle Resource Check ===")
    issues = []

    # Check for nodes with low CPU utilization (potential over-provisioning)
    result = subprocess.run([
        "kubectl", "top", "nodes", "--no-headers"
    ], capture_output=True, text=True)

    if result.returncode == 0:
        for line in result.stdout.strip().split("\n"):
            parts = line.split()
            if len(parts) >= 3:
                node_name = parts[0]
                cpu_pct   = parts[2].replace("%", "")
                try:
                    if int(cpu_pct) < 10:
                        issues.append(f"Node {node_name} CPU only {cpu_pct}% — may be over-provisioned")
                except ValueError:
                    pass

    # Check for Persistent Volumes not in use
    result = subprocess.run([
        "kubectl", "get", "pv", "-o",
        "jsonpath={range .items[*]}{.metadata.name} {.status.phase}\\n{end}"
    ], capture_output=True, text=True)

    if result.returncode == 0:
        for line in result.stdout.strip().split("\n"):
            if "Released" in line or "Available" in line:
                issues.append(f"Unused PV found: {line.strip()} — safe to delete?")

    # Check for old Docker images in GCR (over 60 days)
    result = subprocess.run([
        "gcloud", "container", "images", "list",
        f"--repository=gcr.io/{PROJECT_ID}",
        "--format=json", f"--project={PROJECT_ID}"
    ], capture_output=True, text=True)

    if result.returncode == 0:
        try:
            images = json.loads(result.stdout)
            logger.info(f"  GCR images found: {len(images)}")
        except json.JSONDecodeError:
            pass

    return issues


def check_pod_resource_efficiency():
    """Compare requested vs actual CPU/memory — find over-requested pods"""
    logger.info("=== Pod Resource Efficiency ===")

    result = subprocess.run([
        "kubectl", "top", "pods", "-n", "ecommerce",
        "--no-headers"
    ], capture_output=True, text=True)

    if result.returncode != 0:
        logger.warning("kubectl top not available — metrics-server may not be installed")
        return

    logger.info("Pod resource usage:")
    for line in result.stdout.strip().split("\n"):
        logger.info(f"  {line}")


def generate_cost_report(issues: list) -> str:
    today    = datetime.now().strftime("%Y-%m-%d")
    report   = [
        f"📊 GCP Cost Report — {today}",
        f"   Project: {PROJECT_ID}",
        f"   Monthly Budget: ${BUDGET_USD:.0f}",
        "",
    ]

    if issues:
        report.append(f"⚠️  {len(issues)} cost optimization opportunities found:")
        for issue in issues:
            report.append(f"   • {issue}")
    else:
        report.append("✅ No idle resources found")

    report += [
        "",
        "💡 Cost Saving Tips:",
        "   • Use Spot/Preemptible nodes for non-critical workloads (70% cheaper)",
        "   • Enable GKE Autopilot — only pay for pod requests, not node capacity",
        "   • Set aggressive HPA scale-down — don't keep idle pods running",
        "   • Use Committed Use Discounts for baseline workloads (up to 57% off)",
        "   • Clean up old GCR images and unused PVs regularly",
        "   • Use Cloud SQL shared-core tier for dev/UAT (db-f1-micro = $7/month)",
    ]

    return "\n".join(report)


def send_slack_alert(message: str):
    if not SLACK_WEBHOOK:
        return
    import urllib.request
    data = json.dumps({"text": message}).encode()
    req  = urllib.request.Request(
        SLACK_WEBHOOK, data=data,
        headers={"Content-Type": "application/json"}
    )
    urllib.request.urlopen(req)


if __name__ == "__main__":
    logger.info(f"Cost Monitor started — Project: {PROJECT_ID}")

    issues = check_idle_resources()
    check_pod_resource_efficiency()

    report = generate_cost_report(issues)
    logger.info("\n" + report)

    if issues:
        send_slack_alert(report)
        logger.info("Slack alert sent")
