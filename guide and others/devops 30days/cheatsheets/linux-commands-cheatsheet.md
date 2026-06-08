# Linux Commands Cheat Sheet

## System

```bash
uptime
top
ps aux
free -m
df -h
df -i
du -sh *
```

## Logs

```bash
journalctl -u <service> -f
tail -f /var/log/syslog
grep -i error app.log
```

## Network

```bash
ss -lntp
curl -v http://localhost:8080/health
nslookup example.com
```

## Permissions

```bash
ls -l
chmod 640 file
chown appuser:appuser file
```

## Interview Rule

Do not say "I will check logs" only. Say which logs and what signal you expect.

