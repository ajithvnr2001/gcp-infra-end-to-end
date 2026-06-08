# Day 1 - Variables + Output

## 🎯 Motivation
Variables and output are the foundation of all scripting. In DevOps, you constantly need to:
- Display system information (hostname, date, user)
- Store command outputs for reuse
- Build dynamic scripts that adapt to different environments

## 📚 Learning Objectives
- Understand variable assignment in Bash and Python
- Learn different output methods
- Practice capturing system information

---

## 🐚 Bash: Variables & Output

### Variable Assignment

```bash
# ═══════════════════════════════════════════════════════════════
# BASH VARIABLES - LINE BY LINE EXPLANATION
# ═══════════════════════════════════════════════════════════════

name="server01"           # Assign string "server01" to variable 'name'
                          # NO spaces around = sign! "name = server01" is WRONG
count=5                   # Assign number 5 to variable 'count'
                          # In Bash, ALL variables are strings by default

# ─── Command Substitution ($(command)) ────────────────────────
# Captures the OUTPUT of a command into a variable
# This is THE most important Bash concept for DevOps

hostname=$(hostname)      # Run 'hostname' command, store its output in 'hostname'
                          # $(...) is the MODERN syntax (recommended over backticks `...`)
                          # After this runs: hostname="server-name-01"

current_date=$(date)      # Run 'date' command, store current date/time string
                          # After this runs: current_date="Mon Jun  8 12:00:00 UTC 2026"

user=$(whoami)            # Run 'whoami' to get current username
                          # After this runs: user="ajith"

# ─── Read-only Variable ──────────────────────────────────────
# Once set, cannot be changed - prevents accidental overwrites

readonly PI=3.14159       # Declare PI as read-only constant
                          # PI=3.14  would now give error: PI: readonly variable

# ─── Export Variable ──────────────────────────────────────────
# Makes variable available to CHILD PROCESSES (sub-shells, scripts you call)

export ENV="production"   # Export so scripts called FROM this script can see $ENV
                          # Without 'export', child scripts won't see this variable
```

### Output Methods

```bash
# ═══════════════════════════════════════════════════════════════
# BASH OUTPUT - LINE BY LINE EXPLANATION
# ═══════════════════════════════════════════════════════════════

# ─── echo (Simple output) ────────────────────────────────────
# echo automatically adds a newline at the end

echo "Server: $hostname"    # Print "Server: " followed by the VALUE of variable hostname
                             # $hostname gets REPLACED with the actual hostname string
                             # Output: Server: server-name-01

echo "Date: $current_date"  # Print "Date: " followed by the date string
echo "User: $user"          # Print "User: " followed by username

# ─── printf (Formatted output - more control) ────────────────
# Like C's printf(). More control but more complex.
# %s = string placeholder, \n = newline

printf "Server: %s\nDate: %s\nUser: %s\n" "$hostname" "$current_date" "$user"
#         ↑ placeholders          ↑  ↑ three values for placeholders
# Output:
# Server: server-name-01
# Date: Mon Jun  8 12:00:00 UTC 2026
# User: ajith

# ─── Special Variables ────────────────────────────────────────
# These are built-in variables that hold information about the script itself

echo "Script name: $0"            # $0 = path/name of the current script
                                   # If you ran: ./myscript.sh
                                   # Then $0 = "./myscript.sh"
echo "First argument: $1"         # $1 = first argument passed to script
                                   # If you ran: ./script.sh alice bob
                                   # Then $1 = "alice", $2 = "bob"
echo "All arguments: $@"          # $@ = ALL arguments as separate words
                                   # Useful in loops: for arg in "$@"
echo "Exit code: $?"              # $? = exit code of the LAST command
                                   # 0 = success, non-zero = error
                                   # Critical for error checking!
```

### Practice Exercise

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SYSTEM INFORMATION SCRIPT - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

HOST=$(hostname)          # Run 'hostname' command, store output in HOST variable
                          # $() captures the command's stdout

DATE=$(date)              # Run 'date' command, store date string in DATE

USER=$(whoami)            # Run 'whoami' to get current username

