# Day 11 - sed vs replace()

## 🐚 Bash: sed

```bash
# ═══════════════════════════════════════════════════════════════
# SED (STREAM EDITOR) - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Basic Substitution ────────────────────────────────────
sed 's/ERROR/ALERT/' app.log              # s = substitute. Replace FIRST occurrence on each line
sed 's/ERROR/ALERT/g' app.log             # g = GLOBAL. Replace ALL occurrences on each line
sed -i 's/ERROR/ALERT/g' app.log          # -i = IN-PLACE edit (modifies file directly!)
sed -i.bak 's/ERROR/ALERT/g' app.log      # -i.bak = in-place WITH BACKUP (app.log.bak)

# ─── Line-Specific ────────────────────────────────────────
sed '3s/ERROR/ALERT/' app.log             # Line 3 only
sed '10,20s/ERROR/ALERT/' app.log         # Lines 10 through 20 only
sed '/FATAL/s/ERROR/ALERT/' app.log       # Only lines CONTAINING "FATAL"

# ─── Delete Lines ─────────────────────────────────────────
sed '/DEBUG/d' app.log                    # d = delete. Remove lines containing DEBUG
sed '/^#/d' config.conf                   # ^# = lines starting with #
sed '/^$/d' file.txt                      # ^$ = empty lines

# ─── Multiple Commands ────────────────────────────────────
sed -e 's/ERROR/ALERT/g' -e 's/WARN/CAUTION/g' app.log  # -e = multiple commands

# ─── Different Delimiters ────────────────────────────────
sed 's|/var/log|/var/log/archive|g' config  # Use | instead of / when path has /
```

---

## 🐍 Python: Replace

```python
# ═══════════════════════════════════════════════════════════════
# STRING REPLACEMENT - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── .replace() - Simple String Replacement ───────────────
text = "Error: Connection timeout on server web01"
cleaned = text.replace("Error", "ALERT")
# Result: "ALERT: Connection timeout on server web01"

# Replace all occurrences (always global for .replace())
text = "error error error"
result = text.replace("error", "bug")     # "bug bug bug"

# Count limit (only replace first N)
text = "a,a,a,a,a"
result = text.replace(",", ";", 3)         # "a;a;a,a,a" (only first 3)
                                            # Third argument = MAX REPLACEMENTS

# ─── re.sub() - Regex Replacement ─────────────────────────
import re

text = "Error code: 404 on server web01"
result = re.sub(r"\d+", "[REDACTED]", text)
# r"\d+" = regex pattern: one or more digits
# Result: "Error code: [REDACTED] on server [REDACTED]"

# Case-insensitive
result = re.sub(r"error", "ALERT", text, flags=re.IGNORECASE)

# Function-based replacement
def mask_ip(match):
    ip = match.group(0)                    # The matched text
    parts = ip.split(".")                   # ["10", "0", "0", "1"]
    return f"{parts[0]}.XXX.XXX.{parts[3]}" # Mask middle octets

text = "Accessed from 10.0.0.1"
result = re.sub(r"\b(?:\d{1,3}\.){3}\d{1,3}\b", mask_ip, text)
# Mask calls the function for each match
# Result: "Accessed from 10.XXX.XXX.1"

# ─── In-File Replacement ─────────────────────────────────
def file_replace(filepath, old, new, backup=True):
    """Replace text in file with backup option"""
    import shutil
    if backup:
        shutil.copy2(filepath, f"{filepath}.bak")   # Create backup
    
    content = open(filepath).read()                  # Read entire file
    content = content.replace(old, new)              # Replace
    open(filepath, "w").write(content)               # Write back
```