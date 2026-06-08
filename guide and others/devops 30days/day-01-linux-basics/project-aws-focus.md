# Day 01 Project + AWS Focus

## Project Connection

Your ecommerce services run inside Linux-based containers. Even when the platform is GKE, every container still depends on Linux fundamentals: processes, files, permissions, ports, and logs.

Interview line:

```text
Even in Kubernetes, Linux basics matter because pod failures often come from process crashes, permissions, disk pressure, or resource limits.
```

## GCP To AWS Mapping

GCP VM is Compute Engine. AWS VM is EC2. Linux checks are identical after login.

## Project Question

If a backend service in this project becomes slow, what do you check first?

Answer:

```text
I check whether the issue is service-specific or platform-wide. Then I inspect CPU, memory, pod restarts, logs, dependency latency, and recent deployments.
```

