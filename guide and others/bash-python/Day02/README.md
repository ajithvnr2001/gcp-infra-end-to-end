# Day 2 - Conditions (if/else)

## 🎯 Motivation
Conditions make scripts intelligent. In DevOps, you need to:
- Check if a file exists before acting on it
- Alert when disk usage exceeds threshold (>80%)
- Verify if a service is running or stopped
- Make decisions based on command exit codes

---

## 🐚 Bash: Conditions

### if/elif/else Structure

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# IF/ELIF/ELSE - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Basic Structure ─────────────────────────────────────────
# if [ condition ]; then     ← Start with 'if', condition in [ ], end with '; then'
#     commands               ← If condition is TRUE, these commands run
# elif [ other_condition ]; then
#     commands               ← If elif is true (and if was false)
# else                       ← If NONE of the above are true
#     commands
# fi                         ← 'fi' closes the if block (if spelled backwards!)

if [ "$var" = "hello" ]; then     # [] = test command. Compare $var to "hello"
    echo "Variable is hello"       # Runs only if condition above is TRUE
fi                                # ALWAYS close with fi! Forgetting fi is a syntax error
```

### String Comparison

```bash
# ═══════════════════════════════════════════════════════════════
# STRING COMPARISONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# IMPORTANT: Always QUOTE your variables! "$var" not $var
# Without quotes: if $var is empty, [ = "hello" ] → syntax error!
# With quotes: [ "" = "hello" ] → valid comparison (false)

[ "$var" = "value" ]              # EQUAL: Check if var equals "value"
                                  # Single = is string comparison in [ ]
                                  # Note: Spaces around = are REQUIRED

[ "$var" == "value" ]             # EQUAL (bash-specific): Same as = but more readable
                                  # Works in bash, NOT in sh (POSIX)
                                  # Use == if you know you're using bash

[ "$var" != "value" ]             # NOT EQUAL: Check if var does NOT equal "value"
                                  # ! = negation operator

[ -z "$var" ]                     # IS EMPTY: Check if var has zero length
                                  # -z = "zero length"
                                  # TRUE if var="" or var is unset

[ -n "$var" ]                     # IS NOT EMPTY: Check if var has non-zero length
                                  # -n = "non-zero length"
                                  # TRUE if var contains anything
```

### Numeric Comparison

```bash
# ═══════════════════════════════════════════════════════════════
# NUMERIC COMPARISONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# WARNING: For NUMBERS use -eq, -ne, -gt, -ge, -lt, -le
# Do NOT use =, !=, >, < for numbers in [ ]!

[ "$a" -eq "$b" ]                 # EQUAL: a == b (numeric)
[ "$a" -ne "$b" ]                 # NOT EQUAL: a != b (numeric)
[ "$a" -gt "$b" ]                 # GREATER THAN: a > b (numeric)
[ "$a" -ge "$b" ]                 # GREATER OR EQUAL: a >= b
[ "$a" -lt "$b" ]                 # LESS THAN: a < b (numeric)
[ "$a" -le "$b" ]                 # LESS OR EQUAL: a <= b

# Why not use > in [ ]?
# [ 5 > 3 ] is actually: [ 5 ] > 3  → redirects output to file "3"!
# [ ] treats > as REDIRECTION, not comparison!
```

### File Tests

```bash
# ═══════════════════════════════════════════════════════════════
# FILE TESTS - LINE BY LINE (MOST COMMON DEVOPS USE)
# ═══════════════════════════════════════════════════════════════

[ -f "$file" ]                    # Is it a REGULAR file (not directory, not device)?
[ -d "$dir" ]                     # Is it a DIRECTORY?
[ -e "$path" ]                    # Does the path EXIST (file, dir, link, anything)?
[ -s "$file" ]                    # Is file SIZE > 0 bytes? (non-empty)
[ -r "$file" ]                    # Is file READABLE by current user?
[ -w "$file" ]                    # Is file WRITABLE by current user?
[ -x "$file" ]                    # Is file EXECUTABLE by current user?
[ -L "$file" ]                    # Is it a SYMLINK?
```

### Combining Conditions

```bash
# ═══════════════════════════════════════════════════════════════
# COMBINING CONDITIONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── AND with && ─────────────────────────────────────────────
# Both conditions must be TRUE

