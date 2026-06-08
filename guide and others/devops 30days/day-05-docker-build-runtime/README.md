# Day 05 - Docker Build And Runtime

## Target

Debug Docker by separating build, runtime, network, and storage.

## Learn Deeply

- Dockerfile layers.
- Build context and `.dockerignore`.
- `CMD` vs `ENTRYPOINT`.
- Env vars and port mapping.
- Logs and inspect.
- Image size reduction.
- Non-root containers.

## Hands-On Lab

Build a small Python app image:

1. Add a Dockerfile.
2. Build image.
3. Run with env var.
4. Map port.
5. Break the command and debug using logs.

## Interview Angle

Say:

```text
For Docker issues I first identify whether it is image build, container runtime, networking, or storage.
```

## AWS/GCP Mapping

Artifact Registry and ECR both store Docker images. Cloud Build and CodeBuild both build images.

## Daily Motivation

Containers are not magic. They are packaging plus runtime isolation.

## Practice

Use `interview-question-bank.md` Day 5 questions 1-10.

