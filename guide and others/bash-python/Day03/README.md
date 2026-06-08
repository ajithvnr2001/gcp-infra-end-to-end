# Day 3 - Loops (for/while)

## 🎯 Motivation
Loops eliminate repetitive work. In DevOps, you'll use them to:
- Loop through 100+ servers to check their status
- Process every file in a directory
- Retry operations until success
- Monitor and watch for changes

---

## 🐚 Bash: Loops

### For Loop - Classic

```bash
# ═══════════════════════════════════════════════════════════════
# FOR LOOPS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Simple Range ────────────────────────────────────────────
# "in 1 2 3 4 5" = list of values to loop through
# Each value is assigned to 'i' one at a time

for i in 1 2 3 4 5; do              # for each item in the list 1,2,3,4,5
    echo "Number: $i"                # Print the current value of i
done                                 # done marks the end of the loop block

# ─── Range with Brace Expansion ─────────────────────────────
# {1..10} = the numbers 1 through 10 (Bash expands this BEFORE the loop runs)
# Much cleaner than typing all numbers

for i in {1..10}; do                 # i takes values: 1, 2, 3, ..., 10
    echo "Number: $i"
done

# ─── Step Range (Bash 4+) ───────────────────────────────────
# {START..END..STEP}

for i in {0..100..10}; do           # i takes values: 0, 10, 20, ..., 100
    echo "$i% complete"              # Prints: 0% complete, 10% complete, etc.
done

# ─── C-style For Loop ────────────────────────────────────────
# (( ... )) = arithmetic context. More familiar to C/Java programmers
# Three parts: INITIALIZE; CONDITION; INCREMENT

for ((i=0; i<10; i++)); do          # i=0: start at 0
                                     # i<10: continue while i is less than 10
                                     # i++: add 1 to i each iteration
    echo "Count: $i"                 # Prints: Count: 0, Count: 1, ..., Count: 9
done

# ─── Loop Through Files ─────────────────────────────────────
# /var/log/*.log = ALL files ending in .log (the * is a wildcard)
# Bash expands this to the list of matching files BEFORE the loop runs

for file in /var/log/*.log; do       # file takes each .log file path one at a time
    echo "Processing: $file"          # $file contains the full path like /var/log/syslog
done

# ─── Loop Through Command Output ────────────────────────────
# $(cat /etc/passwd | cut -d: -f1) = list of all usernames
# cat reads file, cut extracts first field (username) from each line, : delimited

for user in $(cat /etc/passwd | cut -d: -f1); do  # user = each username
    echo "User: $user"                              # Print each username
done

# ─── Loop Through Array ────────────────────────────────────
servers=("web01" "web02" "db01")    # Create array with 3 elements

for server in "${servers[@]}"; do    # "${servers[@]}" = ALL elements as separate items
    echo "Checking: $server"         # server = each element one at a time
done
```

### While Loop

```bash
# ═══════════════════════════════════════════════════════════════
# WHILE LOOPS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Counter-based ──────────────────────────────────────────
count=0                              # Initialize counter at 0

while [ "$count" -lt 5 ]; do         # [ condition ]: check BEFORE each iteration
    echo "Count: $count"             # Print current count
    ((count++))                      # (( )) = arithmetic. count++ = add 1 to count
                                     # Equivalent to: count=$((count + 1))
done

# ─── Reading File Line by Line ──────────────────────────────
# IFS=: Clear the Internal Field Separator (preserves leading/trailing spaces)
# read -r: read one line, -r prevents backslash interpretation
# < file: redirect file into the while loop's stdin

while IFS= read -r line; do          # For each line in the file:
    echo "Line: $line"               # Print the line content
done < /path/to/file.txt             # < = input redirection from file

# ─── Infinite Loop with Break ───────────────────────────────
# while true = loop FOREVER (until break)

while true; do                       # condition is always true
    # curl: make HTTP request, -s silent, -o /dev/null discard body
    # -w "%{http_code}" = write ONLY the status code
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
    
    if [ "$STATUS" = "200" ]; then   # HTTP 200 = OK
        echo "Server is UP!"
        break                        # break = EXIT the loop entirely
    fi
    echo "Waiting... current status: $STATUS"
    sleep 5                          # Wait 5 seconds before next check
done

# ─── Watch Loop (Monitoring) ────────────────────────────────
# while sleep 2: run command every 2 seconds
# clear: clear the screen each iteration

while sleep 2; do                    # Loop body runs every 2 seconds
    clear                            # Clear terminal screen
    echo "=== CPU Usage ==="
    top -bn1 | head -5               # top in batch mode, first 5 lines
done
```