[ "$cpu" -gt 80 ] && [ "$mem" -gt 80 ]
#   ↑ condition 1     ↑ condition 2
# Returns TRUE (0) ONLY if BOTH conditions are true

# ─── OR with || ──────────────────────────────────────────────
# At least ONE condition must be TRUE

[ "$disk" -gt 90 ] || [ "$disk" -gt 80 ] && [ "$alert" = "yes" ]
#   ↑ condition 1    ↑ condition 2        ↑ condition 3
# || has LOWER priority than &&. Use parentheses for clarity

# ─── Double Brackets [[ ]] (Bash-specific, MORE POWERFUL) ────
# [[ ]] is MORE POWERFUL than [ ] because:
# 1. NO WORD SPLITTING - variables with spaces work correctly
# 2. PATTERN MATCHING with == and !=
# 3. REGEX MATCHING with =~
# 4. You can use && and || INSIDE (no need for -a and -o)

[[ "$var" == *pattern* ]]         # Pattern matching: * = any characters
                                  # TRUE if var CONTAINS "pattern" anywhere
                                  # [[ "$name" == *web* ]] matches "web01", "web-prod"

[[ "$var" =~ ^[0-9]+$ ]]         # REGEX matching: ^ = start, [0-9]+ = digits, $ = end
                                  # =~ means "matches regex pattern"
                                  # TRUE if var is ALL DIGITS like "12345"
```

### Exit Codes

```bash
# ═══════════════════════════════════════════════════════════════
# EXIT CODES - LINE BY LINE (CRITICAL FOR DEVOPS)
# ═══════════════════════════════════════════════════════════════

# Every command returns a NUMBER (0-255) when it finishes:
#   0  = SUCCESS
#   any non-zero = FAILURE (1 = general error, 127 = command not found, etc.)

command_succeeds && echo "Success"    # && = run next ONLY if previous succeeded
#                                     # Echo runs only if command_succeeds returns 0
#                                     # This is equivalent to:
#                                     # if command_succeeds; then echo "Success"; fi

command_fails || echo "Failed"        # || = run next ONLY if previous FAILED
#                                     # Echo runs only if command_fails returns non-zero
#                                     # This is equivalent to:
#                                     # if ! command_fails; then echo "Failed"; fi

command1; command2                    # ; = just separates commands, runs REGARDLESS
#                                     # command2 runs even if command1 fails!

# ─── Checking $? after a command ──────────────────────────────
some_command                          # Run any command
if [ $? -eq 0 ]; then                 # $? holds exit code of LAST command
    echo "Success"                    # $? == 0 means success
else
    echo "Failed with code: $?"       # $? != 0 means failure
fi
```

### Practice Exercise

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# DISK CHECK SCRIPT - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

THRESHOLD=80                          # Set alert threshold at 80%
                                      # If disk > 80%, we alert

MOUNT_POINT="/"                       # Monitor root filesystem

# ─── Get disk usage percentage ───────────────────────────────
# df -h: disk free in human-readable format
# awk 'NR==2 {print $5}': NR==2 = line 2, $5 = 5th column (the usage %)
# sed 's/%//': remove the % sign so we have a plain number

USAGE=$(df -h "$MOUNT_POINT" | awk 'NR==2 {print $5}' | sed 's/%//')
#    ↑
#    CAPTURE the output of the entire pipeline
#    Pipeline: df → awk extracts column 5 → sed removes %
#    Result: USAGE gets a number like "75" or "92"

echo "Disk usage: ${USAGE}%"

# ─── Compare and act ─────────────────────────────────────────
# ${USAGE} = variable content. We compare with $THRESHOLD

if [ "$USAGE" -gt "$THRESHOLD" ]; then
    # Only enters here if USAGE > 80
    echo "⚠️  ALERT: Disk usage is ${USAGE}% (threshold: ${THRESHOLD}%)"
    echo "Action: Consider clearing old logs or expanding storage"
    exit 1                              # exit with code 1 = error/alert

elif [ "$USAGE" -gt "$((THRESHOLD - 10))" ]; then
    # Only enters here if previous was false AND USAGE > 70
    # $((THRESHOLD - 10)) → arithmetic: 80 - 10 = 70
    echo "⚠️  WARNING: Disk usage at ${USAGE}% - approaching threshold"
    exit 2                              # exit with code 2 = warning

else
    # Enters here if USAGE <= 70
    echo "✅ OK: Disk usage is normal"
    exit 0                              # exit with code 0 = all good
fi

# ─── EXIT CODES IN DEVOPS ────────────────────────────────────
# exit 0 = success (monitoring system: no action needed)
# exit 1 = warning (monitoring system: log it)
# exit 2 = critical (monitoring system: page someone!)
# Different exit codes help automation tools know what happened
```

