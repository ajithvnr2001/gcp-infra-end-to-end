# Day 29 - Final DevOps Project (CLI Tool)

## 🐍 Python: Full DevOps CLI Tool

```python
#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# FINAL DEVOPS PROJECT - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

import click
import yaml, json, subprocess, shutil, logging
from pathlib import Path
from datetime import datetime, timedelta
from concurrent.futures import ThreadPoolExecutor

# ─── Logging Config ───────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
log = logging.getLogger("devops")

# ═══════════════════════════════════════════════════════════
# COMMON UTILITIES
# ═══════════════════════════════════════════════════════════

def load_config(path):
    """Load YAML or JSON config"""
    p = Path(path)
    if not p.exists():
        raise click.ClickException(f"Config not found: {path}")
    
    content = p.read_text()                  # Read entire file
    if p.suffix in (".yaml", ".yml"):
        return yaml.safe_load(content)        # Parse YAML
    elif p.suffix == ".json":
        return json.loads(content)            # Parse JSON
    else:
        raise click.ClickException("Unsupported config format")

def run_command(cmd, timeout=30):
    """Run shell command safely - returns (returncode, stdout, stderr)"""
    try:
        result = subprocess.run(
            cmd, shell=True,                  # shell=True = use system shell
            capture_output=True, text=True,   # Capture stdout/stderr as text
            timeout=timeout,
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", f"Command timed out ({timeout}s)"
    except Exception as e:
        return -1, "", str(e)

# ═══════════════════════════════════════════════════════════
# HEALTH CHECK COMMAND
# ═══════════════════════════════════════════════════════════

@click.group()
@click.option("--config", "-c", default="config.yaml", help="Config file path")
@click.pass_context
def cli(ctx, config):
    """DevOps Utility Tool - Automate servers, backups, deployments"""
    ctx.ensure_object(dict)
    try:
        ctx.obj["config"] = load_config(config)
    except Exception as e:
        log.warning(f"No config loaded: {e}")
        ctx.obj["config"] = {}

# ─── Subcommand: health ──────────────────────────────────
@cli.command()
@click.option("--json-output", is_flag=True, help="Output as JSON")
@click.pass_context
def health(ctx, json_output):
    """Check system health: CPU, Memory, Disk"""
    import psutil
    
    metrics = {
        "cpu": psutil.cpu_percent(interval=1),
        "memory": psutil.virtual_memory().percent,
        "disk": shutil.disk_usage("/").used / shutil.disk_usage("/").total * 100,
    }
    
    score = 100
    alerts = []
    for name, value in metrics.items():
        if value > 80:
            score -= 20
            alerts.append(f"{name}: {value:.1f}%")
    
    metrics["score"] = max(0, score)
    metrics["alerts"] = alerts
    metrics["timestamp"] = datetime.now().isoformat()
    
    if json_output:
        click.echo(json.dumps(metrics, indent=2))
    else:
        click.echo(f"CPU: {metrics['cpu']:.1f}%")
        click.echo(f"Memory: {metrics['memory']:.1f}%")
        click.echo(f"Disk: {metrics['disk']:.1f}%")
        click.echo(f"Score: {score}/100")
        if alerts:
            click.secho("Alerts:", fg="red")
            for a in alerts:
                click.echo(f"  ⚠️  {a}")

# ─── Subcommand: backup ──────────────────────────────────
@cli.command()
@click.argument("source", type=click.Path(exists=True))
@click.option("--dest", "-d", default="/backup", help="Backup destination")
@click.option("--name", "-n", help="Backup name (default: auto)")
@click.pass_context
def backup(ctx, source, dest, name):
    """Backup a directory with compression"""
    source_path = Path(source)
    dest_path = Path(dest)
    dest_path.mkdir(parents=True, exist_ok=True)
    
    backup_name = name or f"{source_path.name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    archive = dest_path / f"{backup_name}.tar.gz"
    
    log.info(f"Backing up {source_path} → {archive}")
    
    with click.progressbar(length=100, label="Backing up") as bar:
        # tar = tape archive; 'w:gz' = write with gzip compression
        import tarfile
        with tarfile.open(archive, "w:gz") as tar:
            tar.add(str(source_path), arcname=source_path.name)
        bar.update(100)
    
    # Verify
    with tarfile.open(archive, "r:gz") as tar:
        files = tar.getmembers()
    
    click.echo(f"✓ Backup created: {archive}")
    click.echo(f"  Files: {len(files)}, Size: {archive.stat().st_size / 1024:.1f} KB")

# ─── Subcommand: deploy ──────────────────────────────────
@cli.command()
@click.argument("service")
@click.option("--env", "-e", default="staging", help="Target environment")
@click.option("--version", "-v", help="Version to deploy")
@click.option("--dry-run", is_flag=True, help="Simulate only")
@click.pass_context
def deploy(ctx, service, env, version, dry_run):
    """Deploy a service to target environment"""
    config = ctx.obj["config"]
    
    # 3-step deployment
    steps = [
        ("Building", f"docker build -t {service}:{version or 'latest'} ."),
        ("Testing", f"docker run --rm {service}:{version or 'latest'} pytest"),
        ("Deploying", f"docker push {service}:{version or 'latest'}"),
    ]
    
    for step_name, step_cmd in steps:
        click.echo(f"[{step_name}] {step_cmd}")
        if not dry_run:
            rc, stdout, stderr = run_command(step_cmd)
            if rc != 0:
                click.secho(f"✗ {step_name} FAILED: {stderr[:200]}", fg="red")
                raise click.Abort()
            click.echo(f"✓ {step_name} OK")
    
    click.echo(f"✓ {service} deployed to {env}")

# ─── Subcommand: batch ───────────────────────────────────
@cli.command()
@click.argument("commands_file", type=click.Path(exists=True))
@click.option("--threads", default=5, help="Parallel threads")
def batch(commands_file, threads):
    """Run commands from a file in parallel"""
    commands = Path(commands_file).read_text().strip().splitlines()
    commands = [c for c in commands if c and not c.startswith("#")]
    
    click.echo(f"Running {len(commands)} commands in {threads} threads")
    
    results = []
    with ThreadPoolExecutor(max_workers=threads) as ex:
        future_map = {
            ex.submit(run_command, cmd, 60): cmd
            for cmd in commands
        }
        
        from concurrent.futures import as_completed
        for future in as_completed(future_map):
            cmd = future_map[future]
            rc, stdout, stderr = future.result()
            status = "✓" if rc == 0 else "✗"
            results.append({"cmd": cmd, "status": status, "rc": rc})
            click.echo(f"  {status} [{rc}] {cmd[:60]}...")
    
    # Summary
    success = sum(1 for r in results if r["rc"] == 0)
    click.echo(f"\nResults: {success}/{len(results)} succeeded")

if __name__ == "__main__":
    cli()
```