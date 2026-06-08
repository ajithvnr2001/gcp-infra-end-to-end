# Day 15 - Disk Monitoring Script

## 🐚 Bash: Disk Monitor

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# DISK MONITOR - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

THRESHOLD=80                              # Alert if usage > 80%

# ─── df -h: Disk Free, Human-Readable ─────────────────────
df -h | grep '^/' | while read -r line; do
    # df -h: show disk usage with human-readable sizes
    # grep '^/': only lines starting with / (filesystems, not virtual)
    # while read: read each line into 'line' variable
    # -r: prevent backslash interpretation
    
    # Extract fields from the df line
    FILESYSTEM=$(echo "$line" | awk '{print $1}')     # Device name (/dev/sda1)
    USE_PERCENT=$(echo "$line" | awk '{print $5}' | sed 's/%//')  # Remove %, get number
    MOUNT=$(echo "$line" | awk '{print $6}')           # Mount point (/)
    
    echo "$MOUNT: ${USE_PERCENT}% used"
    
    if [ "$USE_PERCENT" -gt "$THRESHOLD" ]; then
        echo "ALERT: $MOUNT is ${USE_PERCENT}% full!"  # Alert with tee to log
        
        # Find largest directories
        du -sh "$MOUNT"/* 2>/dev/null | sort -rh | head -5
        # du -sh: disk usage, summary, human-readable
        # sort -rh: reverse, human-readable (understands K, M, G)
        # head -5: top 5 largest
    fi
done
```

## 🐍 Python: Disk Monitor

```python
#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# DISK MONITOR - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import shutil                            # Shell utilities (disk operations)

class DiskMonitor:
    def __init__(self, threshold=80):
        self.threshold = threshold
    
    def check_mount(self, mount_point):
        """Check disk usage for a mount point"""
        usage = shutil.disk_usage(mount_point)  # Returns (total, used, free) in BYTES
        
        percent = (usage.used / usage.total) * 100  # Calculate percentage
        
        return {
            "mount": mount_point,
            "total_gb": usage.total / (1024**3),       # Bytes → GB (divide by 1024^3)
            "used_gb": usage.used / (1024**3),
            "free_gb": usage.free / (1024**3),
            "percent": round(percent, 1),              # Round to 1 decimal
            "alert": percent > self.threshold,         # True if exceeded threshold
        }
    
    def find_large_dirs(self, path, top_n=5):
        """Find largest subdirectories"""
        from pathlib import Path
        entries = []
        for entry in Path(path).iterdir():        # Iterate direct children
            if entry.is_dir():
                total = sum(
                    f.stat().st_size 
                    for f in entry.rglob("*")      # rglob = recursive glob
                    if f.is_file()                  # Only count files
                )
                entries.append((str(entry), total))
        
        entries.sort(key=lambda x: x[1], reverse=True)  # Sort by size descending
        return entries[:top_n]
```