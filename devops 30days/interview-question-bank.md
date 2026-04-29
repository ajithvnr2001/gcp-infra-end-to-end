# 30-Day Interview Question Bank

Format: 10 questions per day. Practice out loud. For every answer, speak in this order:

```text
1. Failing layer
2. VERDICT scan
3. Commands/checks
4. Root cause
5. Fix
6. Prevention
```

## Day 1 - Linux Basics

### 1. A Linux server is slow. How do you debug?

Answer: I first isolate whether it is CPU, memory, disk, network, or one process. V: check recent deploy/package changes. E: one server or all servers. R: `top`, `free -m`, `df -h`, `iostat` if available. D: dependent DB/API latency. I: load average, kernel logs, service status. C: network latency/DNS if requests are slow. T: `/var/log`, `journalctl`, app logs. Fix depends on signal: kill runaway process, increase resources, clean disk, rollback bad change, or scale out. Prevention: monitoring on CPU, memory, disk, load, and process restarts.

### 2. Disk is 95% full. What do you do?

Answer: First avoid deleting blindly. V: check what changed, log rotation, deployment artifacts. E: root volume or data volume. R: `df -h`, `du -sh /*`, `find / -size +500M`. D: database/logs/cache. I: inode usage with `df -i`. C: not usually connectivity. T: system and app logs. Fix: compress/archive logs, clean cache, remove old artifacts, expand disk if needed. Prevention: logrotate, retention policy, disk alerts at 70/80/90%.

### 3. What is the difference between `chmod` and `chown`?

Answer: `chmod` changes permissions; `chown` changes owner/group. In VERDICT terms this is usually a runtime/environment issue: app user cannot read/write a file. Checks: `ls -l`, process user from `ps aux`, container user if Docker/K8s. Fix: set least required permission, not `chmod 777`. Prevention: run app as non-root and define ownership in build/deploy scripts.

### 4. A service is not starting after reboot. How do you debug?

Answer: Treat it as service dependency/startup failure. V: recent package/config change. E: one host after reboot. R: disk/memory. D: DB/network/env files missing. I: `systemctl status service`, `journalctl -u service`, boot logs. C: service dependency ports/DNS. T: exact startup error. Fix unit file, env file, permission, dependency order, or app config. Prevention: health checks and restart policy.

### 5. Explain load average.

Answer: Load average is runnable or waiting tasks over 1, 5, and 15 minutes. It must be interpreted with CPU core count. Load 4 on 4 cores may be normal; load 20 on 4 cores is pressure. Check `uptime`, `top`, CPU wait, disk I/O. Interview point: high load is not always CPU; it can be I/O wait.

### 6. How do you check logs in Linux?

Answer: For systemd services use `journalctl -u <service> -f`. For traditional logs use `/var/log`, `tail -f`, `grep`, `less`. VERDICT: telemetry is the source of truth. Always search for the first error, not the last repeated symptom.

### 7. What is an inode issue?

Answer: Disk can show free space but still fail because inodes are exhausted. Check `df -i`. Common cause: many small temp/cache/session files. Fix by deleting old small files safely. Prevention: cleanup jobs and inode monitoring.

### 8. How do you find a process using a port?

Answer: Use `ss -lntp` or `lsof -i :8080`. Then identify process owner and command. Fix depends: stop duplicate service, change port, or update load balancer/service config. Prevention: define ports clearly in deployment config.

### 9. What is swap and should production use it?

Answer: Swap is disk-backed memory. It can prevent immediate OOM but causes latency. For latency-sensitive services, relying on swap is bad. Better fix is right-sizing memory, memory limits, and leak detection.

### 10. How do you explain Linux troubleshooting to an interviewer?

Answer: "I start with impact and layer isolation. I check CPU, memory, disk, process, service logs, and recent changes. I avoid destructive actions until I know the cause. After restoring service, I add monitoring or automation to prevent recurrence."

## Day 2 - Bash Scripting

### 1. Why use `set -euo pipefail`?

Answer: It makes scripts fail safely. `-e` exits on error, `-u` catches undefined variables, `pipefail` catches failed pipeline commands. VERDICT: this prevents hidden failures in automation. Still handle expected failures with `|| true` or explicit checks.

### 2. A Bash script works manually but fails in cron. Why?

Answer: E is the key: cron has a different environment. PATH, working directory, user, permissions, and env vars differ. Checks: log output, use absolute paths, print `env`, redirect stderr. Fix: set PATH, `cd` to script directory, load env file. Prevention: make scripts environment-independent.

### 3. How do you handle script arguments?

Answer: Use `$1`, `$2`, validate required args, print usage on missing input. For safer scripts use `getopts`. Always quote variables: `"$VAR"`. Prevention: clear usage examples and input validation.

### 4. How do you parse logs with shell?

Answer: Use `grep` for filtering, `awk` for fields, `sort | uniq -c` for counts. Example: count 500 errors by endpoint. VERDICT: telemetry drives debugging; parsing turns logs into signals.

### 5. What is exit code and why important?

Answer: Exit code `0` means success, non-zero means failure. CI/CD and monitoring depend on exit codes. A script that prints "failed" but exits 0 causes false success.

### 6. How do you make a script idempotent?

Answer: It should be safe to run multiple times. Check if resource exists before creating; update instead of duplicate. Example: `kubectl create ns x --dry-run=client -o yaml | kubectl apply -f -`. Prevention: design automation for retries.

### 7. Bash or Python for automation?

Answer: Bash is good for command orchestration and simple file/log tasks. Python is better for APIs, JSON, complex logic, error handling, and tests. Interview line: "I use Bash for glue, Python for maintainable automation."

### 8. How do you secure shell scripts?

Answer: Avoid hardcoded secrets, quote variables, validate inputs, avoid `eval`, use least privilege, log safely, and fail fast. Store secrets in Secret Manager/Secrets Manager, not files.

### 9. How do you debug a shell script?

Answer: Use `bash -x script.sh`, add `set -x` temporarily, echo key variables, inspect exit codes. Do not print secrets. Check environment and working directory.

### 10. Give a useful DevOps Bash script example.