### Loop Control

```bash
# ═══════════════════════════════════════════════════════════════
# LOOP CONTROL - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── break - Exit Loop Early ────────────────────────────────
for i in {1..10}; do                 # Would normally run 10 times
    if [ "$i" -eq 5 ]; then
        break                        # break = STOP loop IMMEDIATELY
    fi                               # When i=5, loop exits
    echo "$i"                        # Prints: 1, 2, 3, 4 (stops at 5)
done

# ─── continue - Skip to Next Iteration ─────────────────────
for i in {1..10}; do                 # Runs 10 times
    if [ "$((i % 2))" -eq 0 ]; then  # $(( ... )) = arithmetic expression
        continue                     # skip rest of THIS iteration, go NEXT
    fi                               # When i is even, skip the echo
    echo "Odd: $i"                   # Prints: 1, 3, 5, 7, 9 (odd numbers only)
done
```

### Practice Exercise

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SERVICE CHECKER - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

SERVERS=("172.16.1.10" "172.16.1.11" "172.16.1.12")    # Array of server IPs
PORTS=(80 443 22)                                        # Array of ports to check
LOG_FILE="service_check.log"                             # Output log file

> "$LOG_FILE"                           # > redirect = TRUNCATE (empty) the file
                                        # Ensures we start with a fresh log

echo "Starting service check at $(date)" | tee -a "$LOG_FILE"
# tee: writes to BOTH stdout (screen) AND file (-a = append)
# $(date): inserts current date/time

# ─── Outer Loop: Servers ────────────────────────────────────
for server in "${SERVERS[@]}"; do       # Loop through each server IP
    echo "--- Checking $server ---" | tee -a "$LOG_FILE"
    
    # ─── Inner Loop: Ports ──────────────────────────────────
    for port in "${PORTS[@]}"; do        # Loop through each port
        # timeout 3: kill command after 3 seconds
        # bash -c "echo >/dev/tcp/$server/$port": try TCP connection
        # >/dev/tcp/$server/$port is Bash's built-in TCP feature
        # It opens a TCP connection - if it succeeds, echo succeeds
        # 2>/dev/null: discard error messages
        # && : if connection succeeds, run the echo
        # || : if connection fails, run the echo
        
        timeout 3 bash -c "echo >/dev/tcp/$server/$port" 2>/dev/null && \
            echo "  ✓ Port $port: OPEN" | tee -a "$LOG_FILE" || \
            echo "  ✗ Port $port: CLOSED" | tee -a "$LOG_FILE"
    done
done

echo "Check completed at $(date)" | tee -a "$LOG_FILE"
```

---

## 🐍 Python: Loops

### For Loop

```python
# ═══════════════════════════════════════════════════════════════
# FOR LOOPS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── range() - Sequence of Numbers ─────────────────────────
# range(10) → 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 (stops BEFORE 10)

for i in range(10):                  # i takes each value: 0, 1, 2, ..., 9
    print(f"Number: {i}")

for i in range(5, 10):               # range(START, STOP): 5, 6, 7, 8, 9
    print(f"Number: {i}")

for i in range(0, 100, 10):          # range(START, STOP, STEP): 0, 10, 20, ..., 90
    print(f"{i}% complete")

# ─── Loop Through List ──────────────────────────────────────
servers = ["web01", "web02", "db01"]  # A Python list

for server in servers:                # server = each element one at a time
    print(f"Checking: {server}")

# ─── enumerate() - Loop with Index ──────────────────────────
# enumerate() gives you BOTH the index AND the value
# (idx, server) = unpacking a tuple

for idx, server in enumerate(servers, 1):  # enumerate starting from 1 (not 0)
    print(f"Server {idx}: {server}")        # idx = 1,2,3; server = web01,web02,...

