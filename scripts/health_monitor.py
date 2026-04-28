#!/usr/bin/env python3
# scripts/health_monitor.py
# Automated health check script — runs every 60s, sends alert if any service is down
# This is the kind of script you'd mention in interviews:
# "I built Python scripts that reduced manual effort by 30%"

import subprocess
import json
import time
import logging
import os
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s"
)
logger = logging.getLogger(__name__)

NAMESPACE = "ecommerce"
SERVICES  = ["catalog-service", "cart-service", "payment-service", "api-gateway", "frontend-service"]
ALERT_THRESHOLD = 3   # alert after 3 consecutive failures

failure_counts = {s: 0 for s in SERVICES}

def run_kubectl(args: list) -> dict:
    try:
        result = subprocess.run(
            ["kubectl"] + args,
            capture_output=True, text=True, timeout=10
        )
        return {"ok": result.returncode == 0, "output": result.stdout, "error": result.stderr}
    except subprocess.TimeoutExpired:
        return {"ok": False, "output": "", "error": "kubectl timeout"}

def check_service_health(service: str) -> dict:
    # Check deployment ready replicas
    result = run_kubectl([
        "get", "deployment", service,
        "-n", NAMESPACE,
        "-o", "jsonpath={.status.readyReplicas}/{.spec.replicas}"
    ])
    if not result["ok"]:
        return {"healthy": False, "reason": f"kubectl error: {result['error']}"}

    parts = result["output"].strip().split("/")
    if len(parts) != 2:
        return {"healthy": False, "reason": "could not parse replica count"}

    ready, desired = parts
    ready   = int(ready)   if ready   else 0
    desired = int(desired) if desired else 0

    if ready < desired:
        return {
            "healthy": False,
            "reason": f"only {ready}/{desired} replicas ready",
            "ready": ready,
            "desired": desired
        }

    # Check for crash loops
    crash_result = run_kubectl([
        "get", "pods", "-n", NAMESPACE,
        "-l", f"app={service}",
        "-o", "jsonpath={.items[*].status.containerStatuses[*].state.waiting.reason}"
    ])
    if "CrashLoopBackOff" in crash_result.get("output", ""):
        return {"healthy": False, "reason": "CrashLoopBackOff detected"}

    return {"healthy": True, "ready": ready, "desired": desired}

def check_hpa(service: str) -> dict:
    result = run_kubectl([
        "get", "hpa", f"{service.replace('-service','')}-hpa",
        "-n", NAMESPACE,
        "-o", "jsonpath={.status.currentReplicas}/{.spec.maxReplicas}"
    ])
    if not result["ok"]:
        return {}
    parts = result["output"].strip().split("/")
    if len(parts) == 2:
        current, maximum = int(parts[0] or 0), int(parts[1] or 0)
        if current >= maximum * 0.9:
            return {"warning": f"HPA at {current}/{maximum} — near max capacity!"}
    return {}

def send_alert(service: str, reason: str):
    """In production: send to Slack/PagerDuty/email via GCP Cloud Monitoring"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    alert_msg = f"🚨 ALERT [{timestamp}] Service DOWN: {service} — {reason}"
    logger.error(alert_msg)
    # Example: post to Slack webhook
    # import urllib.request
    # urllib.request.urlopen(urllib.request.Request(
    #     os.getenv("SLACK_WEBHOOK_URL"),
    #     data=json.dumps({"text": alert_msg}).encode(),
    #     headers={"Content-Type": "application/json"}
    # ))

def run_health_check():
    logger.info(f"--- Health Check @ {datetime.now().strftime('%H:%M:%S')} ---")
    all_healthy = True

    for service in SERVICES:
        result = check_service_health(service)
        hpa    = check_hpa(service)

        if result["healthy"]:
            logger.info(f"  ✅ {service}: {result.get('ready')}/{result.get('desired')} ready")
            failure_counts[service] = 0
        else:
            failure_counts[service] += 1
            logger.warning(f"  ❌ {service}: {result['reason']} (failure #{failure_counts[service]})")
            all_healthy = False
            if failure_counts[service] >= ALERT_THRESHOLD:
                send_alert(service, result["reason"])

        if hpa.get("warning"):
            logger.warning(f"  ⚠️  {service} HPA: {hpa['warning']}")

    return all_healthy

if __name__ == "__main__":
    logger.info("🔍 Starting health monitor (Ctrl+C to stop)...")
    interval = int(os.getenv("CHECK_INTERVAL", "60"))
    while True:
        try:
            run_health_check()
        except Exception as e:
            logger.error(f"Monitor error: {e}")
        time.sleep(interval)