Answer: A health-check script that checks disk, memory, service status, and endpoint health, exits non-zero if thresholds fail, and can run in cron or CI.

## Day 3 - Python For DevOps

### 1. When is Python better than Bash?

Answer: Python is better for APIs, JSON/YAML, retries, structured logs, tests, and complex conditions. Bash is better for short command glue. VERDICT: if maintainability and error handling matter, choose Python.

### 2. How do you call an API in Python safely?

Answer: Use `requests` with timeout, status-code checks, retries if needed, exception handling, and no hardcoded tokens. Telemetry: log URL path, status, duration, not secrets.

### 3. How do you run shell commands from Python?

Answer: Use `subprocess.run([...], check=True, capture_output=True, text=True)`. Avoid `shell=True` unless required. Handle `CalledProcessError`. This prevents injection and catches failures.

### 4. How do you parse JSON logs?

Answer: Use `json.loads` line by line, handle invalid JSON, extract fields like status, latency, service, trace_id. Convert logs into counts and percentiles.

### 5. How do you write production-grade Python scripts?

Answer: Use functions, `argparse`, logging, timeouts, exception handling, config from env, clear exit codes, and tests for critical logic.

### 6. How do you manage Python dependencies?

Answer: Use virtualenv, pinned requirements, lock files when possible, and CI checks. In Docker use slim images and install only runtime dependencies.

### 7. A Python automation script intermittently fails. How do you debug?

Answer: V: dependency/API changes. E: local vs CI. R: timeout/rate limit. D: external API. I: runner health. C: DNS/proxy. T: logs with timestamps and status codes. Fix retries/backoff/timeouts or dependency issue.

### 8. How do you avoid exposing secrets in Python?

Answer: Read from env or secret manager, never print tokens, mask logs, avoid committing `.env`, use IAM role/service account for cloud auth.

### 9. How can Python help in cloud cost optimization?

Answer: Query cloud APIs for idle disks, unused IPs, stopped VMs, old snapshots, unattached load balancers, and generate reports. Automate tagging checks.

### 10. Give a Python DevOps project for interviews.

Answer: "I built a health audit script that reads service endpoints, checks status/latency, validates SSL expiry, writes JSON/CSV report, and exits non-zero for CI alerts."

## Day 4 - Git And Release Workflow

### 1. What is a safe Git workflow for production?

Answer: Feature branch, PR review, CI checks, merge to main, tag release, deploy through pipeline, monitor, rollback plan. VERDICT: version and environment control matter.

### 2. How do you rollback a bad deployment?

Answer: Identify release version, confirm impact, rollback deployment/image/helm release, verify health, then root cause. Git revert is for code; deployment rollback may be image or Kubernetes rollout.

### 3. What is the difference between merge and rebase?

Answer: Merge preserves branch history with merge commit; rebase rewrites commits on top of target. For shared branches avoid unsafe rebases. Interview: choose team policy and clarity.

### 4. What do you check in a PR as DevOps?

Answer: Infra risk, secrets, resource limits, health checks, rollback, observability, IAM permissions, cost impact, security groups/firewalls, pipeline effects.

### 5. What is GitOps?

Answer: Git is the source of truth for desired infrastructure/app state. A controller like ArgoCD syncs cluster state to Git. Benefits: auditability, rollback, review, drift detection.

### 6. ArgoCD app is OutOfSync. What do you do?

Answer: V: recent Git commit. E: one app/namespace. R: cluster resources. D: CRDs/secrets/images. I: ArgoCD controller health. C: repo access. T: ArgoCD events/diff. Fix manifest drift or sync errors.

### 7. How do you prevent secrets in Git?

Answer: `.gitignore`, secret scanning, pre-commit hooks, CI secret scan, use Secret Manager/External Secrets, rotate immediately if leaked.

### 8. What is a release tag?

Answer: A stable pointer to a commit used for release/version tracking. In interviews: tags make rollback and audit easier than only using mutable `latest`.

### 9. CI passes but production fails. Why?

Answer: Environment difference: config, secrets, data, network, IAM, resource limits. Fix by adding staging parity, smoke tests, and deployment validation.

### 10. How do you explain your release experience?

Answer: "I focus on controlled changes: PR, CI, image tag, deployment, health verification, and rollback. I also ensure logs/metrics show whether the release is healthy."

## Day 5 - Docker

### 1. Docker build fails. How do you debug?

Answer: Use VERDICT: V Dockerfile/base tag changes, E local/CI, R disk, D package registry/base image, I Docker daemon, C internet/proxy, T exact build step. Fix the failing layer, not the whole Dockerfile.

### 2. Container exits immediately. Why?

Answer: Main process exited, bad command, missing env, permission issue, app crash. Checks: `docker logs`, `docker inspect`, exit code, run interactive shell. Prevention: health checks and clear entrypoint.

### 3. Image is too large. How reduce?

Answer: Use slim base, multi-stage builds, `.dockerignore`, remove build tools, clean package cache in same layer, inspect with `docker history`.

### 4. Container cannot reach another container.

Answer: Check same Docker network, service name DNS, exposed internal port, app binding to `0.0.0.0`, firewall. Telemetry: logs and `docker inspect`.

### 5. Difference between CMD and ENTRYPOINT?

Answer: ENTRYPOINT defines executable; CMD provides default args. Use ENTRYPOINT for fixed command, CMD for overridable defaults.

### 6. What is Docker layer caching?

Answer: Docker reuses unchanged layers. Put dependency files before app code to avoid reinstalling dependencies every build. Bad ordering slows CI.

### 7. Why not run containers as root?

Answer: If container escape or volume misuse happens, root increases blast radius. Use non-root user, drop capabilities, read-only filesystem when possible.

### 8. What is `.dockerignore`?

Answer: It excludes files from build context, reducing build time and preventing secrets/junk from entering images.

### 9. ImagePullBackOff in Kubernetes after Docker push. Why?

Answer: Wrong image name/tag, registry auth, image not pushed, private registry permission, architecture mismatch. Check pod events.

### 10. How do you explain Docker in interviews?

Answer: "Docker packages app plus dependencies into an image. A container is a running instance. Debug by separating build, runtime, network, and storage layers."

