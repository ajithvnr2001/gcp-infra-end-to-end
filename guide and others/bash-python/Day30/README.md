# Day 30 - Mock DevOps Interview

## 🐚 Bash Interview Questions (with Answers)

```bash
# ═══════════════════════════════════════════════════════════════
# BASH INTERVIEW Q&A - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# Q1: Explain $?, $@, $#, $0, $$
echo "Exit code of last command: $?"       # $? = exit code (0 = success)
echo "All arguments: $@"                     # $@ = all args as separate words
echo "Number of arguments: $#"               # $# = arg count
echo "Script name: $0"                       # $0 = path to current script
echo "PID of this script: $$"               # $$ = process ID

# Q2: Check if a command exists
if command -v nginx &>/dev/null; then        # command -v = locate command
    echo "nginx is installed"
fi

# Q3: Read a file line by line
while IFS= read -r line; do                  # IFS= preserve whitespace; -r=raw
    echo "Line: $line"
done < "servers.txt"                         # Input redirection

# Q4: Find and kill a process by name
PID=$(pgrep -f "python app.py")              # pgrep = process grep by name
[ -n "$PID" ] && kill "$PID"                 # -n = string is not empty

# Q5: Check if port is listening
ss -tlnp | grep -q ":80\b"                  # ss = socket stats; -q = quiet
echo $?                                      # 0 if port 80 is listening

# Q6: sed - replace in file
sed -i 's|old_url|new_url|g' config.yaml    # -i = in-place; s = substitute
# | delimiter avoids escaping /

# Q7: awk - extract column
df -h | awk 'NR>1 {print $5, $6}'           # NR>1 = skip header row

# Q8: Calculate total from a list
echo -e "10\n20\n30" | paste -sd+ | bc      # paste -sd+ = join with +; bc=calc

# Q9: Loop with array
servers=("web01" "web02" "db01")
for s in "${servers[@]}"; do                 # "${arr[@]}" = all elements
    echo "$s"
done

# Q10: Variable default value
NAME=${1:-"default"}                         # Use $1 or "default" if empty
```

## 🐍 Python Interview Questions

```python
# ═══════════════════════════════════════════════════════════════
# PYTHON INTERVIEW Q&A - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# Q1: What is the difference between list, tuple, and set?
lst = [1, 2, 2, 3]    # List: mutable, ordered, allows duplicates
tup = (1, 2, 2, 3)    # Tuple: IMMUTABLE, ordered, allows duplicates
st = {1, 2, 2, 3}     # Set: mutable, UNORDERED, NO duplicates → {1, 2, 3}

# Q2: List comprehension vs generator expression
squares_list = [x**2 for x in range(10)]     # Creates ALL 10 items in memory
squares_gen  = (x**2 for x in range(10))     # Creates 1 item at a time (lazy)
# Use generator for large data (memory efficient)

# Q3: Generator function (yield)
def read_large_file(filepath):
    """Read file line by line - memory efficient for GB files"""
    with open(filepath) as f:
        for line in f:
            yield line.strip()               # yield = return but continue

# Q4: Decorator to time functions
import functools, time
def timer(func):
    @functools.wraps(func)                   # Preserve docstring/name
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"{func.__name__} took {elapsed:.3f}s")
        return result
    return wrapper

# Q5: Context manager (with statement)
class ManagedConnection:
    def __enter__(self):
        print("Opening connection")
        return self
    def __exit__(self, exc_type, exc_val, tb):
        print("Closing connection")          # ALWAYS runs, even on exception

# Q6: Deep vs shallow copy
import copy
original = {"data": [1, 2, 3]}
shallow  = original.copy()                   # Nested list STILL shared
deep     = copy.deepcopy(original)            # Everything is independent

# Q7: Method resolution order (MRO)
class A: pass
class B(A): pass
class C(A): pass
class D(B, C): pass
print(D.__mro__)                             # D → B → C → A → object

# Q8: Contextlib for simple context managers
from contextlib import contextmanager

@contextmanager
def temp_dir():
    """Create and clean up temp directory"""
    import tempfile, shutil
    dirpath = tempfile.mkdtemp()             # Create temp dir
    try:
        yield dirpath                        # Return context value
    finally:
        shutil.rmtree(dirpath)               # Cleanup on exit

# Q9: Properties (getter/setter)
class Config:
    def __init__(self, value):
        self._value = value
    
    @property
    def value(self):
        return self._value                   # Getter: obj.value
    
    @value.setter
    def value(self, new_val):
        if not isinstance(new_val, str):
            raise TypeError("Must be string")
        self._value = new_val                # Setter: obj.value = "new"

# Q10: Abstract base class
from abc import ABC, abstractmethod

class Deployer(ABC):
    @abstractmethod
    def deploy(self, service, env):
        pass                                 # Must be implemented by subclass

class DockerDeployer(Deployer):
    def deploy(self, service, env):
        print(f"Deploying {service} to {env} via Docker")
```

