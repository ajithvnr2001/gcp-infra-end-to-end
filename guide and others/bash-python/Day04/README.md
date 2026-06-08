# Day 4 - Functions

## 🎯 Motivation
Functions make your scripts modular, reusable, and testable. In DevOps:
- Write `check_disk()` once, use it everywhere
- Build a library of monitoring functions
- Make scripts easier to debug and maintain

---

## 🐚 Bash: Functions

### Defining Functions

```bash
# ═══════════════════════════════════════════════════════════════
# FUNCTIONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Method 1: Classic (POSIX-compatible) ───────────────────
check_disk() {                         # Function name () {
    local threshold=$1                  # $1 = first argument passed to function
                                         # local = variable is LOCAL to this function
                                         # Without local, it becomes GLOBAL - bad!
    df -h / | awk 'NR==2 {print $5}'     # Run df, extract usage percentage
}                                        # } = end of function

# ─── Method 2: Using function keyword ───────────────────────
function check_memory() {               # function keyword is optional (bash-specific)
    free -h | grep Mem                   # Show memory info
}

# ─── Calling functions ──────────────────────────────────────
check_disk 80                           # Call with argument 80 (becomes $1 inside)
check_memory                            # Call without arguments
```

### Arguments and Parameters

```bash
# ═══════════════════════════════════════════════════════════════
# ARGUMENTS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

greet() {
    local name=$1                        # First argument: $1
    
    local greeting=${2:-"Hello"}        # Second argument: $2
                                         # ${2:-"Hello"} = use $2 if provided, otherwise "Hello"
                                         # This is DEFAULT VALUE syntax
    echo "$greeting, $name!"
}

greet "John"                            # name="John", greeting="Hello" (default)
greet "Jane" "Hi"                       # name="Jane", greeting="Hi"

# ─── Multiple Arguments ─────────────────────────────────────
sum() {
    # $(( ... )) = arithmetic. $1 + $2 + $3 = add the three arguments
    local total=$(( $1 + $2 + $3 ))
    echo $total                          # echo OUTPUTS the result (not return)
}

result=$(sum 10 20 30)                  # Capture function's echo output
echo "Total: $result"                    # Prints: Total: 60
```

### Return Values

```bash
# ═══════════════════════════════════════════════════════════════
# RETURN VALUES - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Return EXIT CODES (0-255) ─────────────────────────────
# return stores an exit code, NOT a string result
# Use return for SUCCESS/FAILURE flags

check_file() {
    if [ -f "$1" ]; then                 # -f = is regular file?
        return 0                         # 0 = SUCCESS (file exists)
    else
        return 1                         # 1 = FAILURE (file not found)
    fi
}

# Check function result with if
if check_file "/etc/passwd"; then        # Runs check_file. If returns 0 = success
    echo "File exists"
fi

# ─── Return STRINGS (use echo) ─────────────────────────────
# To "return" a string value, echo it and capture with $()

get_hostname() {
    echo "$(hostname)"                   # echo sends this to stdout
}

host=$(get_hostname)                     # $() captures the echo output
```

### Local and Global Variables

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SCOPE - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

GLOBAL_VAR="I am global"                # Not inside any function = GLOBAL

my_function() {
    local LOCAL_VAR="I am local"         # local keyword = ONLY visible inside this function
    GLOBAL_VAR="Modified by function"    # This MODIFIES the global variable!
    
    echo "Inside: $LOCAL_VAR"           # Prints: "Inside: I am local"
    echo "Inside: $GLOBAL_VAR"          # Prints: "Inside: Modified by function"
}

my_function
echo "Outside: $GLOBAL_VAR"            # Prints: "Outside: Modified by function" (changed!)
echo "Outside: $LOCAL_VAR"             # Prints NOTHING (local variable doesn't exist here)

# LOCAL is critical for writing safe functions that don't affect other parts of your script
```

### Practice Exercise

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SYSTEM MONITORING FUNCTIONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

check_disk() {
    local mount_point=${1:-"/"}          # $1 = first arg, default "/"
    local threshold=${2:-80}             # $2 = second arg, default 80
    
    # df -h: disk free human-readable
    # | awk 'NR==2 {print $5}': line 2, column 5 (the "Use%" column)
    # | sed 's/%//': remove % sign → pure number
    local usage=$(df -h "$mount_point" | awk 'NR==2 {print $5}' | sed 's/%//')
    
    echo "$usage"                        # echo the value for capturing
    
    if [ "$usage" -gt "$threshold" ]; then
        return 1                         # Return 1 = ALERT
    fi
    return 0                             # Return 0 = OK
}

# ─── CPU Check ──────────────────────────────────────────────
check_cpu() {
    local threshold=${1:-90}
    
    # top -bn1: batch mode, 1 iteration
    # grep "Cpu(s)": find the CPU line
    # awk '{print $2}': get the 2nd field (us = user CPU)
    # cut -d. -f1: get integer part only
    local usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    
    echo "$usage"
    if [ "$usage" -gt "$threshold" ]; then
        return 1
    fi
    return 0
}

# ─── Main - Call the functions ──────────────────────────────
echo "=== System Health Check ==="

# Call check_disk, capture the echo'd value
disk_usage=$(check_disk "/" 80)
# $? has the RETURN CODE (0 or 1) from the function
if [ $? -eq 0 ]; then
    echo "✓ DISK: ${disk_usage}%"
else
    echo "✗ DISK: ${disk_usage}% - ALERT!"
fi
```

