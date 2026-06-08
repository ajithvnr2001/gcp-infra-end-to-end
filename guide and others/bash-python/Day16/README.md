# Day 16 - Service Checker

## 🐚 Bash: Service Checker

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SERVICE CHECKER - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

SERVICES=("nginx" "postgresql" "redis")   # List of services to monitor
MAX_RESTART=3                              # Max restart attempts

check_service() {
    local service=$1
    # systemctl is-active: check if systemd service is active
    # --quiet: suppress output (exit code only)
    # 2>/dev/null: discard error if service doesn't exist
    systemctl is-active --quiet "$service" 2>/dev/null
    return $?                               # Return 0 if active, non-zero if not
}

for service in "${SERVICES[@]}"; do
    if check_service "$service"; then       # If returns 0 (success)
        echo "✓ $service is running"
    else
        echo "✗ $service is DOWN"
        
        attempts=0
        while [ $attempts -lt "$MAX_RESTART" ]; do
            ((attempts++))
            echo "Restart attempt $attempts..."
            
            systemctl restart "$service" 2>/dev/null  # Try restart
            sleep 2                                    # Wait for startup
            
            if check_service "$service"; then
                echo "✓ $service restarted successfully"
                break                                  # Exit retry loop on success
            fi
        done
    fi
done
```

## 🐍 Python: Service Checker

```python
#!/usr/bin/env python3

import subprocess
import time

class ServiceMonitor:
    def __init__(self, services, max_retries=3):
        self.services = services                     # List of service names
        self.max_retries = max_retries               # Max restart attempts
    
    def is_active(self, service):
        """Check if systemd service is active"""
        result = subprocess.run(
            ["systemctl", "is-active", service],     # Run systemctl command
            capture_output=True, text=True,          # Capture output
            timeout=10                                # Don't hang forever
        )
        return result.stdout.strip() == "active"     # True if output is "active"
    
    def restart(self, service):
        """Restart a service"""
        subprocess.run(
            ["systemctl", "restart", service],       # Run restart command
            timeout=30                                # Some services take long
        )
        time.sleep(2)                                 # Wait for startup
        return self.is_active(service)                # Verify it started
    
    def check_all(self):
        """Check all services, return status dict"""
        results = {}
        for service in self.services:
            if self.is_active(service):
                results[service] = "running"
                print(f"✓ {service} is running")
            else:
                print(f"✗ {service} is DOWN")
                
                for attempt in range(1, self.max_retries + 1):
                    print(f"Restart attempt {attempt}/{self.max_retries}")
                    
                    if self.restart(service):
                        results[service] = "restarted"
                        break
                    elif attempt == self.max_retries:
                        results[service] = "escalate"  # Needs human intervention
        return results
```