---

## 🐍 Python: Conditions

### if/elif/else Structure

```python
# ═══════════════════════════════════════════════════════════════
# IF/ELIF/ELSE - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Basic Structure ─────────────────────────────────────────
# Python uses INDENTATION instead of { } or then/fi
# The colon (:) at the end of if/elif/else is REQUIRED
# The indented block under it is what runs

if condition:               # Colon REQUIRED - means "the block follows"
    # code if true          # 4 spaces (or 1 tab) indentation is REQUIRED
    # MUST be indented!     # Python enforces consistent indentation

elif other_condition:       # elif = else + if (Python-specific shorthand)
    # code if elif true

else:                       # else catches everything not caught above
    # code if none true
```

### Comparison Operators

```python
# ═══════════════════════════════════════════════════════════════
# COMPARISON OPERATORS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Numeric Comparisons ─────────────────────────────────────
# Python uses plain SYMBOLS, not -eq, -ne like Bash

a == b                      # EQUAL: Is a equal to b?
a != b                      # NOT EQUAL: Is a different from b?
a > b                       # GREATER THAN: Is a bigger than b?
a >= b                      # GREATER OR EQUAL
a < b                       # LESS THAN
a <= b                      # LESS OR EQUAL

# ─── String Comparisons ─────────────────────────────────────
s == "hello"                # EQUAL: Is string exactly "hello"?
s != "world"                # NOT EQUAL: Is string NOT "world"?

"hello" in s                # CONTAINS: Does s CONTAIN "hello"?
                            # "Error" in log_line → TRUE if "Error" appears anywhere

s.startswith("prefix")      # STARTS WITH: Does s begin with "prefix"?
s.endswith("suffix")        # ENDS WITH: Does s end with "suffix"?

# ─── Identity vs Equality ───────────────────────────────────
# == checks if VALUES are the same
# is checks if they are the SAME OBJECT in memory

a is b                      # SAME OBJECT: a and b reference the same memory location
a is None                   # NONE CHECK: Is a the None object?
                            # ALWAYS use "is None", NEVER "== None"

# ─── Membership ─────────────────────────────────────────────
# Check if an element exists in a collection

x in [1, 2, 3]              # IN LIST: Is x one of these values?
x not in {"key": "value"}   # NOT IN DICT: Is x NOT a key in this dict?
```

### Combining Conditions

```python
# ═══════════════════════════════════════════════════════════════
# COMBINING CONDITIONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── AND ─────────────────────────────────────────────────────
# BOTH conditions must be True

if cpu > 80 and mem > 80:           # and = both must be True
    print("Both high")               # Only runs if cpu>80 AND mem>80

# ─── OR ──────────────────────────────────────────────────────
# At LEAST ONE condition must be True

if disk > 90 or (disk > 80 and alert_enabled):
    #     ↑ first      ↑ second condition group (parentheses for clarity)
    print("Alert!")                  # Runs if disk>90, OR (disk>80 AND alerts on)

# ─── NOT ─────────────────────────────────────────────────────
# INVERTS a condition (True becomes False, False becomes True)

if not service_running:              # not = "the opposite of"
    print("Service is down")         # Runs if service_running is False

# ─── Chained Comparisons (Python-Specific!) ──────────────────
# Python lets you chain comparisons like in math!

if 80 < disk_usage < 95:             # This means: disk_usage > 80 AND disk_usage < 95
    print("Warning zone")            # Much cleaner than: disk_usage > 80 and disk_usage < 95

# You can chain ANY comparison:
if 0 <= score <= 100:                # Check if score is between 0 and 100 inclusive
    print("Valid score")
```

