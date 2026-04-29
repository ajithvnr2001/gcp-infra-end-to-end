# Day 06 - Docker Compose And Local Development

## Target

Run and debug multi-service applications locally.

## Learn Deeply

- Compose services.
- Internal DNS using service names.
- Volumes and persistence.
- Env files.
- Health checks.
- `depends_on` limitations.

## Hands-On Lab

Create or inspect a Compose stack with app + database:

1. Start services.
2. Break DB password.
3. Read logs.
4. Fix env var.
5. Explain why `localhost` is wrong from one container to another.

## Interview Angle

Say:

```text
In Compose, containers communicate through service names on the Compose network, not through localhost.
```

## AWS/GCP Mapping

Compose is local only. Production equivalent is usually Kubernetes, ECS, or Cloud Run style services.

## Daily Motivation

If you can reproduce locally, you can debug faster.

## Practice

Use `interview-question-bank.md` Day 6 questions 1-10.

