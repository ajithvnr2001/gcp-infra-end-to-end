#!/usr/bin/env bash
set -euo pipefail

DISK_THRESHOLD="${DISK_THRESHOLD:-80}"
URL="${1:-http://localhost:8080/health}"

echo "== Health Check =="

disk_used="$(df -h / | awk 'NR==2 {gsub("%","",$5); print $5}')"
echo "Disk used: ${disk_used}%"
if [ "$disk_used" -ge "$DISK_THRESHOLD" ]; then
  echo "ERROR: Disk usage above ${DISK_THRESHOLD}%"
  exit 1
fi

echo "Memory:"
free -m || true

echo "HTTP check: ${URL}"
if command -v curl >/dev/null 2>&1; then
  curl -fsS "$URL" >/dev/null
  echo "HTTP OK"
else
  echo "WARN: curl not installed"
fi

echo "All checks passed"