### Truthiness

```python
# ═══════════════════════════════════════════════════════════════
# TRUTHINESS - LINE BY LINE (IMPORTANT PYTHON CONCEPT)
# ═══════════════════════════════════════════════════════════════

# In Python, every value is either "truthy" or "falsy"
# You can use ANY value directly in an if condition

# ─── Falsy Values (evaluate to False) ───────────────────────
# These are ALL treated as False in conditions:
#   False            → the boolean False
#   None             → the None/null value
#   0, 0.0, 0j       → zero in any numeric form
#   ""               → empty string
#   [], (), {}        → empty list, tuple, dictionary
#   set(), range(0)  → empty set, empty range

# ─── Truthy Values (everything else) ────────────────────────
# Non-empty strings, non-zero numbers, non-empty collections, etc.

# ─── Practical Uses ──────────────────────────────────────────

if not my_list:             # Equivalent to: if len(my_list) == 0:
    print("Empty list")      # Runs if my_list is [] (empty list)

if my_string:                # Equivalent to: if my_string != "":
    print("Non-empty")       # Runs if my_string has any characters

if config:                   # Equivalent to: if config is not None and config != {}:
    print("Config exists")   # Runs if config is a non-empty dict

# These concise checks are considered more "Pythonic" than explicit length checks
```

### Practice Exercise

```python
#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# DISK CHECK SCRIPT - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import shutil                        # shutil = shell utilities (disk operations)
import sys                           # sys = system functions (exit codes)

THRESHOLD = 80                       # Alert if disk > 80% full (CONSTANT, uppercase)

def check_disk_usage(mount_point="/"):
    """Check disk usage for given mount point
    
    shutil.disk_usage() returns a named tuple with:
    - total: total space in bytes
    - used: used space in bytes
    - free: free space in bytes
    """
    usage = shutil.disk_usage(mount_point)
    #    ↑ Result: usage(total=500e9, used=350e9, free=150e9)
    
    percent = (usage.used / usage.total) * 100
    #          ↑                    ↑
    #          used bytes           total bytes
    #          Divide them → decimal, multiply by 100 → percentage
    #          Example: (350e9 / 500e9) * 100 = 70.0
    
    return percent                    # Return the percentage as a float (e.g., 70.0)

def main():
    """Main function - entry point of the script"""
    usage = check_disk_usage()
    #    ↑ Returns float like 70.0 or 92.5
    
    print(f"Disk usage: {usage:.1f}%")
    #                   ↑     ↑
    #                   f-string  :.1f = show 1 decimal place
    #                   Output: "Disk usage: 70.0%"

    if usage > THRESHOLD:
        # Only enters here if percentage > 80
        print(f"⚠️  ALERT: Disk usage is {usage:.1f}% (threshold: {THRESHOLD}%)")
        print("Action: Consider clearing old logs or expanding storage")
        sys.exit(1)                   # Exit with code 1 = error

    elif usage > (THRESHOLD - 10):
        # Only enters here if 70 < usage <= 80 (because first if was False)
        print(f"⚠️  WARNING: Disk usage at {usage:.1f}% - approaching threshold")
        sys.exit(2)                   # Exit with code 2 = warning

    else:
        # Enters here if usage <= 70
        print("✅ OK: Disk usage is normal")
        sys.exit(0)                   # Exit with code 0 = success

if __name__ == "__main__":
    main()

# ╔══════════════════════════════════════════════════════════════╗
# ║  KEY DIFFERENCES FROM BASH:                                 ║
# ║  Python: and, or, not  (Bash: &&, ||, !)                   ║
# ║  Python: >, <, ==, !=   (Bash: -gt, -lt, -eq, -ne for nums)║
# ║  Python: indentation    (Bash: then/fi)                     ║
# ╚══════════════════════════════════════════════════════════════╝
```

---

## 🔄 Same Problem in Both Languages

### Problem: Check if file exists and is readable, then display its size

