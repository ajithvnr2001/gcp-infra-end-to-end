# Day 5 - Lists / Arrays

## 🎯 Motivation
Arrays and lists store groups of related data. In DevOps:
- Lists of servers to monitor
- Multiple IP addresses or ports
- Collections of log files
- Batches of commands to execute

---

## 🐚 Bash: Arrays

### Creating Arrays

```bash
# ═══════════════════════════════════════════════════════════════
# ARRAYS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Indexed Arrays (Bash 3+) ──────────────────────────────
servers=("web01" "web02" "db01" "cache01")  # Create with elements
ports=(80 443 22 5432)                       # Array of numbers

# ─── Empty Array ───────────────────────────────────────────
errors=()                                    # Empty array (ready to fill)

# ─── Declare Explicitly ────────────────────────────────────
declare -a names                             # Declare 'names' as array (explicit)

# ─── From Command Output ───────────────────────────────────
# $(ls *.log) = list of .log files, split into array by spaces
# WARNING: Fails if filenames have spaces!
files=($(ls *.log))

# mapfile: Read file into array (one line per element, SAFER)
mapfile -t lines < file.txt                 # -t = trim trailing newlines

# ─── Adding Elements ───────────────────────────────────────
errors+=("disk full")                        # Append to array
errors+=("service down")                     # Add another element
```

### Accessing Elements

```bash
# ═══════════════════════════════════════════════════════════════
# ACCESSING ARRAYS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Single Element (0-indexed) ─────────────────────────────
echo "${servers[0]}"                      # web01 (first element)
echo "${servers[1]}"                      # web02 (second element)

# ─── All Elements ──────────────────────────────────────────
echo "${servers[@]}"                      # web01 web02 db01 cache01
                                          # @ = ALL elements as separate words

# ─── Number of Elements ────────────────────────────────────
echo "${#servers[@]}"                     # 4 (length of array)
                                          # ${#array[@]} = count

# ─── Length of an Element ──────────────────────────────────
echo "${#servers[0]}"                     # 5 (length of "web01")
                                          # ${#array[index]} = char count of element

# ─── Slice ─────────────────────────────────────────────────
# ${array[@]:START:LENGTH}
echo "${servers[@]:1:2}"                  # web02 db01
                                          # Start at index 1, take 2 elements
```

### Array Operations

```bash
# ═══════════════════════════════════════════════════════════════
# ARRAY OPERATIONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Append ────────────────────────────────────────────────
servers+=("monitor01")                    # Add to end

# ─── Delete Element ────────────────────────────────────────
unset servers[1]                          # Remove element at index 1
                                          # NOTE: Doesn't re-index! It becomes sparse

# ─── Replace ───────────────────────────────────────────────
servers[0]="web-prod-01"                  # Overwrite first element

# ─── Loop Safely ───────────────────────────────────────────
# "${servers[@]}" with QUOTES = each element stays intact
for server in "${servers[@]}"; do         # Safe even with spaces in names
    echo "Server: $server"
done
```

### Associative Arrays (Bash 4+)

```bash
# ═══════════════════════════════════════════════════════════════
# ASSOCIATIVE ARRAYS (DICTIONARIES) - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# MUST declare with -A (uppercase A)
declare -A server_ips                      # Declare associative array
server_ips["web01"]="10.0.0.1"            # key="web01", value="10.0.0.1"
server_ips["db01"]="10.0.0.2"

# Access
echo "${server_ips[web01]}"               # 10.0.0.1

# All KEYS
echo "${!server_ips[@]}"                  # web01 db01 (! gives keys)
                                          # The ! prefix for associative arrays = list KEYS

# Iterate over keys
for server in "${!server_ips[@]}"; do     # Loop through each KEY
    echo "$server -> ${server_ips[$server]}"  # key -> value
done
```

### Practice Exercise

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# MULTI-SERVICE CHECKER - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

SERVERS=("web01" "web02" "db01" "cache01")     # Indexed array of server names

declare -A PORTS                                 # Associative array
PORTS["web01"]="80,443"                          # Map server -> its ports
PORTS["web02"]="80,443"
PORTS["db01"]="5432"
PORTS["cache01"]="6379"

echo "=== Multi-Server Health Check ==="

for server in "${SERVERS[@]}"; do               # Loop through each server
    
    # Split port string into array
    IFS=',' read -ra port_list <<< "${PORTS[$server]}"
    #    ↑                    ↑
    #    split by comma       string to split: the value from PORTS dict
    #    read: read into variable
    #    -ra: treat as array
    #    port_list = (80 443) or (5432) etc.
    
    all_open=true                                # Assume all ports are open
    
    for port in "${port_list[@]}"; do            # Check each port
        # Try TCP connection via /dev/tcp
        if ! timeout 2 bash -c "echo >/dev/tcp/localhost/$port" 2>/dev/null; then
            all_open=false                       # Mark as not all open
        fi
    done
    
    status=$([ "$all_open" = true ] && echo "UP" || echo "DEGRADED")
    # Construct status: if all_open is true → "UP", else → "DEGRADED"
    
    echo "$server: $status"
