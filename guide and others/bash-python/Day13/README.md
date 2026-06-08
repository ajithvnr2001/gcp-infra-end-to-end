# Day 13 - Process Monitoring

## 🐚 Bash: Process Monitoring

```bash
# ═══════════════════════════════════════════════════════════════
# PROCESS COMMANDS - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

ps aux                                  # ps = process status
                                          # a = all users, u = user-format, x = includes daemons
                                          # Shows: USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND

ps aux --sort=-%cpu                     # --sort=-%cpu = sort by CPU descending
                                          # - (minus) = descending order

ps aux | grep nginx                     # Filter: show only nginx processes

pgrep nginx                             # pgrep = process grep. Returns just PIDs
                                          # Output: 1234 5678 (PID numbers only)

pgrep -c nginx                          # -c = COUNT matching processes
                                          # Returns count, not PIDs

top -bn1                                # top = interactive process viewer
                                          # -b = batch mode (non-interactive)
                                          # -n1 = 1 iteration (then exit)

top -bn1 -o %CPU | head -8              # -o %CPU = sort by CPU
                                          # head -8 = first 8 lines (includes header)

# ─── Kill Processes ───────────────────────────────────────
kill 1234                               # kill = send SIGTERM (graceful shutdown)
kill -9 1234                            # -9 = SIGKILL (force kill - last resort!)
kill -15 1234                           # -15 = SIGTERM explicitly
pkill -f "node app.js"                  # pkill = kill by process name pattern
killall nginx                           # killall = kill ALL processes with this name

# ─── Check if Process Exists ─────────────────────────────
pgrep -x nginx > /dev/null && echo "running" || echo "stopped"
# -x = exact match (not partial)
# > /dev/null = suppress output (we only care about exit code)
# && = if succeeds, || = if fails
```

## 🐍 Python: Process Monitoring

```python
# ═══════════════════════════════════════════════════════════════
# PROCESS MONITORING - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── subprocess (Run any command) ─────────────────────────
import subprocess

result = subprocess.run(["ps", "aux"],    # Run ps aux
    capture_output=True,                    # Capture stdout/stderr
    text=True                               # Return strings, not bytes
)
print(result.stdout)                        # Print the output



# ─── psutil (Most Pythonic - pip install psutil) ──────────
import psutil

# Iterate over all running processes
for proc in psutil.process_iter(["pid", "name", "cpu_percent", "memory_percent"]):
    # process_iter() yields a process for each running process
    # The ["pid", ...] = fields to fetch (saves time vs fetching all)
    try:
        print(f"PID: {proc.info['pid']} | {proc.info['name']} | "
              f"CPU: {proc.info['cpu_percent']}% | "
              f"MEM: {proc.info['memory_percent']}%")
    except (psutil.NoSuchProcess, psutil.AccessDenied):
        pass                                # Process died between listing and access

# ─── System-wide Info ─────────────────────────────────────
print(f"CPU cores: {psutil.cpu_count()}")               # Number of logical CPUs
print(f"CPU usage: {psutil.cpu_percent(interval=1)}")   # Wait 1 sec, measure CPU %
print(f"Memory: {psutil.virtual_memory().percent}%")    # RAM usage %
print(f"Disk: {psutil.disk_usage('/').percent}%")       # Disk usage %

# ─── Find High CPU Processes ──────────────────────────────
def find_high_cpu(threshold=50.0):
    high = []
    for proc in psutil.process_iter(["pid", "name", "cpu_percent"]):
        try:
            cpu = proc.info["cpu_percent"]
            if cpu and cpu > threshold:
                high.append((proc.info["pid"], proc.info["name"], cpu))
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    return sorted(high, key=lambda x: x[2], reverse=True)  # Sort by CPU descending
```