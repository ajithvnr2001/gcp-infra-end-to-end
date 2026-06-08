# Day 12 - find vs os.walk()

## 🐚 Bash: find

```bash
# ═══════════════════════════════════════════════════════════════
# FIND - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── By Name ───────────────────────────────────────────────
find /var/log -name "*.log"              # -name = case-sensitive name pattern
find /var/log -iname "*.LOG"             # -iname = case-INSENSITIVE
find / -name "nginx.conf"                # Search entire filesystem

# ─── By Type ───────────────────────────────────────────────
find /var/log -type f                    # -type f = regular FILES only
find /var/log -type d                    # -type d = DIRECTORIES only

# ─── By Time ──────────────────────────────────────────────
find /var/log -mtime -1                  # -mtime -1 = modified less than 1 day ago
                                         # -mtime = modification time
                                         # -1 = LESS than 1 (i.e., within last day)
find /var/log -mtime +30                 # +30 = MORE than 30 days ago
find . -mmin -60                         # -mmin = minutes. Last 60 minutes.

# ─── By Size ──────────────────────────────────────────────
find /var/log -size +100M                # +100M = larger than 100 Megabytes
find / -size -1M                         # -1M = smaller than 1 Megabyte
find . -size 0                           # Empty files (zero bytes)

# ─── With Actions ─────────────────────────────────────────
find /tmp -name "*.tmp" -exec rm {} \;   # -exec = run command on each file
                                          # {} = placeholder for found file
                                          # \; = end of -exec command

find /var/log -mtime +30 -delete         # -delete = delete found files (faster)

find . -printf "%p - %s bytes\n"         # -printf = custom output format
                                          # %p = file path, %s = file size in bytes
```

---

## 🐍 Python: File Walking

```python
# ═══════════════════════════════════════════════════════════════
# FILE WALKING - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── os.walk() - Walk Directory Tree ──────────────────────
import os

for dirpath, dirnames, filenames in os.walk("/var/log"):
    # dirpath = current directory path (changes each iteration)
    # dirnames = list of subdirectory names (modify to prune)
    # filenames = list of file names in current dir
    
    for filename in filenames:
        if filename.endswith(".log"):            # Filter by extension
            full_path = os.path.join(dirpath, filename)  # Join properly
            print(full_path)

# ─── pathlib (Modern Python) ──────────────────────────────
from pathlib import Path

# rglob() = recursive glob (finds all matching recursively)
log_files = list(Path("/var/log").rglob("*.log"))  # All .log files

# Filter by size
large_logs = [
    f for f in Path("/var/log").rglob("*.log")
    if f.stat().st_size > 100 * 1024 * 1024        # > 100 MB
]
# f.stat().st_size = file size in bytes
# 100 * 1024 * 1024 = 100 MB in bytes

# Filter by time
import time
cutoff = time.time() - (30 * 86400)                # 30 days ago in seconds
old_logs = [
    f for f in Path("/var/log").rglob("*.log")
    if f.stat().st_mtime < cutoff                   # st_mtime = last modified
]
```