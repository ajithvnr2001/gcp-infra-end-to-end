# Day 14 - Mini Project: Log Analyzer

## 🐚 Bash: Log Analyzer

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# LOG ANALYZER - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

LOG_FILE="app.log"                          # Input log file
REPORT="log_report_$(date +%Y%m%d).txt"     # Output report with date

# ─── Count by Level ──────────────────────────────────────
grep -c "ERROR" "$LOG_FILE"                 # -c = count matching lines
grep -c "WARNING" "$LOG_FILE"
wc -l < "$LOG_FILE"                         # wc -l = word count lines. Total lines

# ─── Top IP Addresses ────────────────────────────────────
grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" "$LOG_FILE" | sort | uniq -c | sort -rn | head -10
# -o = only matching text (not whole line)
# -E = extended regex
# sort = sort alphabetically (needed for uniq)
# uniq -c = count consecutive duplicates
# sort -rn = sort numeric, reverse (highest first)
# head -10 = top 10

# ─── Top Error Messages ──────────────────────────────────
grep "ERROR" "$LOG_FILE" | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//' | sort | uniq -c | sort -rn | head -10
# awk: remove first 3 fields (timestamp, time, "ERROR"), keep rest
# sed: remove leading spaces created by awk
# sort | uniq -c: count unique error messages
# sort -rn: sort by count descending
```

## 🐍 Python: Log Analyzer

```python
#!/usr/bin/env python3

import re
from collections import Counter
from pathlib import Path

class LogAnalyzer:
    def __init__(self, filepath):
        self.filepath = Path(filepath)
        self.lines = self.filepath.read_text().splitlines()  # Read all lines
    
    def count_levels(self):
        """Count ERROR, WARNING, INFO, DEBUG occurrences"""
        counts = Counter()
        for line in self.lines:
            for level in ["ERROR", "WARNING", "INFO", "DEBUG"]:
                if level in line:            # Check if level string is in this line
                    counts[level] += 1
                    break                     # Count only once per line
        return dict(counts)
    
    def extract_ips(self):
        """Find all IP addresses in the log"""
        pattern = re.compile(r"\b(?:\d{1,3}\.){3}\d{1,3}\b")  # IP regex
        ips = []
        for line in self.lines:
            ips.extend(pattern.findall(line))  # findall = all matches in line
        return ips
    
    def top_ips(self, n=10):
        """Most common IPs"""
        return Counter(self.extract_ips()).most_common(n)
    
    def generate_report(self):
        counts = self.count_levels()
        print("=" * 50)
        print("  LOG ANALYZER REPORT")
        print("=" * 50)
        
        for level in ["ERROR", "WARNING", "INFO", "DEBUG"]:
            count = counts.get(level, 0)        # .get() safe: returns 0 if missing
            bar = "█" * min(count // 10, 40)    # Visual bar: 1 char per 10
            print(f"  {level:<10}: {count:>6} {bar}")
        
        print("\nTop 5 IPs:")
        for ip, count in self.top_ips(5):
            print(f"  {ip:<16}: {count}")
```