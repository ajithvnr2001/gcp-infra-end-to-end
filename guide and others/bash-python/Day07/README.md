# Day 7 - Revision Week 1

## 🎯 Motivation
Revision is where learning sticks. The goal: write everything from memory.

## 📋 Topics Covered
1. Variables + Output | 2. Conditions | 3. Loops | 4. Functions | 5. Arrays/Lists | 6. Dictionaries

---

## 🔥 Challenge: Write From Memory

### Must-Know (Try without peeking!)

```bash
# 1. Variables - capture hostname, display it
HOST=$(hostname)                    # $(command) = capture command output to variable
echo "Hostname: $HOST"               # $HOST = use variable value

# 2. If statement - check if file exists
if [ -f "/etc/passwd" ]; then        # -f = is regular file test
    echo "File exists"                # Runs if condition is TRUE (0)
fi                                   # Close if block

# 3. For loop - iterate 1 to 5
for i in 1 2 3 4 5; do               # i takes each value: 1, 2, 3, 4, 5
    echo "Number: $i"
done

# 4. Function with local variable
check_disk() {
    local threshold=$1                # local = function-scoped variable
    echo "Threshold: $threshold"
}
```

```python
# 1. Variables
import socket
hostname = socket.gethostname()    # Call function, store return value
print(f"Hostname: {hostname}")     # f-string = formatted string literal

# 2. If statement
import os
if os.path.isfile("/etc/passwd"):  # os.path.isfile() = True if file exists
    print("File exists")

# 3. For loop
for i in range(1, 6):              # range(1,6) = [1, 2, 3, 4, 5]
    print(f"Number: {i}")

# 4. Function with default parameter
def check_disk(threshold=80):      # threshold defaults to 80 if not provided
    return f"Threshold: {threshold}"
```

### Coding Marathon (30 min each)

**Challenge 1: System Snapshot Script**

```bash
#!/bin/bash
# Write this from memory:

# 1. Get hostname, IP, OS, kernel
HOST=$(hostname)
IP=$(hostname -I)
OS=$(uname -s)
KERNEL=$(uname -r)

# 2. Get CPU cores, load average
CORES=$(nproc)
LOAD=$(uptime | awk -F'load average:' '{print $2}')

# 3. Memory total/used/free
MEM_TOTAL=$(free -m | awk 'NR==2 {print $2}')
MEM_USED=$(free -m | awk 'NR==2 {print $3}')

# 4. Disk mount points and usage
DISK=$(df -h / | awk 'NR==2 {print $5}')

# 5. Display all
echo "$HOST | $IP | $OS $KERNEL"
echo "CPU: $CORES cores, Load: $LOAD"
echo "MEM: ${MEM_USED}MB / ${MEM_TOTAL}MB"
echo "DISK: $DISK"
```

```python
#!/usr/bin/env python3
# Write this from memory:

import socket, platform, os, psutil

# 1. System info
host = socket.gethostname()
ip = socket.gethostbyname(host)
os_name = platform.system()
kernel = platform.release()

# 2. CPU
cores = psutil.cpu_count()
load = psutil.getloadavg()

# 3. Memory
mem = psutil.virtual_memory()

# 4. Disk
disk = psutil.disk_usage("/")

# 5. Display
print(f"{host} | {ip} | {os_name} {kernel}")
print(f"CPU: {cores} cores, Load: {load}")
print(f"MEM: {mem.used/1e6:.0f}MB / {mem.total/1e6:.0f}MB")
print(f"DISK: {disk.used/1e9:.1f}G / {disk.total/1e9:.1f}G ({disk.percent}%)")
```