## Day 6 - Docker Compose

### 1. Compose app cannot connect to DB. How debug?

Answer: Check service names, network, DB port, env vars, startup order, health checks. In Compose, use DB service name, not localhost.

### 2. What is `depends_on` limitation?

Answer: It controls start order, not readiness. DB process may start but not be ready. Use health checks or app retry logic.

### 3. Volume data is stale. What do you do?

Answer: Identify named volume, confirm data risk, backup if needed, remove with `docker compose down -v` only when safe. Prevention: documented reset scripts.

### 4. Port conflict in Compose. How fix?

Answer: Host port already used. Check `ss/lsof`, change host mapping, or stop conflicting service. Container internal port can stay same.

### 5. Env var not applied. Why?

Answer: Wrong `.env` path, variable not referenced, container not recreated, shell env overriding. Use `docker compose config` to inspect rendered config.

### 6. How do you see Compose logs?

Answer: `docker compose logs -f <service>`. Use timestamps and grep for first error.

### 7. Compose vs Kubernetes?

Answer: Compose is local/dev multi-container orchestration. Kubernetes is production orchestration with scheduling, self-healing, service discovery, scaling.

### 8. How do you make local dev closer to prod?

Answer: Same image, env structure, health checks, resource limits where possible, realistic service dependencies, seed data.

### 9. Compose build slow. How improve?

Answer: Docker cache, `.dockerignore`, dependency layer ordering, avoid copying large folders, use buildkit.

### 10. Interview story?

Answer: "I used Compose to reproduce production dependency issues locally by running app, DB, and monitoring together, which reduced debugging time."

## Day 7 - Week 1 Mock

### 1. App is slow and container CPU is high.

Answer: Check container stats, app logs, recent release, request volume, dependency latency, profiling if needed. Fix code regression, scale, or resource limits. Prevent with CPU alerts.

### 2. Script deleted wrong files. What went wrong?

Answer: Missing path validation, unquoted variables, unsafe glob, no dry-run. Prevention: dry-run mode, absolute path checks, confirmation, backups.

### 3. Python script fails only in CI.

Answer: Different Python version, missing env var, dependency lock, network/proxy, working directory. Add version pinning and CI logs.

### 4. Docker app works locally but not on another machine.

Answer: Hidden local dependency, env var, architecture mismatch, missing volume, network difference. Make image self-contained and config explicit.

### 5. How do you debug permission denied?

Answer: Check user, file owner, permissions, mount options, SELinux/AppArmor if applicable, container user. Fix least privilege.

### 6. What is your automation mindset?

Answer: Automate repeated, risky, or time-consuming tasks. Add validation, logging, idempotency, and rollback.

### 7. How do you document troubleshooting?

Answer: Symptom, impact, checks, root cause, fix, prevention, commands. This becomes runbook.

### 8. How do you handle unknown errors?

Answer: Do not guess. Isolate layer, collect telemetry, compare last known good, reproduce, then fix.

### 9. What did you learn in week 1?

Answer: Linux inspection, safe scripting, Python automation, Git release basics, Docker build/runtime debugging.

### 10. Why DevOps?

Answer: "I enjoy building reliable delivery systems, automating operations, and debugging across app, infra, and cloud layers."

## Day 8 - CI/CD

### 1. Pipeline fails at dependency install.

Answer: Check lockfile, package registry, network, cache, language version, credentials. Fix pinning or registry access. Prevention: cache and reproducible builds.

### 2. Tests pass but deploy fails.

Answer: Deployment environment issue: credentials, cluster access, image tag, manifest, resource quota. Check deploy logs and permissions.

### 3. Why immutable image tags?

Answer: `latest` is ambiguous. Commit SHA tags provide traceability and rollback. Use latest only as convenience, not audit source.

### 4. How do you secure CI/CD?

Answer: Least privilege tokens, OIDC, secret masking, protected branches, approval gates, dependency scanning, image scanning.

### 5. What stages should a pipeline have?

Answer: lint, test, build, scan, push, deploy, smoke test, notify. Production may include approval/canary.

### 6. Build is slow. How optimize?

Answer: Cache dependencies, Docker layer order, parallel jobs, smaller images, avoid unnecessary workspace files.

### 7. How do you debug Cloud Build failure?

Answer: Read failing step, exact log, service account permissions, substitutions, image registry, network. In your project, Artifact Registry repo/permissions matter.

### 8. What is rollback in CI/CD?

Answer: Automated return to previous known-good image/config/release. Kubernetes: `kubectl rollout undo` or deploy previous image tag.

### 9. How do you prevent broken deployments?

Answer: tests, scans, staging, smoke tests, health checks, readiness probes, canary, rollback.

### 10. Interview CI/CD explanation?

Answer: "A good pipeline makes every change traceable, tested, packaged, scanned, deployed consistently, and rollback-ready."

## Day 9 - Kubernetes Basics

### 1. Pod is CrashLoopBackOff.

Answer: V image/config change. E namespace/deployment. R OOM? D missing secret/DB. I node events. C service dependencies. T `kubectl logs --previous`, `describe pod`. Fix root cause.

### 2. Pod is Pending.

Answer: Check scheduling: insufficient CPU/memory, node selector, taints, PVC, quota. `kubectl describe pod` gives reason.

### 3. ImagePullBackOff.

Answer: Wrong image/tag, registry permissions, secret, repo missing, network. Check events and registry.

### 4. ConfigMap vs Secret.

Answer: ConfigMap stores non-sensitive config. Secret stores sensitive data but still needs encryption/RBAC. Use external secret managers for production.

### 5. Deployment vs StatefulSet.

Answer: Deployment for stateless replicas. StatefulSet for stable identity/storage/order, like databases.

### 6. Readiness vs liveness.

Answer: Readiness controls traffic; liveness restarts unhealthy containers. Wrong probes can cause outages.

### 7. Service selector wrong. Symptom?

Answer: Service has no endpoints. Pod works directly but service fails. Check labels and `kubectl get endpoints`.

### 8. How to rollback Kubernetes deployment?

