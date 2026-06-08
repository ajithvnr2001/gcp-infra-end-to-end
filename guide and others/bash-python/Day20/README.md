# Day 20 - Health Check Report

## 🐚 Bash: Health Report

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# HEALTH REPORT - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

REPORT_FILE="/tmp/health_report_$(date +%Y%m%d).html"

# ─── Collect Metrics ──────────────────────────────────────
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
# top -bn1: batch mode, 1 iteration
# grep "Cpu(s)": find the CPU line
# awk '{print $2}': 2nd field = user CPU percentage
# cut -d. -f1: get integer part (remove decimal)

MEM_PERCENT=$(free -m | awk 'NR==2 {printf "%.0f", $3/$2 * 100}')
# free -m: memory in megabytes
# awk: NR==2 = line 2 (Mem: line)
# $3/$2 = used/total * 100 = percentage
# printf "%.0f": format as integer with 0 decimal places

DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
# df -h /: disk free for root, human-readable
# awk: 5th column = "Use%" (e.g., "75%")

LOAD=$(uptime | awk -F'load average:' '{print $2}')
# uptime: shows how long system has been running + load
# -F'load average:': split on "load average:"
# $2 = part after, e.g., " 0.45, 0.30, 0.25"

# ─── Calculate Health Score ──────────────────────────────
SCORE=100
[ "$CPU_USAGE" -gt 80 ] && SCORE=$((SCORE - 20))
# Deduct 20 points if CPU > 80%
[[ "${DISK_USAGE%\%}" -gt 80 ]] && SCORE=$((SCORE - 20))
# ${DISK_USAGE%\%}: remove trailing % from "75%" → "75"
# Then compare as number

# ─── Generate HTML ───────────────────────────────────────
cat > "$REPORT_FILE" << EOF
<!DOCTYPE html>
<html><head><title>Health Report</title>
<style>
body { font-family: Arial; }
.bar { height: 20px; background: #e0e0e0; }
.fill { height: 20px; background: #4CAF50; width: ${CPU_USAGE}%; }
</style></head><body>
<h1>System Health Report</h1>
<p>CPU: ${CPU_USAGE}%</p>
<div class="bar"><div class="fill"></div></div>
<p>Memory: ${MEM_PERCENT}%</p>
<p>Disk: ${DISK_USAGE}</p>
<p>Load: ${LOAD}</p>
<h2>Health Score: ${SCORE}/100</h2>
</body></html>
EOF

echo "Report: $REPORT_FILE"
echo "Score: $SCORE/100"
```

## 🐍 Python: Health Report

```python
#!/usr/bin/env python3

import psutil
import shutil
from pathlib import Path
from datetime import datetime

class HealthReport:
    def __init__(self, report_dir="/tmp/reports"):
        self.report_dir = Path(report_dir)
        self.report_dir.mkdir(parents=True, exist_ok=True)
    
    def collect_metrics(self):
        """Collect all system metrics"""
        cpu = psutil.cpu_percent(interval=1)  # Measure CPU for 1 second
        mem = psutil.virtual_memory()          # Memory stats
        disk = shutil.disk_usage("/")          # Disk usage
        
        return {
            "cpu": cpu,
            "memory_percent": mem.percent,
            "memory_used_gb": round(mem.used / (1024**3), 1),  # Bytes to GB
            "memory_total_gb": round(mem.total / (1024**3), 1),
            "disk_percent": round((disk.used / disk.total) * 100, 1),
            "disk_used_gb": round(disk.used / (1024**3), 1),
            "disk_total_gb": round(disk.total / (1024**3), 1),
        }
    
    def calculate_score(self, metrics):
        """0-100 health score"""
        score = 100
        if metrics["cpu"] > 80:
            score -= 20
        if metrics["memory_percent"] > 80:
            score -= 20
        if metrics["disk_percent"] > 80:
            score -= 20
        return max(0, score)
    
    def generate_html(self):
        """Generate HTML report"""
        m = self.collect_metrics()
        score = self.calculate_score(m)
        
        html = f"""<!DOCTYPE html>
<html><head><title>Health Report</title></head><body>
<h1>Health Report - {datetime.now().strftime('%Y-%m-%d %H:%M')}</h1>
<p>CPU: {m['cpu']}%</p>
<p>Memory: {m['memory_used_gb']}/{m['memory_total_gb']} GB ({m['memory_percent']}%)</p>
<p>Disk: {m['disk_used_gb']}/{m['disk_total_gb']} GB ({m['disk_percent']}%)</p>
<h2>Health Score: {score}/100</h2>
</body></html>"""
        
        path = self.report_dir / f"health_{datetime.now().strftime('%Y%m%d')}.html"
        path.write_text(html)
        return path
```