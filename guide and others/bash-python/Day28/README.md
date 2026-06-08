# Day 28 - Python Packaging for DevOps

## 🐍 Python: setuptools & pip

```python
# ═══════════════════════════════════════════════════════════════
# PACKAGING - LINE BY LINE
# ═══════════════════════════════════════════════════════════════

# ─── Why Package Python Code? ─────────────────────────────
# Instead of:
#   python3 /home/user/scripts/deploy.py --env prod
# You want:
#   my_tool deploy --env prod

# On any machine with pip install:
#   pip install my-devops-tool
#   my_tool --help

# ─── Project Structure ────────────────────────────────────
# my_devops_tool/
# ├── pyproject.toml          # Modern packaging config
# ├── src/
# │   └── my_devops_tool/
# │       ├── __init__.py     # Makes it a package
# │       ├── cli.py          # CLI entry point
# │       ├── utils.py
# │       └── commands/
# │           ├── __init__.py
# │           ├── deploy.py
# │           └── backup.py
# ├── tests/
# │   ├── test_cli.py
# │   └── test_backup.py
# └── README.md

# ─── pyproject.toml (Modern Standard) ─────────────────────
# [build-system]
# requires = ["setuptools>=61.0"]
# build-backend = "setuptools.build_meta"
#
# [project]
# name = "my-devops-tool"
# version = "0.1.0"
# description = "CLI tools for DevOps automation"
# requires-python = ">=3.8"
# dependencies = [
#     "click>=8.0",        # CLI framework (like argparse but cleaner)
#     "pyyaml>=6.0",       # YAML parsing
#     "requests>=2.28",    # HTTP requests
# ]
#
# [project.scripts]
# # Create CLI command: `my_tool` → main() in cli.py
# my_tool = "my_devops_tool.cli:main"
#
# [project.optional-dependencies]
# dev = [
#     "pytest>=7.0",
#     "black>=22.0",        # Code formatter
#     "mypy>=1.0",          # Type checker
# ]

# ─── CLI with Click ──────────────────────────────────────
# File: src/my_devops_tool/cli.py
import click

@click.group()                               # Top-level CLI group
@click.option("--verbose", "-v", is_flag=True)  # Global flag
@click.pass_context                           # Pass context to subcommands
def cli(ctx, verbose):
    """My DevOps Tool - automation utilities"""
    ctx.ensure_object(dict)                   # ctx.obj = shared dict
    ctx.obj["verbose"] = verbose

@cli.command()                                # Subcommand: backup
@click.option("--dir", "-d", default="/backup")  # Option with default
@click.argument("source")                     # Positional argument
@click.pass_context
def backup(ctx, dir, source):
    """Backup a directory"""
    if ctx.obj["verbose"]:
        click.echo(f"Backing up {source} to {dir}")
    # Actual backup logic here
    click.echo("Backup complete!")

@cli.command()                                # Subcommand: deploy
@click.option("--env", default="staging")
@click.argument("service")
def deploy(env, service):
    """Deploy a service to environment"""
    click.echo(f"Deploying {service} to {env}")

# ─── Install in Development Mode ─────────────────────────
# pip install -e .
# -e = editable: changes to source code immediately reflected

# ─── Build Distributable Package ─────────────────────────
# pip install build
# python -m build
# Creates: dist/my_devops_tool-0.1.0-py3-none-any.whl
#          dist/my_devops_tool-0.1.0.tar.gz

# ─── Publish to Private PyPI ─────────────────────────────
# pip install twine
# twine upload --repository-url https://pypi.internal/ dist/*

# ─── Real DevOps: Install on Servers ─────────────────────
# # In Ansible:
# - name: Install devops tool
#   pip:
#     name: my-devops-tool
#     version: 0.1.0
#     state: present

# # Or from private repo:
# - name: Install from private PyPI
#   pip:
#     name: my-devops-tool
#     extra_args: "--index-url https://pypi.internal/simple/"
```