Answer: `kubectl rollout history`, `kubectl rollout undo`, verify pods and metrics. Best with immutable image tags.

### 9. Namespace purpose?

Answer: Isolation boundary for resources, RBAC, quotas, organization. Not a hard network security boundary unless network policies exist.

### 10. Kubernetes mental model?

Answer: Desired state in YAML, controllers reconcile actual state, scheduler places pods, kubelet runs them, service exposes them.

## Day 10 - Kubernetes Networking

### 1. Pod can curl app locally but service fails.

Answer: Check Service selector, targetPort, endpoints, pod readiness, network policy. `kubectl get svc,endpoints,pods --show-labels`.

### 2. Ingress returns 404.

Answer: Host/path rule mismatch, ingress class, backend service name/port, controller logs. Check ingress describe.

### 3. Ingress returns 502.

Answer: Backend unhealthy, wrong service port, pod not ready, app not listening. Trace ingress -> service -> endpoints -> pod.

### 4. DNS fails inside pod.

Answer: Check CoreDNS pods, `/etc/resolv.conf`, service name/namespace, network policy, node DNS. Try `nslookup`.

### 5. NetworkPolicy blocks traffic.

Answer: If policies select pod, default deny may apply. Check ingress/egress rules, namespace selectors, pod labels.

### 6. ClusterIP vs LoadBalancer.

Answer: ClusterIP is internal. LoadBalancer provisions external LB. Ingress provides HTTP routing on top of service.

### 7. What are endpoints?

Answer: Backend pod IPs selected by service. Empty endpoints means service has no ready matching pods.

### 8. How do you expose app securely?

Answer: Ingress/ALB, TLS, WAF if needed, restrict admin endpoints, network policies, auth, rate limiting.

### 9. Service port vs targetPort?

Answer: `port` is service port; `targetPort` is container port. Mismatch causes routing failure.

### 10. Request path in K8s?

Answer: DNS/LB -> ingress controller -> ingress rule -> service -> endpoint -> pod container port.

## Day 11 - Terraform

### 1. What is Terraform state?

Answer: State maps config to real resources. Protect it with remote backend, locking, access control. Losing state risks duplicate/destructive changes.

### 2. What is drift?

Answer: Real infra differs from Terraform state/config due to manual changes. Detect with plan. Fix by importing, updating config, or reverting manual change.

### 3. Plan shows destroy in prod. What do you do?

Answer: Stop. Read why, check recent changes, state, lifecycle rules, provider version, variables/workspace. Never apply blindly.

### 4. Terraform apply failed halfway.

Answer: Check state, cloud resources created, rerun plan, import if needed. Terraform is declarative but partial applies can happen.

### 5. Variables vs locals.

Answer: Variables are inputs. Locals are computed internal values. Outputs expose values.

### 6. Module purpose.

Answer: Reusable, standardized infrastructure. Prevent copy-paste and enforce patterns.

### 7. Remote backend benefit.

Answer: Shared state, locking, safer team collaboration, audit/control.

### 8. How handle secrets in Terraform?

Answer: Avoid hardcoding. Use secret manager references, sensitive variables, secure backend, restricted state access because state may contain secrets.

### 9. Count vs for_each.

Answer: `for_each` is better for stable identity by key. `count` index changes can recreate wrong resources.

### 10. Terraform interview line?

Answer: "I treat Terraform plan as a change review artifact. I check blast radius before applying."

## Day 12 - Observability

### 1. High latency. How debug?

Answer: Check golden signals. V release. E endpoint/region. R CPU/memory/DB connections. D downstream latency. I LB/node health. C network/DNS. T traces/logs/metrics. Fix bottleneck.

### 2. Logs vs metrics vs traces.

Answer: Logs explain events, metrics show trends, traces show request path. Use all three for production debugging.

### 3. What alerts are useful?

Answer: Error rate, latency, saturation, availability, pod restarts, disk, DB connections, queue depth. Avoid noisy alerts.

### 4. Service has no logs.

Answer: Check app logging config, container stdout/stderr, log agent, permissions, namespace filters, sampling.

### 5. What is SLO?

Answer: Service Level Objective: target reliability like 99.9% availability. Alerts should map to user impact and error budget.

### 6. Prometheus pull model?

Answer: Prometheus scrapes metrics endpoints. Kubernetes annotations/service monitors define targets.

### 7. Grafana dashboard design?

Answer: Start with user-facing indicators, then service metrics, then infra. Include latency, error rate, traffic, saturation.

### 8. CloudWatch vs Cloud Logging?

Answer: AWS CloudWatch handles logs/metrics/alarms. GCP Cloud Logging/Monitoring split similarly. Concept is same: centralized telemetry.

### 9. How find root cause from logs?

Answer: Start at first error near incident time, correlate trace/request ID, compare with deploy/audit logs.

### 10. Prevention after incident?

Answer: Add missing metric/log/alert/runbook so next incident is faster to detect and fix.

## Day 13 - Secrets And IAM

### 1. Static keys in repo. What do you do?

Answer: Revoke/rotate immediately, remove from history if needed, audit usage, add secret scanning, move to secret manager/OIDC/roles.

### 2. GCP service account vs AWS role.

Answer: Both provide workload identity. AWS role is assumed via STS temporary credentials. GCP uses service account identity/tokens.

### 3. AccessDenied in AWS.

Answer: Check identity policy, resource policy, permission boundary, SCP, session policy, KMS policy, region/account. CloudTrail helps.

### 4. Least privilege meaning.

Answer: Only required actions on required resources for required time. Avoid wildcard admin except break-glass.

### 5. Kubernetes secret safe?

Answer: Base64 is not encryption. Use encryption at rest, RBAC, external secrets, avoid printing env.

### 6. How rotate secrets?

Answer: Create new secret, deploy app accepting new value, verify, remove old, audit. Use managed rotation when available.

### 7. CI/CD secret best practice.

Answer: OIDC federation, short-lived credentials, protected environments, no secrets in logs, least privilege deploy role.

### 8. IAM change broke app.

Answer: V recent policy. E one service. D cloud API. T audit logs/access denied. Rollback policy or add missing permission narrowly.

### 9. What is service account impersonation?

