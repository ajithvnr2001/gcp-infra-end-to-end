# Day 17 - Port Checker / Application Health

## 🐚 Bash: Port Checker

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# PORT CHECKER - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

HOST="localhost"
PORTS=(80 443 5432 6379)                 # Ports to check
TIMEOUT=3                                # Seconds before giving up

for port in "${PORTS[@]}"; do
    # /dev/tcp: Bash's built-in TCP connection feature
    # echo > /dev/tcp/$HOST/$port: try opening TCP connection
    # timeout $TIMEOUT: kill after N seconds
    # 2>/dev/null: discard error messages
    
    timeout $TIMEOUT bash -c "echo >/dev/tcp/$HOST/$port" 2>/dev/null
    
    if [ $? -eq 0 ]; then                # $? = exit code of last command
        echo "✓ $HOST:$port OPEN"         # Exit code 0 = connection succeeded
    else
        echo "✗ $HOST:$port CLOSED"       # Non-zero = connection failed
    fi
done
```

## 🐍 Python: Port Checker

```python
#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# PORT CHECKER - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import socket
import time

def check_tcp(host, port, timeout=5):
    """Check if TCP port is open"""
    # socket.socket() creates a network endpoint
    # AF_INET = IPv4, SOCK_STREAM = TCP
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    sock.settimeout(timeout)              # Don't wait more than N seconds
    
    start = time.time()
    result = sock.connect_ex((host, port)) # connect_ex returns 0 on success
    elapsed = time.time() - start
    
    sock.close()                           # Always close sockets!
    
    return result == 0, elapsed            # Return (is_open, response_time)

def check_http(url, timeout=5):
    """Check HTTP endpoint"""
    import requests
    start = time.time()
    
    try:
        resp = requests.get(url, timeout=timeout)
        elapsed = time.time() - start
        return resp.status_code == 200, resp.status_code, f"{elapsed:.2f}s"
    except requests.ConnectionError:
        return False, 0, "connection_refused"
    except requests.Timeout:
        return False, 0, "timeout"

# ─── Check Multiple Ports ─────────────────────────────────
HOST = "localhost"
PORTS = [80, 443, 5432, 6379]

for port in PORTS:
    is_open, elapsed = check_tcp(HOST, port)
    icon = "✓" if is_open else "✗"
    print(f"{icon} {HOST}:{port} - {'OPEN' if is_open else 'CLOSED'} ({elapsed:.2f}s)")
```