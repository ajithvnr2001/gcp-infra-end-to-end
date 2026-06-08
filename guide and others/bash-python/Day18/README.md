# Day 18 - Log Cleanup Script

## 🐚 Bash: Log Cleanup

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# LOG CLEANUP - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

RETENTION_DAYS=30                           # Keep logs for 30 days
ARCHIVE_DIR="/var/log/archive"
mkdir -p "$ARCHIVE_DIR"                     # Create archive dir (no error if exists)

# ─── Compress Old Logs ────────────────────────────────────
find /var/log -name "*.log" -type f -mtime +2 | while read -r file; do
    # find: locate .log files older than 2 days
    # -name "*.log": match .log extension
    # -type f: regular files only
    # -mtime +2: modified more than 2 days ago
    
    if [ ! -f "${file}.gz" ]; then          # Check if NOT already compressed
        gzip "$file"                         # gzip = GNU zip (compresses in-place)
        mv "${file}.gz" "$ARCHIVE_DIR/"     # Move compressed to archive
        echo "Compressed: $(basename "$file")"
    fi
done

# ─── Delete Old Archives ────────────────────────────────
find "$ARCHIVE_DIR" -name "*.gz" -type f -mtime +$RETENTION_DAYS -delete
# -mtime +$RETENTION_DAYS: older than 30 days
# -delete: remove file (safer than -exec rm {} \;)
```

## 🐍 Python: Log Cleanup

```python
#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# LOG CLEANUP - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import gzip
import shutil
import time
from pathlib import Path

class LogCleaner:
    def __init__(self, log_dirs, retention_days=30, compress_after_days=2):
        self.log_dirs = [Path(d) for d in log_dirs]   # Convert strings to Path objects
        self.retention_days = retention_days
        self.compress_after_days = compress_after_days
        self.total_saved = 0                           # Track space saved
    
    def compress_log(self, filepath, archive_dir):
        """Compress single log file"""
        # gzip.open: write compressed file
        # shutil.copyfileobj: copy from original to compressed
        with open(filepath, "rb") as f_in:              # Read original as bytes
            gz_path = archive_dir / f"{filepath.name}.gz"  # New name: file.log.gz
            with gzip.open(str(gz_path), "wb") as f_out:   # Write compressed
                shutil.copyfileobj(f_in, f_out)            # Copy data
        
        original_size = filepath.stat().st_size           # Size before
        compressed_size = gz_path.stat().st_size           # Size after
        saved = original_size - compressed_size
        self.total_saved += saved
        
        filepath.unlink()                                  # Delete original
        return saved
    
    def run(self):
        """Run cleanup on all directories"""
        cutoff = time.time() - (self.retention_days * 86400)  # 30 days in seconds
        
        for log_dir in self.log_dirs:
            if not log_dir.exists():
                continue
            
            archive_dir = Path(f"{log_dir}_archive")
            archive_dir.mkdir(exist_ok=True)
            
            # Find and compress files older than compress_after_days
            for log_file in log_dir.rglob("*.log"):       # rglob = recursive glob
                if log_file.stat().st_mtime < cutoff:
                    self.compress_log(log_file, archive_dir)
            
            # Delete compressed archives older than retention
            for gz_file in archive_dir.rglob("*.gz"):
                if gz_file.stat().st_mtime < cutoff:
                    gz_file.unlink()                       # Delete old archive
        
        return self.total_saved
```