Answer: Acting as another service account with permission. Useful for CI/CD without static keys.

### 10. Interview security line?

Answer: "I prefer identity-based temporary access over long-lived keys, and I validate permissions through audit logs."

## Day 14 - Week 2 Mock

### 1. Deployment failed after pipeline success.

Answer: Check image tag, registry, manifest, cluster auth, rollout status, pod events, logs, service endpoints. Rollback if prod impact.

### 2. Terraform changed more resources than expected.

Answer: Stop apply, inspect plan, provider/variable changes, state drift, module changes. Reduce blast radius.

### 3. Secret missing in pod.

Answer: Check secret exists, namespace, envFrom/keyRef, RBAC/external secret sync, pod restart after secret update.

### 4. Monitoring missed outage.

Answer: Alert covered infrastructure but not user symptom. Add blackbox/synthetic, error rate, latency SLO alerts.

### 5. CI/CD deploy permission denied.

Answer: Check deploy identity, IAM/RBAC, kubeconfig, cloud role, token expiry, protected branch/environment.

### 6. Kubernetes pods restart randomly.

Answer: Check OOMKilled, liveness probe, node pressure, app crash, dependency timeout. Use `describe`, previous logs, metrics.

### 7. ArgoCD sync fails.

Answer: Check manifest validity, missing namespace/CRD, RBAC, image pull secret, repo credentials, diff.

### 8. Why use IaC?

Answer: Repeatability, review, audit, rollback, drift detection, collaboration.

### 9. How explain week 2 project?

Answer: "I connected CI/CD, Terraform, Kubernetes, secrets, and observability into a production-style delivery workflow."

### 10. Biggest week 2 principle?

Answer: Safe change management: plan, deploy, observe, rollback, prevent.

## Day 15 - AWS IAM

### 1. IAM role vs user.

Answer: User is long-term identity, role is assumable temporary identity. For workloads prefer roles, not users/keys.

### 2. EC2 accesses S3 without keys. How?

Answer: Attach IAM role through instance profile. EC2 metadata provides temporary credentials. Policy grants S3 actions.

### 3. What is STS?

Answer: Security Token Service issues temporary credentials when assuming roles or federating identities.

### 4. What is trust policy?

Answer: Defines who can assume a role. Permission policy defines what role can do.

### 5. AWS OIDC for CI/CD.

Answer: CI provider gets short-lived AWS role without static keys. Trust policy restricts repo/branch.

### 6. Access denied despite policy allow.

Answer: Check explicit deny, SCP, permission boundary, resource policy, KMS key, wrong account/region.

### 7. AWS IAM compared to GCP IAM.

Answer: GCP grants roles to principals on resources. AWS combines identity policies, resource policies, trust policies, SCPs.

### 8. Root user best practice.

Answer: Enable MFA, do not use daily, no access keys, use admin IAM role/user for operations.

### 9. How audit IAM actions?

Answer: CloudTrail records API calls. Use it to identify who changed policy/security group.

### 10. Interview IAM line.

Answer: "I design AWS access around roles, temporary credentials, least privilege, and CloudTrail auditability."

## Day 16 - AWS VPC

### 1. Public vs private subnet.

Answer: Public subnet route table has default route to Internet Gateway. Private subnet routes outbound through NAT Gateway and has no direct inbound internet route.

### 2. EC2 in private subnet cannot reach internet.

Answer: Check route table to NAT Gateway, NAT in public subnet, IGW, security group egress, NACL, DNS, instance source/dest not relevant unless NAT instance.

### 3. Security Group vs NACL.

Answer: SG is stateful attached to ENI. NACL is stateless subnet-level. SG usually primary control.

### 4. ALB cannot reach EC2.

Answer: Target SG must allow inbound from ALB SG on app port. Health check path/port must match app.

### 5. What is route table?

Answer: Subnet-associated routing rules. Determines traffic path to local, IGW, NAT, peering, TGW.

### 6. What is VPC peering?

Answer: Private connectivity between VPCs. Non-transitive. Routes and SG/NACL must allow traffic.

### 7. AWS NAT vs GCP Cloud NAT.

Answer: Both provide outbound internet for private workloads. AWS NAT Gateway is placed in public subnet and route tables point to it.

### 8. DNS issue in VPC.

Answer: Check enableDnsSupport/enableDnsHostnames, Route 53 private zone, resolver, security/NACL egress UDP/TCP 53.

### 9. VPC Flow Logs use.

Answer: Network telemetry showing accepted/rejected traffic. Useful for security group/NACL/routing debugging.

### 10. Interview VPC line.

Answer: "In AWS I always trace traffic through route table, security group, NACL, DNS, and target health."

## Day 17 - EC2

### 1. EC2 unreachable by SSH.

Answer: Check instance running, status checks, public IP/bastion, SG inbound 22, NACL, route to IGW, key pair, OS firewall, username.

### 2. EC2 status check failed.

Answer: System check means AWS host/network issue; instance check means OS/app issue. Stop/start may move host; inspect console logs.

### 3. AMI purpose.

Answer: Machine image template for launching instances. Use golden AMIs for consistent builds, patching, rollback.

### 4. EBS volume full.

Answer: Expand EBS, grow filesystem, clean logs, add monitoring. Snapshot before risky operations.

### 5. User data not running.

Answer: Runs at first boot by default. Check cloud-init logs, script syntax, permissions, internet access.

### 6. ASG keeps replacing instances.

Answer: Health check failing, bad launch template, app not starting, ALB health path wrong, bootstrap failure.

### 7. EC2 vs GCE.

Answer: Same VM concept; AWS uses AMI, security groups, IAM instance profile; GCP uses images, firewall rules, service accounts.

### 8. Spot instance risk.

Answer: Cheaper but can be interrupted. Use for fault-tolerant workloads, mixed ASG, checkpointing.

### 9. Patch strategy.

Answer: Bake new AMI or patch via SSM, deploy rolling through ASG, verify, rollback by previous launch template.

### 10. EC2 interview line.

Answer: "For EC2 issues I separate cloud-level health, network access, OS boot, service startup, and application health."

## Day 18 - ALB And Route 53