UPTIME=$(uptime -p)       # Run 'uptime -p' (pretty format), get "up 2 hours, 15 minutes"
                          # -p flag shows human-readable uptime

KERNEL=$(uname -r)        # Run 'uname -r' to get kernel version like "5.15.0-91-generic"

# Display header
echo "========================================="
echo "       SYSTEM INFORMATION REPORT"
echo "========================================="

# printf with formatted columns
printf "Hostname: %s\n" "$HOST"     # %s = string placeholder, replaced by $HOST
printf "Date: %s\n" "$DATE"         # Same pattern for each field
printf "Current User: %s\n" "$USER"
printf "Uptime: %s\n" "$UPTIME"
printf "Kernel: %s\n" "$KERNEL"

echo "========================================="

# ╔══════════════════════════════════════════════════════════════╗
# ║  KEY TAKEAWAY: $(command) captures command output          ║
# ║  echo prints text + variables                              ║
# ║  printf gives formatted output control                     ║
# ╚══════════════════════════════════════════════════════════════╝
```

---

## 🐍 Python: Variables & Output

### Variable Assignment

```python
# ═══════════════════════════════════════════════════════════════
# PYTHON VARIABLES - LINE BY LINE EXPLANATION
# ═══════════════════════════════════════════════════════════════

# ─── Basic Variables ─────────────────────────────────────────
# Python is DYNAMALLY TYPED - you don't declare the type.
# The type is determined by what you assign.

name = "server01"         # Create variable 'name' holding string "server01"
                          # Type: str (string)

count = 5                 # Create variable 'count' holding integer 5
                          # Type: int (integer)

is_active = True          # Create variable 'is_active' holding boolean True
                          # Type: bool (boolean). Note: Capital T! True, not true

# ─── Multiple Assignment ─────────────────────────────────────
# Assign multiple variables in one line - values match positions

cpu, memory, disk = 4, 16, 500
#   ↑     ↑     ↑     ↑   ↑   ↑
# cpu=4, memory=16, disk=500
# Order MATTERS: first value goes to first variable

# ─── Dynamic Typing ──────────────────────────────────────────
# Variables can CHANGE TYPE - this works but is NOT recommended
# because it makes code confusing

status = "running"        # status is now a string
print(type(status))       # <class 'str'>

status = 1                # status is NOW an integer (same variable!)
print(type(status))       # <class 'int'>
# This works in Python but DON'T do it - it's confusing

# ─── Type Hints (Python 3.5+) ───────────────────────────────
# Optional way to INDICATE what type a variable should be.
# Python doesn't ENFORCE it, but tools and IDEs use it.

server_name: str = "web-01"   # : str  says "this should be a string"
                               # If you assign server_name = 123, Python won't complain
                               # But your IDE will warn you

port: int = 8080              # : int  says "this should be an integer"
```

### Output Methods

```python
# ═══════════════════════════════════════════════════════════════
# PYTHON OUTPUT - LINE BY LINE EXPLANATION
# ═══════════════════════════════════════════════════════════════

# ─── print() - Basic Output ─────────────────────────────────
# print() automatically adds a newline (\n) at the end.
# You can pass MULTIPLE arguments separated by commas.
# print() adds a space between each argument.

print("Server:", hostname)
#            ↑         ↑
#            str     variable
# Output: Server: server-name-01
# Note: comma adds a space automatically

print("Date:", current_date)
# Output: Date: 2026-06-08 12:00:00

print("User:", user)
# Output: User: ajith

# ─── f-strings (Python 3.6+) - RECOMMENDED ──────────────────
# The "f" before the string means "format string".
# Any {variable} inside gets replaced with the variable's VALUE.
# This is the CLEANEST and FASTEST way to format strings.

print(f"Server: {hostname}")
#      ↑          ↑
#      f-string   variable inside {} gets replaced
# Output: Server: server-name-01

print(f"Date: {current_date}")
print(f"User: {user}")

# ─── .format() Method ────────────────────────────────────────
# Older way - still useful in older codebases
# {} are placeholders, .format() fills them in order

print("Server: {}, Date: {}, User: {}".format(hostname, current_date, user))
#         ↑ first {}     ↑ second {}    ↑ third {}
#         gets hostname  gets date      gets user

