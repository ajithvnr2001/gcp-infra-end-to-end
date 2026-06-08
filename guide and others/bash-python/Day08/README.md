# Day 8 - File Operations

## 🐚 Bash: Files

```bash
# ═══════════════════════════════════════════════════════════════
# FILE OPERATIONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── cat - Read Entire File ─────────────────────────────────
cat /var/log/syslog                    # cat = concatenate. Dumps entire file to stdout
                                        # Good for small files. Bad for huge files.

# ─── head - First N Lines ──────────────────────────────────
head -20 /var/log/syslog               # -20 = show first 20 lines (stops at 20)
head -n 20 /var/log/syslog             # -n 20 = same thing, explicit flag

# ─── tail - Last N Lines ───────────────────────────────────
tail -50 /var/log/syslog               # -50 = show last 50 lines
tail -f /var/log/nginx/access.log      # -f = FOLLOW. Watch file grow in real-time
                                        # Ctrl+C to stop. Critical for log monitoring!

# ─── Combined with grep ────────────────────────────────────
tail -100 /var/log/syslog | grep ERROR  # | = pipe: send output of tail into grep
                                         # Get last 100 lines, then filter for ERROR

# ─── Writing Files ─────────────────────────────────────────
echo "New content" > file.txt           # > = OVERWRITE. Creates or replaces file!
echo "Log entry" >> app.log             # >> = APPEND. Adds to end of file
                                         # Critical difference! > destroys data!

# ─── Redirect Both stdout and stderr ──────────────────────
command > output.log 2>&1               # > = stdout to file. 2>&1 = stderr to same place
                                         # 2 = stderr, > = redirect, &1 = to same as stdout
command &> output.log                   # Bash 4+ shortcut for the above
```

### Practice Exercise

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# LOG SUMMARY - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

LOG_FILE="/var/log/syslog"              # Path to the log file
REPORT="log_report_$(date +%Y%m%d).txt" # Dynamic filename with date

if [ ! -f "$LOG_FILE" ]; then           # ! -f = NOT a regular file
    echo "Error: $LOG_FILE not found"
    exit 1
fi

{                                       # Curly braces = GROUP commands
    echo "Log Report - $(date)"         # All output inside { } is redirected
    
    echo "Size: $(du -h "$LOG_FILE" | cut -f1)"  # du = disk usage, cut -f1 = first column
    
    echo "Lines: $(wc -l < "$LOG_FILE")"          # wc -l = line count, < = feed file to wc
    
    echo "--- Last 20 lines ---"
    tail -20 "$LOG_FILE"                # Show last 20 lines
} > "$REPORT"                          # > = redirect ALL grouped output to file

echo "Report generated: $REPORT"
```

---

## 🐍 Python: Files

```python
# ═══════════════════════════════════════════════════════════════
# FILE OPERATIONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── The "with" Statement ──────────────────────────────────
# with = CONTEXT MANAGER. It automatically closes the file when done.
# Without with, you must call f.close() manually - easy to forget.

# ─── Read Entire File (small files only) ───────────────────
with open("/var/log/syslog", "r") as f:   # "r" = read mode
    content = f.read()                     # Load ENTIRE file into memory
print(content[:500])                       # Show first 500 characters

# ─── Read Lines into List ──────────────────────────────────
with open("/var/log/syslog", "r") as f:
    lines = f.readlines()                  # Load ALL lines into list (memory heavy!)

# ─── Lazy Iteration (BEST for large files) ─────────────────
with open("/var/log/syslog", "r") as f:
    for line in f:                         # Reads ONE line at a time (memory efficient!)
        if "ERROR" in line:
            print(line.rstrip())            # rstrip() = remove trailing \n

# ─── Writing Files ─────────────────────────────────────────
with open("output.txt", "w") as f:         # "w" = WRITE mode (overwrites!)
    f.write("Hello, World!\n")              # Write a single line
    f.writelines(["line1\n", "line2\n"])    # Write multiple lines from list

with open("app.log", "a") as f:            # "a" = APPEND mode (adds to end!)
    f.write("Log entry\n")                  # Adds to file without deleting existing content

# ─── pathlib (Modern Python - RECOMMENDED) ─────────────────
from pathlib import Path

p = Path("/var/log/syslog")                # Create Path object
print(p.name)                              # "syslog" (file name only)
print(p.stem)                              # "syslog" (name without extension)
print(p.parent)                            # "/var/log" (parent directory)
print(p.exists())                          # True if file exists
print(p.is_file())                         # True if it's a regular file
print(p.stat().st_size)                    # File size in bytes

# Glob = find files matching pattern
for log in Path("/var/log").glob("*.log"): # Search for *.log in directory
    print(log.name)
```

### Practice Exercise

```python
#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# LOG SUMMARY - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

from datetime import datetime
from pathlib import Path

LOG_FILE = Path("/var/log/syslog")
REPORT_FILE = Path(f"log_report_{datetime.now().strftime('%Y%m%d')}.txt")

def get_file_info(filepath):
    """Get file metadata"""
    if not filepath.exists():
        raise FileNotFoundError(f"{filepath} not found")
    
    stats = filepath.stat()               # Get file statistics
    return {
        "size_bytes": stats.st_size,
        "size_kb": f"{stats.st_size / 1024:.1f} KB",
        "modified": datetime.fromtimestamp(stats.st_mtime),
        "lines": sum(1 for _ in open(filepath, "rb")),  # Count lines efficiently
    }

def generate_report():
    info = get_file_info(LOG_FILE)
    
    report_lines = [
        f"Log Report - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"File: {LOG_FILE}",
        f"Size: {info['size_kb']}",
        f"Lines: {info['lines']}",
        "\n--- Last 20 lines ---",
    ]
    
    with open(LOG_FILE, "r") as f:
        lines = f.readlines()[-20:]        # Read last 20 lines
    report_lines.extend(line.rstrip() for line in lines)
    
    REPORT_FILE.write_text("\n".join(report_lines))
    print(f"Report generated: {REPORT_FILE}")

if __name__ == "__main__":
    generate_report()
```