# ─── Loop Through Dictionary ────────────────────────────────
# .items() returns (key, value) pairs

services = {"nginx": 80, "postgresql": 5432, "redis": 6379}
for service, port in services.items():   # Unpack each key-value pair
    print(f"{service} runs on port {port}")

# ─── Loop Through File ──────────────────────────────────────
# "with open" opens the file, automatically closes when done
# "for line in f" reads ONE LINE at a time (doesn't load entire file!)

with open("/var/log/syslog", "r") as f:  # Open file for reading
    for line in f:                        # Read line by line (memory efficient!)
        if "ERROR" in line:                # Only process lines containing "ERROR"
            print(line.rstrip())            # rstrip() removes trailing newline

# ─── zip() - Loop Through Multiple Lists ────────────────────
# zip() pairs up elements from multiple lists by position

hosts = ["web01", "web02", "db01"]
ips = ["10.0.0.1", "10.0.0.2", "10.0.0.3"]

for host, ip in zip(hosts, ips):     # First: web01+10.0.0.1, Second: web02+10.0.0.2
    print(f"{host} -> {ip}")

# ─── List Comprehension (Pythonic Shortcut) ─────────────────
# Creates a NEW list by transforming each element
# [ expression  for variable  in iterable  if condition ]

squares = [x**2 for x in range(10)]
#          ↑     ↑     ↑
#          what   loop  optional filter
# Result: [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# Read error lines into a list (one-liner!)
errors = [line for line in open("app.log") if "ERROR" in line]
#        ↑                        ↑                ↑
#        keep this line           for each line     only if "ERROR" in it
```

### While Loop

```python
# ═══════════════════════════════════════════════════════════════
# WHILE LOOPS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Counter-based ──────────────────────────────────────────
count = 0                            # Initialize counter

while count < 5:                     # Check condition BEFORE each iteration
    print(f"Count: {count}")         # Print current count
    count += 1                       # Same as count = count + 1
                                     # Python has NO count++ operator!

# ─── Server Health Check with Retry ─────────────────────────
# Real DevOps pattern: retry a failing check

import time
import requests

server_healthy = False               # Flag: are we done?
attempts = 0                         # How many times have we tried?
max_attempts = 5                     # Give up after this many

while not server_healthy and attempts < max_attempts:
    # Continue looping while BOTH:
    # 1. server is NOT healthy yet
    # 2. we haven't exhausted our attempts
    
    try:
        response = requests.get("http://localhost:8080/health", timeout=5)
        
        if response.status_code == 200:
            print("Server is UP!")
            server_healthy = True    # This will cause loop to exit
        else:
            print(f"Attempt {attempts + 1}: Status {response.status_code}")
    
    except requests.RequestException as e:
        # Connection error, timeout, DNS failure, etc.
        print(f"Attempt {attempts + 1}: Connection failed - {e}")
    
    attempts += 1                    # Increment attempts counter
    
    if not server_healthy:
        print("Waiting 5 seconds...")
        time.sleep(5)                # Delay before next attempt

# ─── Infinite Loop with break ───────────────────────────────
while True:                          # Loop forever (until break)
    user_input = input("Enter 'quit' to exit: ")
    
    if user_input.lower() == "quit":
        print("Goodbye!")
        break                        # Exit the loop immediately
    
    print(f"You entered: {user_input}")
```

### Loop Control

```python
# ═══════════════════════════════════════════════════════════════
# LOOP CONTROL - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── break - Exit Loop Early ─────────────────────────────────
for i in range(1, 11):               # Would go from 1 to 10
    if i == 5:
        break                        # STOP when i reaches 5
    print(i)                         # Prints: 1, 2, 3, 4

# ─── continue - Skip to Next Iteration ──────────────────────
for i in range(1, 11):               # Goes from 1 to 10
    if i % 2 == 0:                   # If i is EVEN (divisible by 2)
        continue                     # Skip this iteration, go to next i
    print(f"Odd: {i}")               # Prints only odd numbers: 1, 3, 5, 7, 9

# ─── else on Loops - Runs if NO break ───────────────────────
# This is UNIQUE to Python! The else block runs if the loop
# completes normally (no break), but NOT if break was hit.

