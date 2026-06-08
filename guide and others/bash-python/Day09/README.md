# Day 9 - grep vs Python Search

## 🐚 Bash: grep

```bash
# ═══════════════════════════════════════════════════════════════
# GREP - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

grep "ERROR" app.log                    # Basic: print lines containing "ERROR"
grep -i "error" app.log                 # -i = case INSENSITIVE (matches ERROR, Error, error)
grep -c "ERROR" app.log                 # -c = COUNT matches (just the number)
grep -n "ERROR" app.log                 # -n = show LINE NUMBERS
grep -v "INFO" app.log                  # -v = INVERT match (show NON-matching lines)
grep -l "ERROR" *.log                   # -l = show only FILENAMES with matches
grep -w "ERROR" app.log                 # -w = WHOLE WORD (not "ERRORS" or "ERROR_LOG")
grep -r "TODO" /home/user/project/      # -r = RECURSIVE (search all files in directory)

# ─── Context Lines ─────────────────────────────────────────
grep -B 5 "ERROR" app.log               # -B 5 = 5 lines BEFORE match
grep -A 5 "ERROR" app.log               # -A 5 = 5 lines AFTER match
grep -C 3 "ERROR" app.log               # -C 3 = 3 lines CONTEXT (both sides)

# ─── Regular Expressions ──────────────────────────────────
grep "^2024-01-15" app.log             # ^ = line STARTS with "2024-01-15"
grep "10\.0\.0\." app.log             # \. = literal dot (escaped)
grep -E "ERROR|FATAL|CRITICAL" app.log # -E = extended regex: | = OR
grep "error.*timeout" app.log          # .* = any characters between "error" and "timeout"

# ─── Practical ────────────────────────────────────────────
ERRORS=$(grep -c "ERROR" app.log)       # Count ERRORs, store in variable
grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" access.log | sort -u
# -o = only matching text (not whole line)
# \b = word boundary, \.{3} = dot 3 times
# | sort -u = sort and remove duplicates
```

---

## 🐍 Python: String Search

```python
# ═══════════════════════════════════════════════════════════════
# STRING SEARCH - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Simple "in" Operator (FASTEST) ────────────────────────
with open("app.log") as f:
    for line in f:
        if "ERROR" in line:              # "in" is Python's membership test
            print(line.rstrip())          # rstrip() removes trailing newline

# ─── count() Method ────────────────────────────────────────
with open("app.log") as f:
    content = f.read()
error_count = content.count("ERROR")     # .count() = number of occurrences

# ─── Regular Expressions (re module) ──────────────────────
import re

# search() = find FIRST match in each line
with open("app.log") as f:
    for line in f:
        if re.search(r"ERROR|FATAL", line):  # r"" = raw string (no \ escaping needed)
            print(line.rstrip())

# findall() = find ALL matches in a string
with open("app.log") as f:
    content = f.read()
ips = re.findall(r"\b(?:\d{1,3}\.){3}\d{1,3}\b", content)
# \b = word boundary
# (?:...) = non-capturing group
# \d{1,3} = 1 to 3 digits
# \. = literal dot
# {3} = repeat 3 times

# compile() for PERFORMANCE (reuse same pattern)
pattern = re.compile(r"ERROR", re.IGNORECASE)  # Pre-compile for speed
with open("large_file.log") as f:
    for line in f:
        if pattern.search(line):               # Reuse compiled pattern
            count += 1
```