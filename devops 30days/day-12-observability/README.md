# Day 12 - Observability

## Target

Debug using logs, metrics, traces, and alerts.

## Learn Deeply

- Logs explain events.
- Metrics show trends.
- Traces show request path.
- Golden signals: latency, traffic, errors, saturation.
- Alert quality.
- Dashboards by user impact.

## Hands-On Lab

Design a dashboard for an API service:

- Request rate.
- Error rate.
- P95/P99 latency.
- CPU/memory.
- Pod restarts.
- DB latency/connections.

## Interview Angle

Say:

```text
I start with user-impact metrics, then drill into service metrics, dependencies, and infrastructure.
```

## AWS/GCP Mapping

GCP Cloud Logging/Monitoring maps to AWS CloudWatch Logs/Metrics/Alarms. CloudTrail maps to Cloud Audit Logs for audit.

## Daily Motivation

Telemetry is the truth. Guessing is not debugging.

## Practice

Use `interview-question-bank.md` Day 12 questions 1-10.