done
```

---

## 🐍 Python: Lists

### Creating Lists

```python
# ═══════════════════════════════════════════════════════════════
# LISTS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Literals ───────────────────────────────────────────────
servers = ["web01", "web02", "db01", "cache01"]  # List of strings
ports = [80, 443, 22, 5432]                      # List of integers
mixed = [True, 42, "hello", 3.14]                # Mixed types (valid!)

# ─── Empty List ────────────────────────────────────────────
errors = []                                      # Empty list
errors = list()                                  # Same thing, using list() constructor

# ─── From Iterable ─────────────────────────────────────────
numbers = list(range(10))                        # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
chars = list("hello")                            # ['h', 'e', 'l', 'l', 'o']

# ─── List Comprehension ────────────────────────────────────
squares = [x**2 for x in range(10)]
#          ↑     ↑     ↑
#          what  loop  optional filter
# Result: [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
```

### Accessing Elements

```python
# ═══════════════════════════════════════════════════════════════
# ACCESSING LISTS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

servers = ["web01", "web02", "db01", "cache01"]

print(servers[0])                             # web01 (first element, 0-indexed)
print(servers[-1])                            # cache01 (NEGATIVE = count from end)
print(servers[1:3])                           # ['web02', 'db01'] (slice: index 1 to 2)
                                              # [START:END] - END is EXCLUSIVE
print(servers[:2])                            # ['web01', 'web02'] (from start to index 1)
print(servers[::2])                           # ['web01', 'db01'] (every 2nd element)

# Check existence
if "web01" in servers:                        # "in" checks membership
    print("Found web01")                      # True if element exists
```

### List Operations

```python
# ═══════════════════════════════════════════════════════════════
# LIST OPERATIONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Adding Elements ───────────────────────────────────────
servers.append("monitor01")                  # Add to END of list
servers.extend(["backup01", "backup02"])     # Add MULTIPLE elements (like +=)
servers.insert(0, "lb01")                    # INSERT at position 0 (shifts others right)

# ─── Removing Elements ─────────────────────────────────────
servers.remove("web01")                      # Remove FIRST occurrence of value
                                             # ERROR if value not found!

removed = servers.pop(1)                     # Remove at INDEX and RETURN it
del servers[0]                               # Delete at index (no return)

# ─── Finding Elements ──────────────────────────────────────
idx = servers.index("db01")                  # Find INDEX of "db01"
                                             # ERROR if not found!
count = servers.count("web01")               # Count occurrences

# ─── Sorting ───────────────────────────────────────────────
servers.sort()                               # Sort IN PLACE (modifies original)
sorted_servers = sorted(servers)             # Return NEW sorted list (original unchanged)

# ─── Reversing ─────────────────────────────────────────────
servers.reverse()                            # Reverse IN PLACE
```

### Practice Exercise

```python
#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# MULTI-SERVICE CHECKER - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import socket
from typing import Dict, List, Tuple

# List of server names
SERVERS = ["web01", "web02", "db01", "cache01"]

# Dictionary mapping server name -> list of ports
PORTS: Dict[str, List[int]] = {
    "web01": [80, 443],
    "web02": [80, 443],
    "db01": [5432],
    "cache01": [6379],
}

def check_port(host: str, port: int, timeout: int = 2) -> bool:
    """Check if a TCP port is open"""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            # with statement = auto-close socket when done
            sock.settimeout(timeout)
            # connect_ex returns 0 on success
            return sock.connect_ex((host, port)) == 0
    except:
        return False

def check_server(server: str, ports: List[int]) -> Tuple[str, str, List[str]]:
    """Check all ports for a server"""
    open_ports = []
    closed_ports = []
    
    for port in ports:
        if check_port(server, port):
            open_ports.append(str(port))
        else:
            closed_ports.append(str(port))
    
    if closed_ports:                           # Any closed = degraded
        return server, "DEGRADED", closed_ports
    elif open_ports:                           # All open = up
        return server, "UP", []
    else:
        return server, "DOWN", ports           # No open ports = down

def main():
    print("=== Multi-Server Health Check ===")
    
    # Iterate through each server in the SERVERS list
    for server in SERVERS:
        name, status, failed_ports = check_server(server, PORTS[server])
        #    ↑     ↑        ↑
        #    name  status   list of failed
        
        details = f"Ports down: {','.join(failed_ports)}" if failed_ports else "All OK"
        print(f"{name:<10} | {status:<10} | {details:<20}")
        #         ↑                ↑                ↑
        #         left-align 10     left-align 10    left-align 20
    
    # Count statuses using list comprehension
    statuses = [check_server(s, PORTS[s])[1] for s in SERVERS]
    #          ↑                                        ↑
    #          collect the status (index 1)              for each server
    
    up_count = statuses.count("UP")
    print(f"Summary: {up_count}/{len(SERVERS)} servers fully operational")

if __name__ == "__main__":
    main()
```

---

## 🎯 Interview Q&A

1. **Bash**: Difference between `${arr[@]}` and `${arr[*]}`?
   - `${arr[@]}` = each element as separate WORD (for loops). `${arr[*]}` = all elements as ONE string.

2. **Python**: What is list comprehension?
   - `[expr for item in iterable if condition]` - concise way to create lists.

3. **Python**: Difference between `append()` and `extend()`?
   - `append([1,2])` adds the list AS ONE ELEMENT. `extend([1,2])` adds each element separately.