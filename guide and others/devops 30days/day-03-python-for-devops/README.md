# Day 03 - Python For DevOps Automation

## Target

Use Python when Bash becomes hard to maintain.

## Learn Deeply

- Files: `pathlib`.
- JSON: `json.load`, `json.loads`.
- Commands: `subprocess.run`.
- APIs: `requests` with timeouts.
- CLI arguments: `argparse`.
- Logging: `logging`.
- Error handling: `try/except`, explicit exit codes.

## Hands-On Lab

Build `service-audit.py`:

Input JSON:

```json
[
  {"name": "catalog", "status": "healthy"},
  {"name": "payment", "status": "unhealthy"}
]
```

Output unhealthy services and exit `1` if any service is unhealthy.

## Interview Angle

Say:

```text
Bash is good for glue. Python is better when I need structured data, APIs, retries, tests, and maintainable logic.
```

## AWS/GCP Mapping

Python can call both AWS SDK `boto3` and GCP SDK/client libraries. The automation pattern is the same: authenticate, call API, handle errors, log result.

## Daily Motivation

Python is your force multiplier. It lets you build tools instead of repeating commands.

## Practice

Use `interview-question-bank.md` Day 3 questions 1-10.

