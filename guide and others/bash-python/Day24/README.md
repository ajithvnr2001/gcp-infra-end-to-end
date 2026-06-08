# Day 24 - YAML in DevOps

## 🐍 Python: PyYAML

```python
# ═══════════════════════════════════════════════════════════════
# YAML - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import yaml  # Requires: pip install pyyaml

# ─── What is YAML? ────────────────────────────────────────
# YAML = "YAML Ain't Markup Language"
# Used for: Docker Compose, Kubernetes, Ansible, CI/CD configs
# Key: uses INDENTATION (spaces) for structure, NOT braces or brackets

# ─── YAML Structure ───────────────────────────────────────
# server:
#   name: web01          # key: value pairs
#   role: app            # String values
#   cpu: 4               # Integer
#   enabled: true        # Boolean
#   tags:                # Nested mapping
#     env: prod
#     tier: frontend
#   ports:               # List (array)
#     - 80
#     - 443
#   features: [monitor, logging]  # Inline list (JSON-style)

yaml_data = """
server:
  name: web01
  role: frontend
  cpu: 4
  enabled: true
  tags:
    env: prod
  ports:
    - 80
    - 443
"""

parsed = yaml.safe_load(yaml_data)   # safe_load = parse YAML string → Python dict
# Use safe_load() NOT load() - load() can execute arbitrary code!
# Output type: dict

server_name = parsed["server"]["name"]       # "web01"
cpu = parsed["server"]["cpu"]                 # 4 (int)
ports = parsed["server"]["ports"]            # [80, 443]

print(server_name, cpu, ports)

# ─── Convert Python → YAML ───────────────────────────────
config = {
    "server": {
        "name": "web01",
        "cpu": 4,
        "enabled": True,
    }
}

yaml_output = yaml.dump(config, default_flow_style=False)
# dump = convert Python dict → YAML string
# default_flow_style=False → block style (not inline JSON)
print(yaml_output)
# server:
#   cpu: 4
#   enabled: true
#   name: web01

# ─── Read YAML File ──────────────────────────────────────
with open("config.yaml", "r") as f:
    config = yaml.safe_load(f)               # safe_load (no 's') = from FILE

# ─── Write YAML File ─────────────────────────────────────
with open("backup_config.yaml", "w") as f:
    yaml.dump(config, f)                     # Same syntax as dump to string

# ─── Real-World: Ansible Config Parser ────────────────────
def parse_ansible_inventory(filepath):
    """Parse Ansible inventory file"""
    with open(filepath, "r") as f:
        data = yaml.safe_load(f)
    
    hosts = []
    for group_name, group_data in data.get("all", {}).get("children", {}).items():
        # "all" → "children" → each group (e.g., "webservers")
        if "hosts" in group_data:
            for host_name, host_vars in group_data["hosts"].items():
                host_info = {"name": host_name, "group": group_name}
                host_info.update(host_vars or {})
                hosts.append(host_info)
    
    return hosts
```