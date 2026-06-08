# Day 27 - Logging in Python

## 🐍 Python: logging Module

```python
# ═══════════════════════════════════════════════════════════════
# LOGGING MODULE - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import logging
import sys
from pathlib import Path

# ─── Basic Config (Quick Start) ──────────────────────────
logging.basicConfig(
    level=logging.INFO,                    # Only show INFO and above
    format="%(asctime)s [%(levelname)s] %(message)s",
    # %(asctime)s = timestamp (e.g., 2024-01-15 10:30:45)
    # %(levelname)s = DEBUG/INFO/WARNING/ERROR/CRITICAL
    # %(message)s = the actual log message
    handlers=[
        logging.FileHandler("app.log"),     # Write to file
        logging.StreamHandler(sys.stdout)   # Also print to console
    ]
)

# Usage:
logging.debug("Detail for debugging")      # Shows only if level=DEBUG
logging.info("Server started on port 8080")
logging.warning("Disk at 85%% capacity")
logging.error("Connection refused to db01")
logging.critical("Service is DOWN")

# ─── Custom Logger (Best Practice) ───────────────────────
logger = logging.getLogger(__name__)        # Get named logger
logger.setLevel(logging.DEBUG)              # Accept all levels (filters below)

# ─── Different Handlers for Different Outputs ────────────
# Console handler: only WARNING+
console_handler = logging.StreamHandler(sys.stdout)
console_handler.setLevel(logging.WARNING)
console_format = logging.Formatter("[%(levelname)s] %(message)s")
console_handler.setFormatter(console_format)

# File handler: everything
file_handler = logging.FileHandler("detailed.log")
file_handler.setLevel(logging.DEBUG)
file_format = logging.Formatter(
    "%(asctime)s | %(name)s | %(levelname)s | %(filename)s:%(lineno)d | %(message)s"
)
# %(filename)s = file where log was called from
# %(lineno)d = line number in that file
file_handler.setFormatter(file_format)

logger.addHandler(console_handler)
logger.addHandler(file_handler)

logger.debug("Only in file")               # Not in console
logger.warning("Both file and console")    # Everywhere

# ─── Structured Logging (JSON format) ────────────────────
class JSONFormatter(logging.Formatter):
    """Format logs as JSON for log aggregators (ELK, Datadog, etc.)"""
    def format(self, record):
        log_entry = {
            "timestamp": self.formatTime(record, self.datefmt),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }
        # Include extra fields passed via extra={}
        if hasattr(record, "extra_data"):
            log_entry["extra"] = record.extra_data
        return json.dumps(log_entry)

json_handler = logging.StreamHandler()
json_handler.setFormatter(JSONFormatter())
logger.addHandler(json_handler)

# ─── Contextual Logging (extra fields) ────────────────────
class ContextLogger:
    """Add context (request_id, user, etc.) to every log"""
    def __init__(self, logger, **defaults):
        self._logger = logger
        self._defaults = defaults
    
    def info(self, msg, **extra):
        self._logger.info(msg, extra={"extra_data": {**self._defaults, **extra}})
    
    def error(self, msg, **extra):
        self._logger.error(msg, extra={"extra_data": {**self._defaults, **extra}})

# ─── Log Rotation (Prevent Disk Full) ─────────────────────
from logging.handlers import RotatingFileHandler

rotating_handler = RotatingFileHandler(
    "server.log",
    maxBytes=10 * 1024 * 1024,              # 10 MB per file
    backupCount=5,                          # Keep 5 backups (server.log.1, .2...)
)
logger.addHandler(rotating_handler)

# ─── Real DevOps: Centralized Logging Setup ──────────────
def setup_devops_logger(name, log_dir="/var/log/app", level=logging.INFO):
    """Production-grade logger setup"""
    log_path = Path(log_dir)
    log_path.mkdir(parents=True, exist_ok=True)
    
    logger = logging.getLogger(name)
    logger.setLevel(level)
    
    # Rotation handler
    file_handler = RotatingFileHandler(
        str(log_path / "app.log"),
        maxBytes=50 * 1024 * 1024,   # 50 MB
        backupCount=3,
    )
    file_handler.setFormatter(logging.Formatter(
        "%(asctime)s [%(levelname)s] %(name)s: %(message)s"
    ))
    logger.addHandler(file_handler)
    
    # Error-only handler
    error_handler = RotatingFileHandler(
        str(log_path / "error.log"),
        maxBytes=50 * 1024 * 1024,
        backupCount=3,
    )
    error_handler.setLevel(logging.ERROR)
    logger.addHandler(error_handler)
    
    return logger
```