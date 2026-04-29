# Day 01 - Linux Basics For DevOps Interviews

## Target

Build the inspection mindset. Most DevOps debugging starts on Linux: process, CPU, memory, disk, logs, permissions, and services.

## Learn Deeply

- Filesystem: `/var/log`, `/etc`, `/opt`, `/tmp`, `/home`, `/usr`.
- Process model: PID, parent process, foreground/background, zombie process.
- Resource checks: `top`, `free -m`, `df -h`, `du -sh`, `uptime`.
- Service checks: `systemctl status`, `journalctl -u`.
- Permission basics: owner, group, others, read/write/execute.

## Hands-On Lab

1. Find top 5 largest files in this repo.
2. Check current system disk and memory.
3. Pick any process and explain PID, CPU, memory.
4. Write a mini incident note: "Server disk reached 95%."

## Interview Angle

When asked "server is slow", do not jump to restart. Say:

```text
I will first isolate whether the issue is CPU, memory, disk, network, process, or dependency related. Then I will validate using metrics and logs.
```

## AWS/GCP Mapping

Linux debugging is same on GCE and EC2. Cloud changes how you access the VM and view logs, but OS-level checks are the same.

## Daily Motivation

You do not need to memorize every command. You need to know how to inspect a system calmly.

## Practice

Use `interview-question-bank.md` Day 1 questions 1-10.

