# Day 10 - awk vs Python split

## 🐚 Bash: awk

```bash
# ═══════════════════════════════════════════════════════════════
# AWK - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Column Extraction ─────────────────────────────────────
df -h | awk '{print $1, $5}'          # $1 = first column (Filesystem)
                                        # $5 = fifth column (Use%)
                                        # awk auto-splits by whitespace
                                        # NR = current line number
                                        # NF = number of fields in current line

# ─── Skip Header ───────────────────────────────────────────
ps aux | awk 'NR>1 {print $2, $11}'  # NR>1 = skip line 1 (header row)
                                        # $2 = PID, $11 = COMMAND

# ─── Custom Field Separator ────────────────────────────────
awk -F: '{print $1}' /etc/passwd      # -F: = field separator is colon (:)
                                        # /etc/passwd uses : as delimiter
                                        # $1 = username field

# ─── Filter + Extract ──────────────────────────────────────
df -h | awk '$5+0 > 80 {print $1, $5}'  # $5+0 = convert $5 to number (remove %)
                                           # > 80 = filter: only show > 80%
                                           # {print $1, $5} = action for matching rows

# ─── BEGIN/END Blocks ─────────────────────────────────────
awk 'BEGIN {print "Starting..."}       # BEGIN = runs ONCE before processing
     {count++}                         # For each line: increment counter
     END {print "Total:", count}' file.txt  # END = runs ONCE after all lines

# ─── Calculations ─────────────────────────────────────────
ps aux | awk 'NR>1 {sum+=$3} END {print "Total CPU:", sum "%"}'
# NR>1 = skip header
# sum+=$3 = add CPU% column to running total
# END = after all lines, print the sum
```

---

## 🐍 Python: Split and Parse

```python
# ═══════════════════════════════════════════════════════════════
# SPLIT AND PARSE - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Basic split() ─────────────────────────────────────────
line = "2024-01-15 10:30:45 ERROR Connection timeout"
parts = line.split()                     # split() = split on whitespace
# Result: ["2024-01-15", "10:30:45", "ERROR", "Connection", "timeout"]
timestamp = " ".join(parts[:2])          # Join first 2 parts: "2024-01-15 10:30:45"
level = parts[2]                         # "ERROR"
message = " ".join(parts[3:])            # Join from index 3: "Connection timeout"

# ─── Split with delimiter ─────────────────────────────────
csv_line = "web01,10.0.0.1,80,running"
fields = csv_line.split(",")             # Split by comma
name = fields[0]                         # "web01"
ip = fields[1]                           # "10.0.0.1"

# ─── Parse Command Output ─────────────────────────────────
import subprocess
result = subprocess.run(["df", "-h", "/"], capture_output=True, text=True)
# result.stdout now contains the df output as a string

lines = result.stdout.strip().split("\n")  # Split into lines
header = lines[0]                          # First line = header
data_line = lines[1]                       # Second line = the data
parts = data_line.split()                  # Split data by whitespace
filesystem = parts[0]                      # Device name
size = parts[1]                            # Total size
use_pct = parts[4]                         # Use percentage (e.g., "75%")

# ─── csv Module (for real CSV) ────────────────────────────
import csv
with open("servers.csv", "r") as f:
    reader = csv.DictReader(f)             # DictReader: first row = field names
    for row in reader:                     # Each row is a dict
        print(f"{row['name']} -> {row['ip']}:{row['port']}")
```