# ─── sys.stdout.write - No Newline ──────────────────────────
# Unlike print(), write() does NOT add \n at the end.
# You need to explicitly add \n or call .flush()

import sys                        # Import the sys module (system functions)
sys.stdout.write("Loading...")    # Write to stdout without newline
                                  # Output: Loading... (no newline)
sys.stdout.flush()                # Force the buffer to write to console NOW
                                  # Without flush(), output may be delayed
```

### Capturing System Info in Python

```python
# ═══════════════════════════════════════════════════════════════
# CAPTURING SYSTEM INFO - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import os                         # Import os module for OS-level operations
import socket                     # Import socket module for network operations
import platform                   # Import platform module for system identification
from datetime import datetime     # Import datetime class from datetime module

# ─── Get System Information ──────────────────────────────────

hostname = socket.gethostname()   # Call gethostname() from socket module
                                   # Returns: "my-pc" or "server-01.example.com"

current_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
#              ↑                    ↑
#              current date/time    format as string
# %Y = year (2026), %m = month (06), %d = day (08)
# %H = hour (24h), %M = minute, %S = second
# Returns: "2026-06-08 12:00:00"

user = os.getenv("USER") or os.getenv("USERNAME")
#      ↑                      ↑
#      Try Linux USER env var  If None, try Windows USERNAME
# os.getenv() reads ENVIRONMENT VARIABLES (like Linux $USER)
# The 'or' means: if first is None, try second

kernel = platform.release()       # Get OS kernel version
                                   # Linux: "5.15.0-91-generic"
                                   # Windows: "10.0.19045"

platform_info = platform.platform()
# Returns: "Linux-5.15.0-91-generic-x86_64-with-glibc2.31"
# This gives a comprehensive OS description

print(f"Hostname: {hostname}")
print(f"Date: {current_date}")
print(f"User: {user}")
print(f"Kernel: {kernel}")
print(f"Platform: {platform_info}")
```

### Practice Exercise

```python
#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# SYSTEM INFORMATION SCRIPT - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import os                         # For OS operations like getting username
import socket                     # For network operations like getting hostname
import platform                   # For getting OS version
from datetime import datetime     # For getting current date/time

def get_system_info():
    """Collect and return system information as dictionary"""
    # Create a dictionary {} with key:value pairs
    return {
        "hostname": socket.gethostname(),          # key "hostname" → value from gethostname()
        "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),  # formatted datetime
        "user": os.getenv("USER") or os.getenv("USERNAME", "unknown"),
        #        ↑              ↑                    ↑
        #        try Linux var   Fallback to Windows   Last fallback string
        "kernel": platform.release(),               # Kernel version string
        "platform": platform.platform(),            # Full platform description
        "python_version": platform.python_version() # Python version string
    }

def display_info(info):
    """Display system info with formatting"""
    print("=" * 40)              # Print 40 equals signs as border
    print("    SYSTEM INFORMATION REPORT")
    print("=" * 40)
    
    # Loop through each key:value pair in the dictionary
    # .items() returns (key, value) tuples
    for key, value in info.items():
        # .replace("_", " ") converts "hostname" → "hostname" (no change)
        # .title() capitalizes first letter: "hostname" → "Hostname"
        print(f"{key.replace('_', ' ').title()}: {value}")
    
    print("=" * 40)

# ─── This is the Python "main guard" ─────────────────────────
# __name__ is "__main__" ONLY when you run this file directly
# If this file is imported somewhere else, __name__ = "day1_system_info"
# This allows the file to be used both as a script AND as an importable module

if __name__ == "__main__":
    info = get_system_info()      # Call function to get info dict
    display_info(info)            # Pass dict to display function

# ╔══════════════════════════════════════════════════════════════╗
# ║  KEY TAKEAWAY:                                              ║
# ║  Python uses os/socket/platform modules for system info     ║
# ║  f-strings (f"{var}") are the best way to output            ║
# ║  Functions (def) organize reusable code                     ║
# ║  if __name__ == "__main__" controls script execution        ║
# ╚══════════════════════════════════════════════════════════════╝
```

---

## 🔄 Same Problem in Both Languages

### Problem: Create a script that prints hostname, date, and current user

#### Bash Solution

```bash
#!/bin/bash
# LINE BY LINE:
echo "Hostname: $(hostname)"    # $(hostname) → runs hostname, replaces with output
                                 # echo prints: Hostname: server-01