---

## 🐍 Python: Functions

### Defining Functions

```python
# ═══════════════════════════════════════════════════════════════
# FUNCTIONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

def check_disk():
    """Check disk usage and return percentage"""
    # Triple-quoted string = DOCSTRING (function documentation)
    # This is accessible via help(check_disk) in Python
    
    import shutil                    # Import inside function (valid but unusual)
    
    usage = shutil.disk_usage("/")   # Returns named tuple with total, used, free
    
    # usage.used / usage.total = decimal (e.g., 0.7)
    # * 100 = percentage (e.g., 70.0)
    return (usage.used / usage.total) * 100

result = check_disk()                # Call function, get return value
print(f"Disk usage: {result:.1f}%")
```

### Parameters and Arguments

```python
# ═══════════════════════════════════════════════════════════════
# PARAMETERS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

def greet(name, greeting="Hello"):   # name = required, greeting = optional (default)
    """Greet someone"""
    print(f"{greeting}, {name}!")

greet("John")                        # name="John", greeting="Hello" (default)
greet("Jane", "Hi")                  # name="Jane", greeting="Hi"
greet(name="Bob", greeting="Hey")    # KEYWORD arguments (order doesn't matter)

# ─── *args - Variable Positional Arguments ─────────────────
# The * means "put ALL remaining positional args into a tuple"

def sum_all(*args):                  # args = a tuple of all arguments passed
    return sum(args)                  # sum() adds all numbers in the tuple

print(sum_all(1, 2, 3, 4, 5))        # args = (1, 2, 3, 4, 5), returns 15

# ─── **kwargs - Variable Keyword Arguments ─────────────────
# The ** means "put ALL keyword args into a dictionary"

def server_info(**kwargs):           # kwargs = dict of all keyword args
    for key, value in kwargs.items():
        print(f"{key}: {value}")

server_info(name="web01", ip="10.0.0.1", port=80)
# kwargs = {"name": "web01", "ip": "10.0.0.1", "port": 80}
```

### Return Values

```python
# ═══════════════════════════════════════════════════════════════
# RETURN VALUES - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

def divide(a, b):
    """Return division result or None on error"""
    if b == 0:
        return None, "Division by zero"  # Tuple: (result, error_message)
    return a / b, None                    # (result, None) = no error

result, error = divide(10, 2)
#    ↑       ↑
#    first   second value from tuple
# result = 5.0, error = None

if error:
    print(f"Error: {error}")
else:
    print(f"Result: {result}")

# ─── Multiple Returns as Tuple ─────────────────────────────
def get_server_stats():
    """Return a dictionary of server stats"""
    import psutil
    
    return {
        "cpu": psutil.cpu_percent(),             # Current CPU usage %
        "memory": psutil.virtual_memory().percent, # Current memory usage %
        "disk": psutil.disk_usage("/").percent,   # Current disk usage %
    }

stats = get_server_stats()
print(f"CPU: {stats['cpu']}%")
```

### Lambda Functions (Anonymous)

```python
# ═══════════════════════════════════════════════════════════════
# LAMBDAS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# lambda = a ONE-LINE function without a name
# syntax: lambda arguments: expression
# Use when you need a simple function for a short time

square = lambda x: x ** 2          # Define: takes x, returns x squared
print(square(5))                    # 25

# ─── Used with filter() ────────────────────────────────────
servers = [
    {"name": "web01", "cpu": 45},
    {"name": "web02", "cpu": 92},
    {"name": "db01", "cpu": 30},
]

# filter() takes a function and an iterable
# lambda s: s["cpu"] > 80 = function that returns True for high CPU
high_cpu = list(filter(lambda s: s["cpu"] > 80, servers))
print(high_cpu)                     # [{"name": "web02", "cpu": 92}]

# ─── Used with sorted() ────────────────────────────────────
# sorted() takes a key function that extracts the sort value
sorted_servers = sorted(servers, key=lambda s: s["cpu"])
# Sorts by cpu ascending: db01(30), web01(45), web02(92)
```