## 🐚🐍 DevOps Scenario Questions

```python
# ═══════════════════════════════════════════════════════════════
# SCENARIO QUESTIONS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# Scenario 1: "A web server is slow. What do you check?"
# Answer:
# 1. CPU: top/htop
# 2. Memory: free -m
# 3. Disk I/O: iostat -x 1
# 4. Network: ss -tlnp, netstat
# 5. Application logs: journalctl -u nginx
# 6. Database: SHOW PROCESSLIST;

# Scenario 2: "Implement retry logic for API calls"
import time
import functools
import requests

def retry_with_backoff(max_retries=3, base_delay=1, backoff=2):
    """Retry HTTP calls with exponential backoff"""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            last_exc = None
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except (requests.ConnectionError, 
                        requests.Timeout, 
                        requests.HTTPError) as e:
                    last_exc = e
                    if attempt < max_retries - 1:
                        wait = base_delay * (backoff ** attempt)
                        time.sleep(wait)
            raise last_exc
        return wrapper
    return decorator

# Scenario 3: "Parse Nginx access log and find IPs with > 100 requests"
def find_high_traffic_ips(logfile, threshold=100):
    from collections import Counter
    ip_counts = Counter()
    
    with open(logfile) as f:
        for line in f:
            ip = line.split()[0]             # First field = IP
            ip_counts[ip] += 1
    
    return {ip: count for ip, count in ip_counts.items() if count > threshold}

# Scenario 4: "Monitor /var/log for ERRORs and send alert"
def monitor_log(path="/var/log/app.log", keywords=("ERROR", "CRITICAL")):
    import time
    with open(path) as f:
        f.seek(0, 2)                         # Seek to end of file
        while True:
            line = f.readline()
            if line:
                for kw in keywords:
                    if kw in line:
                        print(f"ALERT: {line.strip()}")
            else:
                time.sleep(0.5)              # No new line, wait

# Scenario 5: "Backup database and send to S3"
def backup_and_upload(db_name, s3_bucket):
    import subprocess
    from pathlib import Path
    
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    backup_file = Path(f"/tmp/{db_name}_{timestamp}.sql.gz")
    
    # Step 1: pg_dump + gzip
    subprocess.run(
        f"pg_dump {db_name} | gzip > {backup_file}",
        shell=True, check=True,
    )
    
    # Step 2: Upload to S3
    subprocess.run(
        f"aws s3 cp {backup_file} s3://{s3_bucket}/backups/",
        shell=True, check=True,
    )
    
    # Step 3: Clean local
    backup_file.unlink()

# ─── DevOps Mindset Questions ────────────────────────────
# Q: "A deployment fails. What's your process?"
# A: 1. Check deployment logs
#    2. Rollback to previous version
#    3. Identify root cause
#    4. Write test to catch it
#    5. Fix and redeploy

# Q: "How do you handle secrets?"
# A: NEVER in code. Use:
#    - HashiCorp Vault
#    - AWS Secrets Manager
#    - Encrypted env vars in CI/CD
#    - .env files (never committed)

# Q: "How do you debug a network issue?"
# A: ping → traceroute → ss/netstat → nslookup/dig → tcpdump

# Q: "What goes into a CI/CD pipeline?"
# A: Lint → Test → Build → Security Scan → Deploy Staging → 
#    Integration Tests → Deploy Production → Smoke Tests

# Q: "What monitoring metrics matter?"
# A: USE method (Utilization, Saturation, Errors)
#    RED method (Rate, Errors, Duration)
#    The Four Golden Signals: Latency, Traffic, Errors, Saturation
```