#### Bash Solution

```bash
#!/bin/bash
# LINE BY LINE:

FILE="/var/log/syslog"                # Path to the file we want to check

# [ -f "$FILE" ] = Is it a regular file? (not a directory, not a device)
# [ -r "$FILE" ] = Is it readable by us?
# && = BOTH conditions must be true

if [ -f "$FILE" ] && [ -r "$FILE" ]; then
    # If we get here: file exists AND is readable
    
    # du -h "$FILE" = disk usage of file, human-readable format
    # cut -f1 = extract first column (the size like "1.2M")
    SIZE=$(du -h "$FILE" | cut -f1)
    echo "File: $FILE | Size: $SIZE"

elif [ ! -e "$FILE" ]; then
    # [ ! -e "$FILE" ] = NOT exists
    # If we get here: file does NOT exist at all
    echo "Error: $FILE does not exist"
    exit 1

else
    # If we get here: file exists but is NOT readable
    echo "Error: $FILE is not readable"
    exit 1
fi
```

#### Python Solution

```python
#!/usr/bin/env python3
# LINE BY LINE:

import os                        # os.path has file checking functions
import sys                       # sys.exit() to return error codes

file_path = "/var/log/syslog"    # Path to the file we want to check

# os.path.isfile() = True if path is a regular file (not directory)
# os.access() with os.R_OK = True if file is readable

if os.path.isfile(file_path) and os.access(file_path, os.R_OK):
    # BOTH conditions must be True
    
    # os.path.getsize() returns size in BYTES
    size_bytes = os.path.getsize(file_path)
    
    # Divide by 1024 to convert bytes → kilobytes
    size_kb = size_bytes / 1024
    
    # :.2f = format as float with 2 decimal places
    print(f"File: {file_path} | Size: {size_kb:.2f} KB")

elif not os.path.exists(file_path):
    # os.path.exists() = True if path exists (file, dir, anything)
    # not exists = it's nowhere to be found
    print(f"Error: {file_path} does not exist")
    sys.exit(1)

else:
    # File exists but is not readable (permissions issue)
    print(f"Error: {file_path} is not readable")
    sys.exit(1)
```

---

## 💪 Hands-On Exercises

### Exercise 1: Service Status Checker
Check if a service (e.g., nginx, sshd) is running:
- **Bash**: `systemctl is-active nginx` returns "active" (exit 0) or "inactive" (exit 3)
- **Python**: `subprocess.run(["systemctl", "is-active", "nginx"])` and check returncode

### Exercise 2: User Input Validator
- Ask for a number (Bash: `read`, Python: `input()`)
- Check if it's positive/negative/zero with `-gt 0`, `-lt 0`, `-eq 0`
- Check if even/odd with modulo: `$((num % 2))` (Bash), `num % 2` (Python)

### Exercise 3: Log File Analyzer
- Check if `app.log` exists: `[ -f "app.log" ]` (Bash), `os.path.isfile("app.log")` (Python)
- Check if > 100MB: `stat -c%s` returns bytes, compare with `104857600` (100*1024*1024)
- Print warning if large

---

## 🎯 Interview Questions for Day 2

1. **Bash**: What's the difference between `[ ]` and `[[ ]]`?
   - `[[ ]]` supports pattern matching (`*`), regex (`=~`), &&/|| inside, no word splitting. `[ ]` is POSIX-compatible but limited.

2. **Bash**: How do you check if a command succeeded?
   - Check `$?` after running, or use `if command; then` directly

3. **Bash**: What does `-z` flag do in test conditions?
   - Returns TRUE if string is EMPTY (zero length)

4. **Python**: What values are considered falsy in Python?
   - `False, None, 0, 0.0, "", [], {}, (), set(), range(0)`

5. **Python**: Difference between `==` and `is`?
   - `==` compares VALUE, `is` compares MEMORY IDENTITY (same object)

---

## ✅ Day 2 Checklist
- [ ] Can write if/elif/else in both languages
- [ ] Can compare numbers, strings, and check file conditions
- [ ] Can combine conditions with and/or/not
- [ ] Understand exit codes in Bash / return values in Python
- [ ] Completed all 3 exercises