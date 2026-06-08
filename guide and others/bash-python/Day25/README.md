# Day 25 - Error Handling & Exception Handling

## 🐚 Bash: Exit Codes & Error Handling

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# ERROR HANDLING - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Exit Codes ───────────────────────────────────────────
# Every command returns an exit code:
#   0 = SUCCESS
#   non-zero = FAILURE (1-255)

ls /tmp > /dev/null 2>&1
echo $?                                    # 0 (success)

ls /nonexistent 2>/dev/null
echo $?                                    # 2 (failure: file not found)

# ─── $? - Previous Command Exit Status ────────────────────
ping -c 1 google.com > /dev/null 2>&1
if [ $? -eq 0 ]; then                      # Check exit code of ping
    echo "Network OK"
else
    echo "Network FAILED"
fi

# ─── && and || - SHORTCUT Operators ──────────────────────
mkdir -p /tmp/test && echo "Created"       # Runs echo ONLY if mkdir succeeds
# && = AND: second command runs only if first succeeds (exit code 0)

ping -c 1 google.com || echo "Offline"     # Runs echo ONLY if ping fails
# || = OR: second command runs only if first FAILS (exit code ≠ 0)

# ─── set -e : Exit on Error ──────────────────────────────
set -e                                      # Exit script immediately on ANY error
# Without set -e: script continues even if commands fail
# With set -e: script stops at first failure

cp /etc/secret /backup/ 2>/dev/null         # If this fails, script exits here
echo "Will never run if cp failed"          # Only reached if cp succeeded

# ─── set -x : Debug Mode ─────────────────────────────────
set -x                                      # Print each command before executing
# Output: + cp /etc/secret /backup/
# The '+' prefix shows this is a command being traced

# ─── trap : Cleanup on Exit ─────────────────────────────
cleanup() {
    rm -rf /tmp/script_temp                 # Remove temp files
    echo "Cleanup done"
}
trap cleanup EXIT                           # trap = catch signal
# When script exits (even on error), run cleanup()
# Signals: EXIT, ERR, SIGINT (Ctrl+C), SIGTERM

# ─── Custom Error Function ────────────────────────────────
die() {
    echo "ERROR: $1" >&2                    # >&2 = redirect to stderr
    exit 1                                   # Exit with status 1
}

# Usage:
[ -f "/etc/important.conf" ] || die "Config file missing"
```

## 🐍 Python: Exception Handling

```python
# ═══════════════════════════════════════════════════════════════
# EXCEPTION HANDLING - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── try/except/finally ──────────────────────────────────
try:
    file = open("/tmp/data.txt", "r")        # May raise FileNotFoundError
    content = file.read()                    # May raise IOError
    data = json.loads(content)               # May raise json.JSONDecodeError
    print(data["name"])                      # May raise KeyError

except FileNotFoundError:
    print("File not found")                  # Handle specific error
except json.JSONDecodeError as e:
    print(f"Invalid JSON: {e}")              # e = error object with details
except Exception as e:                       # Catch-all (use sparingly!)
    print(f"Unexpected: {e}")
finally:
    if "file" in locals() and not file.closed:
        file.close()                          # ALWAYS runs (even if return/break)

# ─── with Statement (Context Manager) ────────────────────
# Cleaner: no need for explicit close()
try:
    with open("/tmp/data.txt", "r") as f:    # Auto-closes when block exits
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError) as e:
    print(f"Failed: {e}")

# ─── raise your Own Exception ────────────────────────────
class ConfigError(Exception):
    """Custom exception for config problems"""
    pass

def validate_config(config, required_keys):
    """Verify required keys exist"""
    for key in required_keys:
        if key not in config:
            raise ConfigError(f"Key '{key}' missing from config")
    return True

try:
    validate_config({"name": "web01"}, ["name", "port"])
except ConfigError as e:
    print(f"Validation failed: {e}")

# ─── retry Decorator ─────────────────────────────────────
import time, functools

def retry(max_attempts=3, delay=1, backoff=2):
    """Retry a function with exponential backoff"""
    def decorator(func):
        @functools.wraps(func)               # Preserve function metadata
        def wrapper(*args, **kwargs):
            last_exception = None
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)  # Try the function
                except Exception as e:
                    last_exception = e
                    if attempt < max_attempts:
                        wait = delay * (backoff ** (attempt - 1))  # 1, 2, 4 sec
                        print(f"Attempt {attempt} failed. Retrying in {wait}s...")
                        time.sleep(wait)
                    else:
                        print(f"All {max_attempts} attempts failed")
            raise last_exception               # Raise last error after all retries
        return wrapper
    return decorator

# Usage:
@retry(max_attempts=3, delay=1)
def fetch_data(url):
    response = requests.get(url, timeout=5)
    response.raise_for_status()              # Raises for HTTP 4xx/5xx
    return response.json()

# ─── Best Practices ─────────────────────────────────────
# 1. Be specific: catch specific exceptions, not bare 'except:'
# 2. Don't swallow: at minimum log the error
# 3. Use finally: for cleanup (close files, release resources)
# 4. Fail fast: raise early when preconditions are not met
# 5. Retry transient: network errors, not logic errors
```