### 1. ALB returns 502.

Answer: Backend closed connection, wrong port, app crash, bad protocol, target SG. Check target health, app logs, ALB logs.

### 2. ALB returns 503.

Answer: No healthy targets or listener rule issue. Check target group health and health check config.

### 3. ALB vs NLB.

Answer: ALB is layer 7 HTTP/HTTPS routing. NLB is layer 4 TCP/UDP high performance/static IP use cases.

### 4. Route 53 record types.

Answer: A/AAAA, CNAME, Alias, weighted, latency, failover. Alias commonly points to ALB/CloudFront.

### 5. Health check failing but app works.

Answer: Wrong path, port, expected status code, host header, SG, app requires auth. Health endpoint should be simple.

### 6. SSL cert issue on ALB.

Answer: Check ACM cert region, listener, SNI, domain validation, TLS policy, DNS record.

### 7. Blue-green with ALB?

Answer: Use target groups/listener weights or Route 53 weighted records. Shift traffic gradually and rollback.

### 8. DNS propagation delay.

Answer: TTL controls caching. Lower TTL before migration. Route 53 changes are quick but client resolvers cache.

### 9. GCP LB vs AWS ALB.

Answer: Both route external traffic. AWS separates ALB/NLB; GCP global LB is integrated differently.

### 10. Interview traffic line.

Answer: "I trace from DNS to load balancer listener, rule, target group, security group, and app health."

## Day 19 - S3, ECR, CloudFront

### 1. S3 AccessDenied.

Answer: Check IAM, bucket policy, object ownership, block public access, ACLs if used, KMS key policy, wrong bucket/account.

### 2. S3 public access not working.

Answer: Block Public Access may override policy. Check bucket policy and object ownership. Prefer CloudFront OAC for public delivery.

### 3. ECR image pull fails.

Answer: Check image tag exists, task/node IAM pull permission, ECR auth, region/account, network to ECR endpoints/NAT.

### 4. ECR vs Artifact Registry.

Answer: Both store container images. IAM integration and registry URL format differ.

### 5. CloudFront serving old content.

Answer: Cache TTL. Invalidate path or version assets. Check origin and cache behavior.

### 6. S3 lifecycle policy.

Answer: Moves/deletes objects by age/prefix/tags. Used for cost optimization and retention.

### 7. S3 versioning benefit.

Answer: Recover overwritten/deleted objects. Costs more, pair with lifecycle.

### 8. KMS encrypted S3 access denied.

Answer: Need both S3 permission and KMS decrypt permission/key policy.

### 9. Static website hosting on AWS.

Answer: S3 stores assets, CloudFront serves HTTPS/CDN, Route 53 DNS, ACM cert in us-east-1 for CloudFront.

### 10. Interview storage line.

Answer: "For S3 issues I check identity policy, bucket policy, block public access, ownership, encryption, and object path."

## Day 20 - AWS Databases

### 1. App cannot connect to RDS.

Answer: Check endpoint, port, SG from app to RDS, subnet routing, public accessibility, credentials, DB status, max connections.

### 2. RDS Multi-AZ vs read replica.

Answer: Multi-AZ is HA/failover. Read replica scales reads and can support DR but not same as automatic HA.

### 3. RDS slow queries.

Answer: Check CPU, memory, IOPS, connections, slow query logs, indexes, query plan, locks.

### 4. RDS backup strategy.

Answer: Automated backups, snapshots, retention, point-in-time recovery, test restore.

### 5. DynamoDB partition key importance.

Answer: Bad key causes hot partitions. Choose high-cardinality evenly distributed access pattern.

### 6. DynamoDB vs RDS.

Answer: RDS for relational SQL/joins/transactions. DynamoDB for high-scale key-value/document predictable access.

### 7. Redis cache failure.

Answer: App should degrade gracefully. Check ElastiCache node, connections, memory eviction, security group.

### 8. Cloud SQL vs RDS.

Answer: Same managed relational idea: backups, HA, private networking, IAM/integration differences.

### 9. DB migration safe approach.

Answer: Backward-compatible schema, backup, migration in stages, test, monitor, rollback plan.

### 10. Interview DB line.

Answer: "For DB connectivity I check network, auth, endpoint, DB health, connection limits, and app config."

## Day 21 - AWS Containers

### 1. ECS task stopped.

Answer: Check stopped reason, container exit code, CloudWatch logs, image pull, task execution role, env/secrets, CPU/memory.

### 2. ECS service not stable.

Answer: Health checks failing, desired count not met, capacity, deployment config, target group issue.

### 3. Task role vs execution role.

Answer: Execution role lets ECS pull image/write logs/read secrets. Task role is app permissions to AWS APIs.

### 4. ECS vs EKS.

Answer: ECS is simpler AWS-native container orchestration. EKS is Kubernetes for portability/ecosystem/operators.

### 5. Fargate benefit.

Answer: No node management. Pay per task resources. Good for simpler operational model.

### 6. EKS pod ImagePullBackOff.

Answer: Same K8s issue: image/tag/registry/IAM/node network. For ECR, node role/pod identity and region matter.

### 7. EKS node NotReady.

Answer: Check EC2 health, kubelet, CNI IP exhaustion, IAM, security group, disk pressure.

### 8. Cloud Run vs ECS Fargate.

Answer: Both reduce server management. Cloud Run is more serverless and request-driven; ECS gives more AWS networking/task control.

### 9. Container secrets in AWS.

Answer: Use Secrets Manager/SSM injected into ECS task or external secrets in EKS. Avoid baking secrets into image.

### 10. Interview container choice.

Answer: "If Kubernetes is required I choose EKS; if simple containers with less overhead, ECS Fargate is often better."

## Day 22 - AWS Monitoring

### 1. How find who changed SG?

Answer: CloudTrail lookup for `AuthorizeSecurityGroupIngress`, `RevokeSecurityGroupIngress`, user/role, time, source IP.

### 2. CloudWatch alarm not firing.

Answer: Wrong metric/dimensions/statistic/period, missing data treatment, threshold, namespace, region.

### 3. VPC Flow Logs show REJECT.

