# Day 26 - Threading & Concurrency

## 🐍 Python: threading Module

```python
# ═══════════════════════════════════════════════════════════════
# THREADING - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

# ─── Why Threading? ───────────────────────────────────────
# DevOps tasks: ping 100 servers, check 50 URLs, process 1000 logs
# Sequential = 100 × 2s = 200s  (3.3 minutes)
# Parallel   = 2s total + overhead

# ─── threading.Thread (Basic) ─────────────────────────────
def ping_server(ip, results, idx):
    """Simulate pinging a server"""
    time.sleep(0.5)                          # Simulate network latency
    results[idx] = f"{ip}: OK"               # Write result at index

ips = ["10.0.0.1", "10.0.0.2", "10.0.0.3"]
results = [None] * len(ips)                  # Pre-allocate list to store results
threads = []

for i, ip in enumerate(ips):
    t = threading.Thread(target=ping_server,  # Function to run
                         args=(ip, results, i))  # Arguments tuple
    t.start()                                 # Start the thread
    threads.append(t)                         # Track for joining

for t in threads:
    t.join()                                  # Wait for ALL threads to finish
    # Without join(): main thread finishes before worker threads

print(results)
# Output: ["10.0.0.1: OK", "10.0.0.2: OK", "10.0.0.3: OK"]

# ─── ThreadPoolExecutor (BETTER - Modern API) ────────────
def check_website(url):
    """Check if a website is reachable"""
    import requests
    try:
        resp = requests.get(url, timeout=5)
        return f"{url}: HTTP {resp.status_code}"
    except Exception as e:
        return f"{url}: ERROR - {str(e)}"

urls = [
    "https://google.com",
    "https://github.com",
    "https://httpbin.org/delay/2",  # Takes 2 seconds
]

with ThreadPoolExecutor(max_workers=5) as executor:
    # submit() = schedule function to run on a thread
    # Returns a Future object (represents pending result)
    futures = [executor.submit(check_website, url) for url in urls]
    
    # as_completed() = yield futures AS they complete (not in order)
    for future in as_completed(futures):
        result = future.result()             # Get the return value
        print(f"Done: {result}")

# ─── map() - Simplified ──────────────────────────────────
with ThreadPoolExecutor(max_workers=5) as executor:
    results = executor.map(check_website, urls)
    # map() = submit all, wait for ALL, return in ORDER
    for result in results:
        print(result)

# ─── Real-World: Parallel Service Check ──────────────────
def check_services_concurrent(services, timeout=10):
    """Check multiple services simultaneously"""
    def _check_one(name, host, port):
        import socket
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            result = sock.connect_ex((host, port))  # 0 = open, else = error
            sock.close()
            return name, "UP" if result == 0 else "DOWN"
        except Exception as e:
            return name, f"ERROR: {e}"
    
    with ThreadPoolExecutor(max_workers=20) as ex:
        futures = {
            ex.submit(_check_one, name, svc["host"], svc["port"]): name
            for name, svc in services.items()
        }
        
        status = {}
        for future in as_completed(futures):
            name, result = future.result()
            status[name] = result
        return status

# ─── Thread Safety ───────────────────────────────────────
# Problem: multiple threads writing to same variable causes DATA CORRUPTION
counter = 0

def increment_bad():
    global counter
    for _ in range(100000):
        counter += 1  # NOT thread-safe! Read-modify-write = race condition

# Solution: Lock
lock = threading.Lock()
counter = 0

def increment_good():
    global counter, lock
    for _ in range(100000):
        with lock:                       # Acquire lock (blocks others)
            counter += 1                 # Safe: only one thread at a time
        # Lock released automatically when 'with' block exits
```