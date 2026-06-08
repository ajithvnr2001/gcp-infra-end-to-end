# Day 6 - Dictionaries / Associative Arrays

## 🎯 Motivation
Dictionaries (Python) / Associative Arrays (Bash) store key-value pairs. In DevOps:
- Map server names to their IP addresses
- Track service names to their status
- Store configuration as key-value pairs

---

## 🐚 Bash: Associative Arrays (Bash 4+)

### Creating

```bash
# ═══════════════════════════════════════════════════════════════
# ASSOCIATIVE ARRAYS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# MUST declare with -A (uppercase). -a (lowercase) = indexed array.
declare -A server_ips                      # Declare associative array

# Assign values: map[key]=value
server_ips["web01"]="10.0.0.1"            # Key "web01" → Value "10.0.0.1"
server_ips["web02"]="10.0.0.2"
server_ips["db01"]="10.0.0.3"

# Declare and initialize in one line
declare -A PORTS=(
    [nginx]=80                             # key=nginx, value=80
    [postgresql]=5432
    [redis]=6379
)

# Access value
echo "${server_ips[web01]}"               # 10.0.0.1

# All KEYS (! = keys operator for assoc arrays)
echo "${!server_ips[@]}"                  # web01 web02 db01

# All VALUES
echo "${server_ips[@]}"                   # 10.0.0.1 10.0.0.2 10.0.0.3

# Number of entries
echo "${#server_ips[@]}"                  # 3
```

---

## 🐍 Python: Dictionaries

### Creating

```python
# ═══════════════════════════════════════════════════════════════
# DICTIONARIES - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# Literal syntax: {key: value, key: value}
server_ips = {
    "web01": "10.0.0.1",
    "web02": "10.0.0.2",
    "db01": "10.0.0.3",
}

# dict() constructor (keys become strings automatically)
ports = dict(nginx=80, postgresql=5432, redis=6379)
# Result: {"nginx": 80, "postgresql": 5432, "redis": 6379}

# From pairs (list of tuples)
pairs = [("web01", "10.0.0.1"), ("web02", "10.0.0.2")]
server_ips = dict(pairs)

# Dict comprehension: {key_expr: value_expr for item in iterable}
squares = {x: x**2 for x in range(5)}
# Result: {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}

# From zip (parallel lists)
servers = ["web01", "web02", "db01"]
ips = ["10.0.0.1", "10.0.0.2", "10.0.0.3"]
server_ips = dict(zip(servers, ips))
# zip() pairs up: ("web01", "10.0.0.1"), ("web02", "10.0.0.2"), ...
# dict() turns those pairs into a dictionary
```

### Accessing

```python
# ═══════════════════════════════════════════════════════════════
# ACCESSING DICTS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# Direct access (CRASHES if key doesn't exist!)
print(server_ips["web01"])                # 10.0.0.1
# print(server_ips["unknown"])            # KeyError! Crash!

# .get() - SAFE access (returns None or default)
print(server_ips.get("web01"))            # 10.0.0.1
print(server_ips.get("unknown"))          # None (no crash!)
print(server_ips.get("unknown", "N/A"))   # N/A (custom default)

# Check existence
if "web01" in server_ips:                 # "in" checks KEYS
    print("Exists")

# Get all keys/values/items
print(server_ips.keys())                  # dict_keys(['web01', 'web02', ...])
print(server_ips.values())                # dict_values(['10.0.0.1', ...])
print(server_ips.items())                 # dict_items([('web01', '10.0.0.1'), ...])

# Iterate over key-value pairs
for server, ip in server_ips.items():
    print(f"{server} -> {ip}")
```

### Nested Dictionaries (Important for DevOps)

```python
# ═══════════════════════════════════════════════════════════════
# NESTED DICTS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# Real-world DevOps data: nested dicts within dicts
servers = {
    "web01": {                              # Each server is a dict
        "ip": "10.0.1.10",
        "region": "us-east-1",
        "services": {                       # Services is a nested dict
            "nginx": {"port": 80, "status": "running"},
            "app": {"port": 8080, "status": "running"},
        },
        "specs": {"cpu": 4, "ram_gb": 16, "disk_gb": 100}
    },
    "db01": {
        "ip": "10.0.2.10",
        "region": "us-west-2",
        "services": {
            "postgresql": {"port": 5432, "status": "running"},
        },
        "specs": {"cpu": 8, "ram_gb": 32, "disk_gb": 500}
    },
}

# Access nested data: chain the keys
print(servers["web01"]["ip"])                          # 10.0.1.10
print(servers["web01"]["services"]["nginx"]["port"])   # 80

# Safe nested access with .get() defaults
nginx_port = servers.get("web01", {}).get("services", {}).get("nginx", {}).get("port", "unknown")
# Chain: if any level fails, return "unknown" (thanks to {} defaults)
```

### Practice Exercise

```python
#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# SERVER INVENTORY - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

INVENTORY = {
    "web01": {"ip": "10.0.1.10", "role": "web", "status": "running", "region": "us-east-1"},
    "web02": {"ip": "10.0.1.11", "role": "web", "status": "running", "region": "us-east-1"},
    "db01": {"ip": "10.0.2.10", "role": "database", "status": "stopped", "region": "us-west-2"},
    "db02": {"ip": "10.0.2.11", "role": "database", "status": "stopped", "region": "us-west-2"},
}


def get_servers_by_status(inventory, status):
    """Return list of server names with given status"""
    return [
        name for name, info in inventory.items()   # name = "web01", info = {"ip": ..., ...}
        if info["status"] == status                # filter: only matching status
    ]


def group_by(inventory, key):
    """Group servers by any key (role, region, status)"""
    result = {}
    for name, info in inventory.items():
        group = info.get(key, "unknown")            # Get the grouping value
        
        if group not in result:                     # First time seeing this group?
            result[group] = []                      # Create empty list for this group
        
        result[group].append(name)                  # Add server to group
    
    return result


def main():
    print("=== Server Inventory ===")
    
    for name, info in sorted(INVENTORY.items()):
        print(f"{name:<10} | {info['ip']:<15} | {info['role']:<10} | {info['status']:<10}")
        #  ↑           ↑                    ↑                     ↑
        #  left-align 10  left-align 15     left-align 10         left-align 10
    
    print("\n=== Grouped by Role ===")
    for role, servers in group_by(INVENTORY, "role").items():
        print(f"{role}: {', '.join(servers)}")
    
    stopped = get_servers_by_status(INVENTORY, "stopped")
    if stopped:
        print(f"\nStopped servers: {', '.join(stopped)}")

if __name__ == "__main__":
    main()
```

---

## 🎯 Interview Q&A

1. **Python**: Difference between `dict.get()` and direct access with `[]`?
   - `[]` raises KeyError if missing. `.get()` returns None or a default.
   
2. **Python**: How to merge two dictionaries?
   - `dict1 | dict2` (Python 3.9+) or `dict1.update(dict2)` or `{**dict1, **dict2}`

3. **Bash**: How to check if a key exists in an associative array?
   - `[[ -v array[key] ]]` (Bash 4.2+) or `[ "${array[key]+exists}" ]`