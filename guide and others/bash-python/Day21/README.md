# Day 21 - Project: Server Health Monitor

## 🐚 Bash: Health Monitor

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SERVER HEALTH MONITOR - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

SCORE=100                                  # Start at 100, deduct for problems
SERVICES=("nginx" "postgresql" "redis" )   # Services to check

check_cpu() {
    local usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    echo "CPU: $usage%"
    if [ "$usage" -gt 80 ]; then
        SCORE=$((SCORE - 20))               # Deduct 20 points
        return 1                             # Return 1 = alert
    fi
    return 0
}

check_memory() {
    local total=$(free -m | awk 'NR==2 {print $2}')  # Total MB
    local used=$(free -m | awk 'NR==2 {print $3}')   # Used MB
    local percent=$((used * 100 / total))              # Calculate %
    echo "Memory: ${used}MB / ${total}MB (${percent}%)"
    if [ "$percent" -gt 80 ]; then
        SCORE=$((SCORE - 20))
        return 1
    fi
    return 0
}

check_disk() {
    local percent=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "Disk: ${percent}%"
    if [ "$percent" -gt 80 ]; then
        SCORE=$((SCORE - 20))
        return 1
    fi
    return 0
}

check_services() {
    for svc in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            echo "  ✓ $svc: running"
        else
            echo "  ✗ $svc: STOPPED"
            SCORE=$((SCORE - 15))            # -15 per service down
        fi
    done
}

# ─── Main ─────────────────────────────────────────────────
echo "=== Health Monitor ==="
check_cpu
check_memory
check_disk
echo "--- Services ---"
check_services
echo "Health Score: ${SCORE}/100"
```

## 🐍 Python: Health Monitor

```python
#!/usr/bin/env python3

import psutil, shutil, subprocess

class HealthMonitor:
    def __init__(self, cpu_threshold=80, mem_threshold=80, disk_threshold=80):
        self.thresholds = {"cpu": cpu_threshold, "mem": mem_threshold, "disk": disk_threshold}
        self.score = 100
        self.alerts = []
    
    def check_cpu(self):
        percent = psutil.cpu_percent(interval=1)   # Measure for 1 second
        if percent > self.thresholds["cpu"]:
            self.score -= 20
            self.alerts.append(f"CPU at {percent}%")
        return percent
    
    def check_memory(self):
        mem = psutil.virtual_memory()
        if mem.percent > self.thresholds["mem"]:
            self.score -= 20
            self.alerts.append(f"Memory at {mem.percent}%")
        return mem.percent
    
    def check_disk(self):
        disk = shutil.disk_usage("/")
        percent = (disk.used / disk.total) * 100
        if percent > self.thresholds["disk"]:
            self.score -= 20
            self.alerts.append(f"Disk at {percent:.1f}%")
        return percent
    
    def check_service(self, service):
        result = subprocess.run(
            ["systemctl", "is-active", service],
            capture_output=True, text=True, timeout=10
        )
        running = result.stdout.strip() == "active"
        if not running:
            self.score -= 15
            self.alerts.append(f"Service {service} is DOWN")
        return running
    
    def run(self):
        print("=== Health Monitor ===")
        print(f"CPU: {self.check_cpu():.1f}%")
        print(f"Memory: {self.check_memory():.1f}%")
        print(f"Disk: {self.check_disk():.1f}%")
        
        print("\n--- Services ---")
        for svc in ["nginx", "postgresql", "redis"]:
            status = self.check_service(svc)
            icon = "✓" if status else "✗"
            print(f"  {icon} {svc}: {'running' if status else 'STOPPED'}")
        
        print(f"\nHealth Score: {max(0, self.score)}/100")
        
        if self.alerts:
            print(f"\nAlerts ({len(self.alerts)}):")
            for a in self.alerts:
                print(f"  ⚠️  {a}")
```