### Practice Exercise

```python
#!/usr/bin/env python3
"""System monitoring function library"""

import psutil
import shutil
import logging
from typing import Optional, Tuple

# ─── Setup Logging ──────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,              # Log INFO and above
    format="%(asctime)s - %(levelname)s - %(message)s",  # Include timestamp
)
logger = logging.getLogger(__name__) # Get a logger for this module


def check_disk(mount_point: str = "/", threshold: int = 80) -> Tuple[float, bool]:
    """Check disk usage
    
    Args:
        mount_point: Filesystem to check (default: /)
        threshold: Alert percentage (default: 80%)
    
    Returns:
        Tuple of (usage_percent, is_alert)
    """
    try:
        usage = shutil.disk_usage(mount_point)
        
        percent = (usage.used / usage.total) * 100
        
        return percent, percent > threshold   # Return (value, alert_flag)
    
    except Exception as e:
        logger.error(f"Disk check failed: {e}")
        return -1, True                      # -1 = error, True = alert


def check_cpu(threshold: int = 90) -> Tuple[float, bool]:
    """Check CPU usage"""
    try:
        percent = psutil.cpu_percent(interval=1)  # interval=1 means measure for 1 second
        return percent, percent > threshold
    except Exception as e:
        logger.error(f"CPU check failed: {e}")
        return -1, True


def main():
    """Run all checks and report"""
    print("=== System Health Check ===\n")
    
    checks = [
        ("DISK", check_disk()),          # Call check_disk with defaults
        ("CPU", check_cpu()),
    ]
    
    all_ok = True
    for name, (value, alert) in checks:  # Unpack tuple from function
        icon = "✓" if not alert else "✗"
        print(f"{icon} {name}: {value:.1f}%")
        if alert:
            all_ok = False
    
    print(f"\nOverall: {'PASS' if all_ok else 'ALERT'}")

if __name__ == "__main__":
    main()
```

---

## 🔄 Same Problem in Both Languages

### Problem: Create reusable functions `check_disk()` and `check_service()`

#### Bash Solution

```bash
#!/bin/bash
# LINE BY LINE:

check_disk() {
    local mount=$1                     # First argument: mount point path
    local threshold=$2                 # Second argument: threshold percentage
    
    # df: disk free, $mount: specific mount point
    # awk: NR==2 (line 2), $5 (column 5 = use%)
    # sed: remove % to get plain number
    local usage=$(df -h "$mount" | awk 'NR==2 {print $5}' | sed 's/%//')
    
    echo "$usage"                      # Echo the value (for capturing via $())
    
    # [ "$usage" -gt "$threshold" ] is the last command
    # Its exit code becomes the function's exit code
    [ "$usage" -gt "$threshold" ]      # Returns 0 if usage > threshold (ALERT)
}

# Usage:
# Capture the echo'd value
# $? checks the return code
disk_pct=$(check_disk "/" 80)
if [ $? -eq 0 ]; then                  # 0 = alert condition met
    echo "DISK ALERT: ${disk_pct}%"
fi
```

#### Python Solution

```python
#!/usr/bin/env python3
# LINE BY LINE:

import shutil
import subprocess

def check_disk(mount="/", threshold=80):
    """Return (usage_percent, is_alert)"""
    usage = shutil.disk_usage(mount)    # Get disk stats
    
    percent = (usage.used / usage.total) * 100  # Calculate %
    
    return percent, percent > threshold  # Return tuple

def check_service(service_name):
    """Return True if service is running"""
    result = subprocess.run(
        ["systemctl", "is-active", service_name],
        capture_output=True, text=True
    )
    return result.returncode == 0        # 0 means active

# Usage:
disk_pct, is_alert = check_disk("/", 80)
print(f"Disk OK" if not is_alert else f"Disk ALERT: {disk_pct:.1f}%")
```

---

## 🎯 Interview Q&A

1. **Bash**: How do you return a value from a Bash function?
   - Use `echo` to output (capture with $()), use `return` for exit codes 0-255

2. **Bash**: Why use `local` variables in functions?
   - Prevents accidentally modifying global variables. Without local, functions can overwrite variables in other parts of your script.

3. **Python**: Difference between `return` and `yield`?
   - `return` exits the function and gives ONE value. `yield` creates a generator that can produce MULTIPLE values over time.

4. **Python**: What are `*args` and `**kwargs`?
   - `*args` captures positional arguments as a tuple, `**kwargs` captures keyword arguments as a dict.