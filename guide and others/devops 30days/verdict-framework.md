# VERDICT Interview Framework

Use VERDICT for every DevOps/cloud scenario. The interviewer is not only checking if you know a command. They are checking if you can debug production safely.

## VERDICT-7

```text
V - Version
What changed recently? Runtime, dependency, image tag, Terraform provider, helm chart, API version, kernel, SDK?

E - Environment
Where is it failing? Local, CI, dev, staging, prod, one namespace, one region, one AWS account/GCP project?

R - Resources
CPU, memory, disk, inode, connection pool, IP exhaustion, API quota, cloud cost, node capacity?

D - Dependencies
Database, DNS, registry, secrets, IAM, external API, package repo, cloud service dependency?

I - Infra health
Node health, cluster events, VPC routes, NAT gateway/Cloud NAT, load balancer, managed service status?

C - Connectivity
Security group/firewall, NACL, route table, DNS, service discovery, ports, TLS certs, proxy, private endpoint?

T - Telemetry
Application logs, CloudWatch/Cloud Logging, metrics, traces, audit logs, Kubernetes events, CI logs?
```

## 5-Second Openers

Use one of these before answering:

```text
I would isolate the failing layer first: application, container, CI/CD, Kubernetes, network, IAM, or managed service.
```

```text
I will not restart blindly. First I will read the exact error, check recent changes, and confirm if the issue is isolated or widespread.
```

```text
Because this is production, I would first reduce impact, then debug root cause, then add prevention.
```

## Best Answer Shape

1. State the likely layer.
2. Apply VERDICT quickly.
3. Give exact commands or cloud console checks.
4. Explain likely root causes.
5. Give the fix.
6. Give prevention.

## Example Template

Question: "A service is down after deployment. How do you debug?"

Answer:

```text
I would treat this as a deployment regression until proven otherwise.

V: Check new image tag, commit, config, Helm values, and Kubernetes deployment revision.
E: Confirm if only prod is affected or dev/staging also failed.
R: Check pod CPU/memory, restarts, OOMKilled, node pressure.
D: Check DB, secrets, DNS, downstream APIs, container registry pull.
I: Check node readiness, events, ingress/load balancer health.
C: Check service endpoints, ports, DNS, security policies, firewall/security groups.
T: Start with kubectl describe pod, kubectl logs, events, and application metrics.

Commands:
kubectl rollout status deploy/<name> -n <ns>
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous
kubectl get events -n <ns> --sort-by=.lastTimestamp

Fix depends on root cause: rollback image if bad code, fix secret/config if missing env, increase resources if OOMKilled, fix service/ingress if routing.

Prevention: add readiness probes, canary deployment, automated smoke tests, dashboards, and alerting on error rate/restarts.
```

## Interview Rule

Never answer only with one command. Give the command, the reason for the command, the expected signal, and the next action.