for i in range(5):                   # Normal loop: 0, 1, 2, 3, 4
    print(i)
else:
    print("Loop completed without break")  # This DOES run (no break)

for i in range(5):
    if i == 3:
        break                        # Break exits on 3
    print(i)
else:
    print("This will NOT run")       # break happened, so else is SKIPPED

# ─── Practical Use of Loop-else ─────────────────────────────
# Search for an item: if found, break. If not found, else runs.

servers = ["web01", "web02", "db01"]
target = "db01"

for server in servers:
    if server == target:
        print(f"Found {target}!")
        break
else:
    print(f"{target} not found")      # Runs only if break never happened
```

### Practice Exercise

```python
#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# SERVICE CHECKER - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import socket                         # socket module for TCP connections
from datetime import datetime         # datetime for timestamps

# List of dictionaries - each has server info
SERVERS = [
    {"name": "web01", "ip": "172.16.1.10", "ports": [80, 443]},
    {"name": "web02", "ip": "172.16.1.11", "ports": [80, 443]},
    {"name": "db01", "ip": "172.16.1.12", "ports": [5432]},
]

def check_port(ip, port, timeout=3):
    """Check if a TCP port is open on given IP
    
    socket.socket(): Create a TCP socket
    AF_INET: IPv4 address family
    SOCK_STREAM: TCP protocol (not UDP)
    connect_ex(): Returns 0 if connection succeeds, error code if fails
    """
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        #    ↑ Create a TCP socket object
        
        sock.settimeout(timeout)      # Don't wait longer than 3 seconds
        
        result = sock.connect_ex((ip, port))
        #       ↑ Try to connect. Returns 0 = success
        
        sock.close()                  # Always close the socket!
        return result == 0            # True if open, False if closed
    
    except:
        return False                  # Any error = port is closed

def main():
    """Main function"""
    log_entries = []                   # Empty list to store log lines
    
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"Starting service check at {now}")
    print("=" * 40)
    
    # Outer loop: servers
    for server in SERVERS:
        print(f"\n--- Checking {server['name']} ({server['ip']}) ---")
        
        # Inner loop: ports for this server
        for port in server['ports']:
            is_open = check_port(server['ip'], port)
            
            status = "OPEN" if is_open else "CLOSED"
            symbol = "✓" if is_open else "✗"
            
            print(f"  {symbol} Port {port}: {status}")
            
            log_entries.append(f"{now},{server['name']},{port},{status}")
    
    # Write the log file
    with open("service_check.log", "w") as f:
        f.write("timestamp,server,port,status\n")       # CSV header
        f.writelines("\n".join(log_entries))            # Write all entries
    
    print(f"\nResults saved to service_check.log")

if __name__ == "__main__":
    main()
```

---

## 💪 Hands-On Exercises

### Exercise 1: Number Guessing Game
**Bash:**
```bash
SECRET=$((RANDOM % 100 + 1))    # Random number 1-100
while true; do
    read -p "Guess: " guess
    if [ "$guess" -eq "$SECRET" ]; then echo "Correct!"; break
    elif [ "$guess" -lt "$SECRET" ]; then echo "Higher"
    else echo "Lower"; fi
done
```

**Python:**
```python
import random
secret = random.randint(1, 100)
while True:
    guess = int(input("Guess: "))
    if guess == secret: print("Correct!"); break
    elif guess < secret: print("Higher")
    else: print("Lower")
```

### Exercise 2 & 3 - Follow the same patterns

---

## 🎯 Interview Q&A

1. **Bash**: Difference between `for i in {1..10}` and `for ((i=1; i<=10; i++))`?
   - First is BRACE EXPANSION (simpler, works for ranges). Second is C-STYLE (more flexible, supports complex conditions).

2. **Bash**: How would you loop through the output of a command?
   - `for item in $(command); do ... done`

3. **Python**: When to use for vs while?
   - FOR: when you know how many iterations (or have a collection to iterate)
   - WHILE: when you don't know how many iterations (retry loops, wait conditions)

4. **Python**: What is list comprehension?
   - `[x**2 for x in range(10)]` - a concise way to create lists by transforming each element