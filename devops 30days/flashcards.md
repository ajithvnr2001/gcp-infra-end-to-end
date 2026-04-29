# Flashcards - Fast Daily Revision

Use these for 10-minute revision.

## Core DevOps

Q: What is DevOps?
A: DevOps is a culture and engineering practice that improves software delivery through automation, CI/CD, monitoring, collaboration, and reliable operations.

Q: What is CI?
A: Continuous Integration means automatically testing and building code after changes are merged or pushed.

Q: What is CD?
A: Continuous Delivery/Deployment means safely releasing tested artifacts to environments with rollback and verification.

Q: Why immutable image tags?
A: They make deployments traceable and rollback-safe. `latest` is mutable and unclear.

Q: What is rollback?
A: Returning to a previously known-good version of code, image, config, or infrastructure.

## Linux

Q: First checks for slow server?
A: CPU, memory, disk, process, network, logs, recent changes.

Q: Disk full command?
A: `df -h`, `du -sh *`, `find`.

Q: Inode issue command?
A: `df -i`.

Q: Service logs command?
A: `journalctl -u <service> -f`.

Q: Find port user?
A: `ss -lntp` or `lsof -i :<port>`.

## Bash/Python

Q: Why `set -euo pipefail`?
A: Fails fast on errors, undefined variables, and failed pipeline commands.

Q: Bash vs Python?
A: Bash for simple command glue; Python for APIs, JSON, complex logic, retries, and maintainability.

Q: Python subprocess safe pattern?
A: `subprocess.run([...], check=True, capture_output=True, text=True)`.

Q: Script idempotency?
A: Script can run multiple times safely without duplicate or destructive side effects.

## Docker

Q: Image vs container?
A: Image is packaged template; container is running instance.

Q: Docker build fails?
A: Read exact failing layer, check Dockerfile, base image, dependencies, network, disk.

Q: Image too large?
A: Use slim base, multi-stage builds, `.dockerignore`, remove caches.

Q: CMD vs ENTRYPOINT?
A: ENTRYPOINT defines executable; CMD provides default arguments.

Q: ImagePullBackOff?
A: Wrong image/tag, registry permission, missing repo, auth, network.

## Kubernetes

Q: Pod CrashLoopBackOff?
A: App crashes repeatedly. Check logs, previous logs, describe, env/secrets, resources.

Q: Pod Pending?
A: Scheduler cannot place pod. Check resources, taints, selectors, PVC, quota.

Q: Readiness vs liveness?
A: Readiness controls traffic; liveness restarts unhealthy containers.

Q: Service has no endpoints?
A: Selector labels mismatch or pods are not ready.

Q: Rollback deployment?
A: `kubectl rollout undo deployment/<name> -n <ns>`.

## Terraform

Q: Terraform state?
A: Mapping between Terraform config and real infrastructure.

Q: Drift?
A: Real infra differs from config/state.

Q: Remote backend?
A: Shared state, locking, team safety.

Q: Unexpected destroy?
A: Stop, inspect plan, variables, state, provider/module changes.

## AWS/GCP Mapping

Q: GKE maps to?
A: EKS.

Q: Artifact Registry maps to?
A: ECR.

Q: Cloud Build maps to?
A: CodeBuild, often with CodePipeline.

Q: Cloud SQL maps to?
A: RDS/Aurora.

Q: Cloud Monitoring maps to?
A: CloudWatch Metrics/Alarms.

Q: Cloud Audit Logs maps to?
A: CloudTrail.

Q: GCP service account maps to?
A: AWS IAM Role.

Q: Cloud NAT maps to?
A: NAT Gateway.

Q: GCP firewall rules map to?
A: Security Groups and NACLs.

## AWS

Q: IAM trust policy?
A: Defines who can assume a role.

Q: IAM permission policy?
A: Defines what actions/resources the role can access.

Q: Public subnet?
A: Subnet with default route to Internet Gateway.

Q: Private subnet?
A: Subnet without direct internet route; usually outbound through NAT Gateway.

Q: Security Group vs NACL?
A: SG is stateful resource-level; NACL is stateless subnet-level.

Q: ECS task execution role?
A: Pulls ECR image, writes logs, reads startup secrets.

Q: ECS task role?
A: App's AWS API permissions.

Q: CloudWatch vs CloudTrail?
A: CloudWatch is logs/metrics/alarms; CloudTrail is API audit.