Answer: Likely SG/NACL/routing. Check source/destination/port/action and match with rules.

### 4. ECS logs missing.

Answer: Check awslogs driver, execution role logs permission, log group, region, app stdout/stderr.

### 5. ALB access logs use.

Answer: Debug status codes, target response time, client IP, request path, target status.

### 6. CloudWatch vs CloudTrail.

Answer: CloudWatch is telemetry metrics/logs/alarms. CloudTrail is audit of AWS API actions.

### 7. How monitor RDS?

Answer: CPU, memory, connections, storage, IOPS, latency, slow queries, replication lag.

### 8. How monitor cost?

Answer: Budgets, Cost Explorer, anomaly detection, tags, reports by service/account/environment.

### 9. Alert noise problem.

Answer: Tune thresholds, alert on symptoms not every cause, add severity, route ownership, remove duplicate alerts.

### 10. Interview monitoring line.

Answer: "I start with user-impact metrics, then drill into service and infrastructure metrics."

## Day 23 - Multi-Cloud

### 1. How will you learn AWS if you know GCP?

Answer: Map concepts: Project->Account, Service Account->Role, GKE->EKS, Cloud SQL->RDS, GCS->S3, Cloud Logging->CloudWatch. Then learn differences in IAM/networking.

### 2. Main IAM difference?

Answer: AWS has trust policies/resource policies/SCPs more commonly. GCP IAM is more uniform around resource hierarchy and service accounts.

### 3. Main network difference?

Answer: AWS route tables attach to subnets, security groups attach to ENIs, NACLs are subnet-level. GCP firewall rules are VPC-level with targets.

### 4. GKE to EKS migration concerns?

Answer: IAM, ingress controller/ALB, storage classes, registry, secrets, observability, node autoscaling, network policies.

### 5. Cloud Build to AWS equivalent?

Answer: CodeBuild for builds, CodePipeline for pipeline orchestration, CodeDeploy for deployment patterns.

### 6. Artifact Registry to ECR?

Answer: Same registry concept. Update image names, auth, IAM pull/push, lifecycle policies.

### 7. Cloud NAT to NAT Gateway?

Answer: Same private outbound pattern. AWS NAT Gateway placed per AZ/public subnet for HA.

### 8. Cloud Armor to AWS?

Answer: AWS WAF and Shield for web protection/DDoS.

### 9. How explain multi-cloud confidence?

Answer: "The names differ, but the layers are same: identity, network, compute, storage, deploy, observe, secure."

### 10. Risk in multi-cloud?

Answer: Operational complexity. Need standard IaC, logging, IAM governance, cost tags, and clear ownership.

## Day 24 - Incidents

### 1. Production is down. First steps?

Answer: Assess impact, communicate, stop bleeding, rollback if recent change, gather telemetry, assign roles, document timeline.

### 2. Restart or debug first?

Answer: If restart restores service safely, do it after capturing minimal evidence. Do not lose all forensic data. Balance recovery and root cause.

### 3. Bad deployment caused outage.

Answer: Rollback, verify, freeze further deploys, compare changes, identify missed test/alert, postmortem.

### 4. How communicate incident?

Answer: Short factual updates: impact, current action, ETA if known, next update time. Avoid guesses.

### 5. What is postmortem?

Answer: Blameless document: summary, timeline, impact, root cause, contributing factors, action items.

### 6. High error rate after DB change.

Answer: Check DB metrics, connection pool, schema compatibility, slow queries, locks, app logs. Rollback if needed.

### 7. Regional outage handling.

Answer: Confirm provider status, failover if architecture supports, communicate, monitor dependencies.

### 8. Alert says CPU high.

Answer: Check if user impact exists. CPU may be symptom. Correlate traffic, release, errors, latency.

### 9. Incident prevention.

Answer: Better tests, canary, alerts, runbooks, capacity planning, change review.

### 10. Interview incident story format.

Answer: Situation, impact, action, technical root cause, result, prevention.

## Day 25 - Security

### 1. Secure Kubernetes deployment.

Answer: Non-root, read-only FS, drop capabilities, resource limits, network policies, RBAC, secrets manager, image scanning.

### 2. Secure AWS VPC.

Answer: Private subnets, least SG rules, no public DB, NACL as extra guard, VPC endpoints, flow logs.

### 3. Secret leaked in logs.

Answer: Rotate secret, remove logs if possible, audit usage, fix logging mask, add detection.

### 4. What is encryption at rest/in transit?

Answer: At rest protects stored data using KMS/disk/bucket encryption. In transit uses TLS.

### 5. Image vulnerability found.

Answer: Identify severity/exploitability, update base/dependency, rebuild, redeploy, scan in CI.

### 6. Public S3 bucket risk.

Answer: Data exposure. Use block public access, bucket policies, CloudFront OAC, least privilege.

### 7. SSH to production best practice.

Answer: Prefer SSM/IAP/bastion, MFA, audit, no shared keys, least access, emergency only.

### 8. How secure Terraform state?

Answer: Remote backend encryption, locking, restricted IAM, avoid secrets in state, audit access.

### 9. What is defense in depth?

Answer: Multiple controls: IAM, network, encryption, logging, runtime security, backups.

### 10. Interview security line.

Answer: "I secure by default: least privilege, private networking, managed secrets, encryption, logging, and automated scanning."

## Day 26 - Cost

### 1. Cloud bill increased. Debug?

Answer: Check Cost Explorer/Billing by service, account/project, region, tags. Look for new resources, traffic, storage, NAT, logs.

### 2. NAT Gateway cost high.

Answer: High data processing. Use VPC endpoints for AWS services, reduce cross-AZ traffic, review architecture.

### 3. Kubernetes cost optimization.

Answer: Requests/limits, HPA, cluster autoscaler, right-size nodes, remove idle namespaces, spot/preemptible for safe workloads.

### 4. RDS cost high.

Answer: Right-size, reserved instances, storage type, read replicas, backups retention, stop non-prod if possible.

### 5. S3 cost optimization.

Answer: Lifecycle to IA/Glacier, delete old versions, compress, review request costs.

### 6. Logging cost high.

Answer: Reduce noisy logs, sampling, retention, log levels, exclude health checks.

