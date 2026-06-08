# Day 23 - Nested JSON Processing

## 🐍 Python: Safe Nested Access

```python
# ═══════════════════════════════════════════════════════════════
# NESTED JSON - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── The Problem: KeyError ─────────────────────────────────
data = {"name": "web01"}
# This CRASHES:
# print(data["ip"])           # KeyError: 'ip'
# print(data["tags"]["env"])   # TypeError: 'NoneType' is not subscriptable

# ─── .get() Method (Safe Access) ──────────────────────────
data = {"name": "web01"}

print(data.get("ip"))                    # None (no crash!)
print(data.get("ip", "0.0.0.0"))         # "0.0.0.0" (custom default)

# Chained .get() for nested access
config = {"database": {"host": "db01", "port": 5432}}

host = config.get("database", {}).get("host", "localhost")
# .get("database", {}) → if "database" missing, return EMPTY dict {}
# .get("host", "localhost") → if "host" missing, return "localhost"

# ─── deep_get() - Reusable Safe Function ──────────────────
def deep_get(data, *keys, default=None):
    """Safely access deeply nested keys"""
    current = data
    for key in keys:
        try:
            if isinstance(current, dict):           # If current is a dict
                current = current.get(key)           # Access with .get()
                if current is None:                  # If missing key
                    return default
            elif isinstance(current, (list, tuple)): # If current is a list
                if isinstance(key, int) and 0 <= key < len(current):
                    current = current[key]            # Access by index
                else:
                    return default
            else:
                return default
        except (TypeError, IndexError):
            return default
    return current

# ─── Real-World Usage ────────────────────────────────────
aws_response = {
    "Reservations": [{
        "Instances": [{
            "InstanceId": "i-12345",
            "State": {"Name": "running"},
            "NetworkInterfaces": [{
                "Association": {"PublicIp": "54.123.45.67"}
            }]
        }]
    }]
}

# Before (brittle, crashes if any level missing):
# instance_id = aws_response["Reservations"][0]["Instances"][0]["InstanceId"]

# After (safe):
instance_id = deep_get(aws_response, "Reservations", 0, "Instances", 0, "InstanceId")
public_ip = deep_get(aws_response, "Reservations", 0, "Instances", 0, 
                      "NetworkInterfaces", 0, "Association", "PublicIp")
state = deep_get(aws_response, "Reservations", 0, "Instances", 0, "State", "Name")

print(f"Instance: {instance_id}")    # i-12345
print(f"IP: {public_ip}")            # 54.123.45.67
print(f"State: {state}")             # running

# ─── Flatten Nested JSON ─────────────────────────────────
def flatten_json(data, parent_key="", sep="."):
    """Convert nested JSON to flat dot-notation keys"""
    items = []
    
    if isinstance(data, dict):
        for k, v in data.items():
            new_key = f"{parent_key}{sep}{k}" if parent_key else str(k)
            # Recurse if value is dict or list
            if isinstance(v, (dict, list)):
                items.extend(flatten_json(v, new_key, sep=sep).items())
            else:
                items.append((new_key, v))
    
    elif isinstance(data, list):
        for i, item in enumerate(data):
            new_key = f"{parent_key}{sep}{i}" if parent_key else str(i)
            if isinstance(item, (dict, list)):
                items.extend(flatten_json(item, new_key, sep=sep).items())
            else:
                items.append((new_key, item))
    
    return dict(items)

# Usage: convert nested to flat
nested = {"server": {"name": "web01", "specs": {"cpu": 4, "ram_gb": 16}}}
flat = flatten_json(nested)
print(flat)
# {"server.name": "web01", "server.specs.cpu": 4, "server.specs.ram_gb": 16}
```