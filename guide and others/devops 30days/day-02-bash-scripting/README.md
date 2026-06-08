# Day 02 - Bash Scripting For Operations

## Target

Turn repeated manual checks into reliable scripts.

## Learn Deeply

- Safe mode: `set -euo pipefail`.
- Variables and quoting: always prefer `"$VAR"`.
- Arguments: `$1`, `$2`, usage messages.
- Exit codes: `0` success, non-zero failure.
- Loops, conditions, functions.
- Text processing: `grep`, `awk`, `sed`, `sort`, `uniq`.

## Hands-On Lab

Create a script named `health-check.sh` that checks:

- Disk usage above 80%.
- Memory availability.
- Whether a service/process is running.
- Whether an HTTP endpoint returns 200.

Expected behavior: print readable output and exit non-zero if a check fails.

## Interview Angle

Good answer:

```text
I use Bash for command orchestration and simple operational checks. I make scripts safe with strict mode, input validation, clear exit codes, and logs.
```

## AWS/GCP Mapping

Bash is useful for both `gcloud` and `aws` CLI automation. The cloud CLI changes; scripting discipline does not.

## Daily Motivation

Every script you write should remove one repeated manual action from your life.

## Practice

Use `interview-question-bank.md` Day 2 questions 1-10.