echo "Date: $(date)"            # $(date) → runs date command inline
                                 # echo prints: Date: Mon Jun  8 12:00:00 UTC 2026

echo "User: $(whoami)"          # $(whoami) → runs whoami inline
                                 # echo prints: User: ajith
# The $() COMMAND SUBSTITUTION runs a command and replaces itself with the output
# This is a Bash-only feature - it happens BEFORE echo runs
```

#### Python Solution

```python
#!/usr/bin/env python3
# LINE BY LINE:

import socket                   # Import socket module for gethostname()
from datetime import datetime   # Import datetime class for now()
import os                       # Import os module for getenv()

# socket.gethostname() returns the computer's hostname as a string
# f"{...}" inserts the value inside {} into the string
print(f"Hostname: {socket.gethostname()}")

# datetime.now() returns current date/time
# .strftime() formats it as a string
print(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

# os.getenv("USER") reads the USER environment variable (Linux/macOS)
# Falls back to os.getenv("USERNAME") for Windows
print(f"User: {os.getenv('USER') or os.getenv('USERNAME')}")
```

---

## 💪 Hands-On Exercises

### Exercise 1: Environment Info Script
```bash
# What to do:
# 1. Print all environment variables containing "PATH"
#    Hint: echo $PATH  (shows PATH variable)
#    Hint: env | grep PATH  (filters env vars)

# 2. Print home directory
#    Hint: echo $HOME

# 3. Print current working directory
#    Hint: pwd command or $PWD variable

# 4. Print shell being used (Bash) / Python executable
#    Bash: echo $SHELL
#    Python: import sys; print(sys.executable)
```

### Exercise 2: Dynamic Message Generator
```bash
# What to do:
# 1. Take name as first argument: $1
# 2. Get current time: $(date)
# 3. Get day of week: $(date +%A)   (%A = full weekday name)
# 4. Print: "Hello <name>! Today is <day>. Current time: <time>"
```

### Exercise 3: Server Inventory Entry
```bash
# What to do:
# 1. Get hostname: $(hostname)
# 2. Get IP address: $(hostname -I)  (bash), socket.gethostbyname() (Python)
# 3. Get OS type: $(uname -s) (bash), platform.system() (Python)
# 4. Save to file: echo "data" > inventory_$(date +%Y%m%d).txt
```

---

## 🎯 Interview Questions for Day 1

1. **Bash**: What's the difference between `var=value` and `var = value`?
   - `var=value` = ASSIGNMENT (correct). `var = value` = COMPARISON (runs `var` command with args `=` and `value`)

2. **Bash**: How do you capture command output into a variable?
   - `var=$(command)` or `` var=`command` `` (modern: use $())

3. **Bash**: Difference between `$@` and `$*`?
   - `$@` = each arg as separate word (for loops). `$*` = all args as single string

4. **Python**: What are f-strings and why are they preferred?
   - `f"Hello {name}"` - fastest, most readable string formatting

5. **Python**: How do you get environment variables in Python?
   - `os.getenv("VAR_NAME")` or `os.environ.get("VAR_NAME")`

6. **Both**: How would you make a script executable?
   - `chmod +x script.sh` (bash), `chmod +x script.py` (Python)

---

## ✅ Day 1 Checklist
- [ ] Can create variables in both languages
- [ ] Can output formatted text using echo/printf and print/f-strings
- [ ] Can capture system information (hostname, date, user)
- [ ] Understand $() command substitution in Bash
- [ ] Understand os/socket/platform modules in Python
- [ ] Completed all 3 exercises

---

## 📖 Resources
- [Bash Variables](https://www.gnu.org/software/bash/manual/html_node/Shell-Variables.html)
- [Python Variables](https://docs.python.org/3/tutorial/introduction.html#using-python-as-a-calculator)
- [f-strings](https://realpython.com/python-f-strings/)