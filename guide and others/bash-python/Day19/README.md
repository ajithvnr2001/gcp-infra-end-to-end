# Day 19 - Backup Script

## 🐚 Bash: Backup

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# BACKUP SCRIPT - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

BACKUP_DIR="/backup"
RETENTION=7                              # Keep 7 days of backups
DATE=$(date +%Y%m%d_%H%M%S)              # Timestamp: 20240115_103045
BACKUP_NAME="backup_$DATE"               # Unique backup name

mkdir -p "$BACKUP_DIR/$BACKUP_NAME"      # Create backup folder

# ─── Backup Configs ───────────────────────────────────────
tar czf "$BACKUP_DIR/$BACKUP_NAME/configs.tar.gz" \
    /etc/nginx /etc/postgresql /etc/redis 2>/dev/null
# tar: tape archive
# c = create, z = gzip compress, f = filename
# 2>/dev/null: suppress errors if dirs don't exist

# ─── Database Backup ──────────────────────────────────────
if pg_isready -q 2>/dev/null; then       # Check if PostgreSQL is running
    PGPASSWORD="$DB_PASS" pg_dumpall -U postgres \
        > "$BACKUP_DIR/$BACKUP_NAME/postgres_full.sql"
    # pg_dumpall: dump ALL databases
    gzip "$BACKUP_DIR/$BACKUP_NAME/postgres_full.sql"
fi

# ─── Checksums ───────────────────────────────────────────
cd "$BACKUP_DIR/$BACKUP_NAME"
sha256sum * > checksums.sha256           # Create checksums for verification
# sha256sum: compute SHA-256 hash of each file
# Later you can run: sha256sum -c checksums.sha256

# ─── Final Archive ────────────────────────────────────────
cd "$BACKUP_DIR"
tar czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"  # Archive everything together
rm -rf "$BACKUP_NAME"                            # Remove temp folder

# ─── Verify ──────────────────────────────────────────────
tar tzf "${BACKUP_NAME}.tar.gz" > /dev/null 2>&1  # t = list, test integrity
if [ $? -eq 0 ]; then
    echo "✓ Backup verified: ${BACKUP_NAME}.tar.gz"
fi

# ─── Clean Old ───────────────────────────────────────────
find "$BACKUP_DIR" -name "backup_*.tar.gz" -type f -mtime +$RETENTION -delete
# Remove backups older than retention period
```

## 🐍 Python: Backup

```python
#!/usr/bin/env python3

import tarfile, gzip, shutil, hashlib, subprocess
from pathlib import Path
from datetime import datetime, timedelta

class Backup:
    def __init__(self, backup_dir="/backup", retention_days=7):
        self.backup_dir = Path(backup_dir)
        self.retention_days = retention_days
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.name = f"backup_{self.timestamp}"
        self.work_dir = self.backup_dir / self.name
    
    def backup_configs(self, dirs=None):
        """Archive config directories"""
        if dirs is None:
            dirs = ["/etc/nginx", "/etc/postgresql", "/etc/redis"]
        
        self.work_dir.mkdir(parents=True, exist_ok=True)
        path = self.work_dir / "configs.tar.gz"
        
        with tarfile.open(path, "w:gz") as tar:   # "w:gz" = write + gzip
            for d in dirs:
                p = Path(d)
                if p.exists():
                    # arcname = name INSIDE the archive (not full path)
                    tar.add(str(p), arcname=p.name)
        
        return path
    
    def create_checksums(self):
        """Create SHA256 checksums"""
        sums = self.work_dir / "checksums.sha256"
        with open(sums, "w") as f:
            for filepath in self.work_dir.iterdir():
                if filepath.is_file() and filepath != sums:
                    h = hashlib.sha256()
                    h.update(filepath.read_bytes())    # Hash file content
                    f.write(f"{h.hexdigest()}  {filepath.name}\n")
    
    def finalize(self):
        """Create final archive and clean up"""
        archive = self.backup_dir / f"{self.name}.tar.gz"
        
        with tarfile.open(archive, "w:gz") as tar:
            tar.add(str(self.work_dir), arcname=self.name)
        
        shutil.rmtree(self.work_dir)          # Remove working directory
        
        # Clean old backups
        cutoff = datetime.now() - timedelta(days=self.retention_days)
        for old in self.backup_dir.glob("backup_*.tar.gz"):
            ctime = datetime.fromtimestamp(old.stat().st_ctime)
            if ctime < cutoff:
                old.unlink()                   # Delete old backup
        
        return archive
```