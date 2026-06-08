# Day 22 - JSON in DevOps

## 🐚 Bash: jq

```bash
# ═══════════════════════════════════════════════════════════════
# jq - COMMAND-LINE JSON PROCESSOR - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Basic Parsing ─────────────────────────────────────────
echo '{"name": "web01", "ip": "10.0.0.1"}' | jq '.name'
# jq '.name' = extract the "name" field from the JSON object
# Output: "web01" (with quotes - JSON string)

echo '{"name": "web01", "ip": "10.0.0.1"}' | jq -r '.name'
# -r = RAW output (no quotes). Output: web01

# ─── Nested Fields ─────────────────────────────────────────
echo '{"server": {"name": "web01", "ip": "10.0.0.1"}}' | jq -r '.server.name'
# .server.name = drill into "server" object, then "name" field
# Output: web01

# ─── Array Operations ─────────────────────────────────────
echo '["web01", "web02", "db01"]' | jq -r '.[]'
# .[] = iterate over ALL array elements
# Output: web01  web02  db01 (one per line)

echo '["web01", "web02", "db01"]' | jq -r '.[0]'
# .[0] = first element (0-indexed). Output: web01

echo '["web01", "web02", "db01"]' | jq 'length'
# length = number of elements. Output: 3

# ─── Array of Objects (DEVOPS COMMON) ─────────────────────
# Filter: find servers with CPU > 80
SERVERS='[{"name":"web01","cpu":45},{"name":"web02","cpu":92}]'

echo "$SERVERS" | jq -r '.[] | select(.cpu > 80) | .name'
# .[] = iterate through array
# select(.cpu > 80) = filter: only keep if cpu field > 80
# | .name = extract name from the filtered result
# Output: web02

# Multiple conditions
echo "$SERVERS" | jq -r '.[] | select(.cpu > 50 and .status == "running") | .name'

# ─── Transform ────────────────────────────────────────────
echo '{"name":"web01","ip":"10.0.0.1","tags":{"env":"prod"}}' | \
    jq '{hostname: .name, address: .ip, environment: .tags.env}'
# Create NEW object with renamed fields
# Output: {"hostname":"web01","address":"10.0.0.1","environment":"prod"}
```

## 🐍 Python: json Module

```python
# ═══════════════════════════════════════════════════════════════
# JSON MODULE - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import json

# ─── Load from String ─────────────────────────────────────
json_string = '{"name": "web01", "ip": "10.0.0.1", "enabled": true, "tags": {"env": "prod"}}'

data = json.loads(json_string)        # loads = LOAD from STRING
# Result: Python dict: {"name": "web01", "ip": "10.0.0.1", "enabled": True, ...}
# Note: JSON "true" → Python True, JSON "null" → Python None

print(data["name"])                    # web01
print(data["tags"]["env"])             # prod

# ─── Load from File ──────────────────────────────────────
with open("servers.json", "r") as f:
    servers = json.load(f)              # load = LOAD from FILE (no 's')

# ─── Dump to String ──────────────────────────────────────
output = json.dumps(data, indent=2)    # dumps = DUMP to STRING
                                        # indent=2 = pretty-print with 2 spaces
# Output:
# {
#   "name": "web01",
#   "ip": "10.0.0.1",
#   ...
# }

# ─── Dump to File ────────────────────────────────────────
with open("output.json", "w") as f:
    json.dump(data, f, indent=2)        # dump = DUMP to FILE (no 's')

# ─── JSON ↔ Python Type Mapping ──────────────────────────
# JSON string     → Python str
# JSON number     → Python int or float
# JSON object     → Python dict
# JSON array      → Python list
# JSON true/false → Python True/False
# JSON null       → Python None

# ─── Filter Array of Objects ─────────────────────────────
servers = [
    {"name": "web01", "cpu": 45, "status": "running"},
    {"name": "web02", "cpu": 92, "status": "running"},
    {"name": "db01", "cpu": 30, "status": "stopped"},
]

# Find servers with high CPU
high_cpu = [s for s in servers if s["cpu"] > 80]
# List comprehension: keep each server 's' where s["cpu"] > 80
print([s["name"] for s in high_cpu])    # ['web02']

# Group by status
running = [s for s in servers if s["status"] == "running"]
stopped = [s for s in servers if s["status"] == "stopped"]
```