### 7. Idle resource examples.

Answer: unattached disks, unused IPs, old snapshots, stopped but charged resources, idle load balancers.

### 8. Cost tagging.

Answer: Tags/labels by env, team, app, owner, cost center. Required for accountability.

### 9. Savings without risk.

Answer: Start with idle cleanup and non-prod scheduling before risky production downsizing.

### 10. Interview cost line.

Answer: "I optimize cost by measuring first, targeting waste, and protecting reliability."

## Day 27 - Troubleshooting Drill

### 1. Pod OOMKilled.

Answer: Check memory limit, app memory usage, leak, traffic spike. Increase limit only after understanding behavior.

### 2. Terraform state lock stuck.

Answer: Verify no apply running, inspect lock owner, unlock carefully. Prevention: remote locking and team process.

### 3. DNS resolves wrong IP.

Answer: Check record, TTL/cache, hosted zone, split-horizon/private DNS, client resolver.

### 4. IAM denied after role update.

Answer: Check policy propagation, wrong role/session, explicit deny, resource policy.

### 5. DB max connections.

Answer: Check app pool, connection leaks, traffic, DB limit. Fix pooling and scaling.

### 6. CI cannot push image.

Answer: Registry exists, auth, IAM writer role, image name, region. Similar to this repo's GCR/Artifact Registry issue.

### 7. ALB target unhealthy.

Answer: Health path/port, SG, app binding, response code, startup time.

### 8. Node disk pressure.

Answer: Clean images/logs, increase disk, eviction thresholds, monitor.

### 9. API 500 spike.

Answer: Check recent deploy, logs, dependency errors, DB, config/secrets.

### 10. Slow deployment rollout.

Answer: Readiness failing, image pull slow, insufficient nodes, maxSurge/maxUnavailable, startup time.

## Day 28 - Project Story

### 1. Explain this ecommerce project.

Answer: "It is a microservices ecommerce platform deployed with containers, Kubernetes, Terraform, CI/CD, monitoring, and GitOps-style deployment."

### 2. Your role?

Answer: Focus on infra automation, build/deploy pipeline, Kubernetes manifests, cloud setup, observability, and troubleshooting.

### 3. Hardest issue?

Answer: Use real example: Cloud Build pushed to legacy GCR and failed because repository/permission was missing. Fixed by moving to Artifact Registry and adding IAM/repo creation.

### 4. How did you improve reliability?

Answer: Health checks, readiness/liveness probes, rolling updates, resource requests, monitoring, rollback-ready image tags.

### 5. How did you handle secrets?

Answer: Secret manager/external secrets pattern, no hardcoded credentials, IAM-based access.

### 6. How did CI/CD work?

Answer: Build image, tag with commit SHA, push registry, update manifests/deploy, verify health.

### 7. How did Terraform help?

Answer: Provision repeatable GKE/VPC/Cloud SQL/network resources with state and plan review.

### 8. What would you improve?

Answer: Add canary deployments, stronger tests, image scanning, policy checks, SLO dashboards.

### 9. AWS version of project?

Answer: EKS/ECS, ECR, RDS, VPC public/private subnets, ALB, CloudWatch, IAM roles, Terraform.

### 10. Project closing line.

Answer: "This project helped me practice end-to-end DevOps: infra, build, deploy, observe, debug, and secure."

## Day 29 - Mock Interview 1

### 1. Tell me about yourself.

Answer: "I am a DevOps/Cloud Engineer focused on automation, CI/CD, containers, Kubernetes, Terraform, and GCP. I am expanding AWS by mapping equivalent services and practicing production troubleshooting."

### 2. Why switch?

Answer: "I want to work closer to platform reliability, automation, and cloud operations. My project work already aligns with DevOps responsibilities."

### 3. Strongest skill?

Answer: GCP + troubleshooting + automation. Then mention AWS learning bridge.

### 4. Weakness?

Answer: "AWS is newer than GCP for me, but I am closing that gap through service mapping and hands-on labs."

### 5. Explain CI/CD.

Answer: Controlled path from code to production: test, build, scan, push, deploy, verify, rollback.

### 6. Explain Kubernetes.

Answer: Desired-state orchestration for containers with scheduling, self-healing, service discovery, scaling.

### 7. Explain Terraform.

Answer: IaC tool that manages cloud resources declaratively using state and plans.

### 8. Explain AWS VPC.

Answer: Isolated network with subnets, route tables, IGW/NAT, security groups, NACLs.

### 9. Production outage approach.

Answer: Triage impact, communicate, rollback/mitigate, debug with telemetry, postmortem.

### 10. Why hire you?

Answer: "I combine cloud fundamentals, automation mindset, project experience, and structured troubleshooting using VERDICT."

## Day 30 - Final Revision

### 1. Your 30-day summary?

Answer: Linux, Bash, Python, Git, Docker, CI/CD, Kubernetes, Terraform, observability, IAM, AWS/GCP mapping, incidents, security, cost.

### 2. Best project story?

Answer: Use ecommerce CI/CD + Kubernetes + cloud registry fix.

### 3. Best automation story?

Answer: Health check/script/reporting automation with clear before/after impact.

### 4. Best incident story?

Answer: Use symptom, checks, root cause, fix, prevention.

### 5. AWS confidence answer.

Answer: "I map AWS to GCP concepts, then learn AWS-specific IAM/networking differences through labs."

### 6. What salary/role target?

Answer: DevOps/Cloud Engineer role where responsibilities include CI/CD, cloud infra, Kubernetes/containers, monitoring, and automation.

### 7. What if asked unknown question?

Answer: "I have not implemented that directly, but I would debug it by checking identity, network, service health, dependencies, and logs." Then reason.

### 8. Final technical opener?

Answer: "I will first identify the failing layer and confirm with logs/metrics before making changes."

### 9. Final motivation.

Answer: You are not starting from zero. GCP knowledge gives you cloud mental models. AWS is mostly new names plus IAM/networking details.

### 10. Final interview promise.

Answer: "I can operate production systems carefully: automate repetitive work, deploy safely, observe clearly, debug systematically, and improve after incidents."

