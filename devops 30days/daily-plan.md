# 30-Day DevOps / Cloud Engineer Learning Plan

Target: switch as fast as possible into DevOps/Cloud Engineer interviews for 2.5 to 3 years experience.

Daily rule: learn one concept, do one command/lab, answer 10 questions out loud.

## Day 1 - Linux, Terminal, Process Basics

Goal: become comfortable explaining Linux as the base of DevOps.

Learn:
- Filesystem paths, permissions, process, service, logs.
- Commands: `ls`, `cd`, `find`, `grep`, `ps`, `top`, `df`, `du`, `chmod`, `chown`, `systemctl`, `journalctl`.

Lab:
- Find top 5 largest files in a folder.
- Check running processes and explain PID, CPU, memory.
- Write a one-page incident note: "Server disk is full."

Motivation:
You do not need to know every Linux command. You need to know how to inspect, reason, and recover.

Interview outcome:
Explain Linux debugging without panic.

## Day 2 - Bash Scripting

Goal: automate repetitive checks.

Learn:
- Variables, arguments, exit codes, `if`, `for`, functions, `set -euo pipefail`.
- Log file parsing with `grep`, `awk`, `sed`.

Lab:
- Create a script that checks disk, memory, CPU, and service status.
- Add readable output and non-zero exit when disk is above 80%.

Motivation:
A DevOps engineer is a person who turns repeated manual work into safe automation.

Interview outcome:
Explain how you write production-safe scripts.

## Day 3 - Python For DevOps

Goal: use Python for automation, APIs, JSON, files, and cloud scripts.

Learn:
- `pathlib`, `json`, `subprocess`, `requests`, exceptions, logging.

Lab:
- Write a Python script that reads a JSON list of services and prints unhealthy services.
- Add error handling and logging.

Motivation:
Python is not for showing syntax skill. It is for reducing operational effort.

Interview outcome:
Explain when Python is better than Bash.

## Day 4 - Git And Release Workflow

Goal: understand code flow from branch to deployment.

Learn:
- Branching, commits, PRs, tags, semantic commit messages, rollback.

Lab:
- Create a branch, make a small change, inspect `git diff`, and write a release note.

Motivation:
Interviewers trust candidates who understand change control.

Interview outcome:
Explain how a change safely reaches production.

## Day 5 - Docker Build And Runtime

Goal: master image build, runtime, logs, networking, volumes.

Learn:
- Dockerfile, layers, cache, `.dockerignore`, `docker logs`, `docker inspect`, ports.

Lab:
- Build a small Python app image.
- Run it with env vars and port mapping.

Motivation:
Containers are just packaging plus runtime isolation. Keep the mental model simple.

Interview outcome:
Debug image build and container crash scenarios.

## Day 6 - Docker Compose And Local Dev

Goal: run multi-service stacks locally.

Learn:
- Compose services, networks, volumes, health checks.

Lab:
- Run app + database in Compose.
- Break DB env var and debug the failure.

Motivation:
Breaking things intentionally is the fastest way to learn debugging.

Interview outcome:
Explain service-to-service networking in local containers.

## Day 7 - Week 1 Revision And Mock

Goal: connect Linux, Bash, Python, Git, Docker.

Lab:
- Build a script that checks Docker container health and prints logs for failed containers.

Motivation:
Your first week foundation is enough to answer many real interview questions.

Interview outcome:
Give one end-to-end story: "I automated health checks and improved debugging."

## Day 8 - CI/CD Fundamentals

Goal: understand pipelines and why they fail.

Learn:
- Build, test, scan, push, deploy, rollback.
- Pipeline variables, secrets, artifacts, cache.

Lab:
- Draw a CI/CD pipeline for this ecommerce repo.

Motivation:
CI/CD is change safety, not just YAML.

Interview outcome:
Explain pipeline failure debugging.

## Day 9 - Kubernetes Basics

Goal: understand Pod, Deployment, Service, ConfigMap, Secret.

Learn:
- `kubectl get/describe/logs`, labels, selectors, rollout.

Lab:
- Explain one deployment YAML from this repo line by line.

Motivation:
Kubernetes becomes easier when you treat it as desired state plus controllers.

Interview outcome:
Debug CrashLoopBackOff, ImagePullBackOff, and Service routing.

## Day 10 - Kubernetes Networking

Goal: understand ClusterIP, NodePort, LoadBalancer, Ingress, DNS.

Learn:
- Service endpoints, kube-dns, ingress controller.

Lab:
- Trace request path: user -> ingress -> service -> pod.

Motivation:
Most Kubernetes problems are labels, ports, DNS, or readiness.

Interview outcome:
Explain why pod works but service is unreachable.

## Day 11 - Terraform Fundamentals

Goal: understand IaC and state.

Learn:
- Provider, resource, variable, output, backend, plan/apply/destroy.

Lab:
- Read a Terraform module and identify inputs/outputs/state.

Motivation:
Terraform skill is not writing resources only. It is managing change safely.

Interview outcome:
Explain state locking, drift, and safe apply.

## Day 12 - Observability

Goal: logs, metrics, traces, alerts.

Learn:
- Golden signals: latency, traffic, errors, saturation.
- Prometheus, Grafana, Cloud Logging, CloudWatch.

Lab:
- Design dashboard for API service.

Motivation:
If you cannot observe it, you cannot operate it.

Interview outcome:
Explain how to debug high latency.

## Day 13 - Secrets And IAM

Goal: manage credentials safely.

Learn:
- Secret Manager, AWS Secrets Manager, IAM least privilege, service accounts/roles.

Lab:
- Compare GCP service account with AWS IAM role.

Motivation:
Security maturity is a strong differentiator at 3 years experience.

Interview outcome:
Explain why static keys are risky.

## Day 14 - Week 2 Revision And Mock

Goal: Kubernetes + Terraform + CI/CD story.

Lab:
- Create a production deployment checklist.

Motivation:
Good engineers do not rely on memory during production changes. They use checklists.

Interview outcome:
Answer one full scenario: "Deployment failed after CI/CD rollout."

## Day 15 - AWS IAM For GCP Native

Goal: understand AWS identities fast.

Learn:
- IAM users, groups, roles, policies, STS, instance profile, OIDC.

Lab:
- Map GCP service accounts to AWS roles.

Motivation:
AWS IAM looks hard because names differ. The security ideas are the same.

Interview outcome:
Explain role assumption and least privilege.

## Day 16 - AWS VPC For GCP Native

Goal: understand AWS networking.

Learn:
- VPC, subnet, route table, IGW, NAT Gateway, SG, NACL.

Lab:
- Draw public and private subnet architecture.

Motivation:
Networking interviews reward clear diagrams and exact traffic flow.

Interview outcome:
Debug EC2 private instance cannot reach internet.

## Day 17 - EC2, AMI, EBS, Auto Scaling

Goal: understand VM operations in AWS.

Learn:
- EC2 lifecycle, AMI, EBS, user data, ASG, launch template.

Lab:
- Compare Compute Engine MIG with AWS Auto Scaling Group.

Motivation:
VMs still run a lot of production systems. Know the basics well.

Interview outcome:
Debug instance unhealthy in ASG.

## Day 18 - AWS Load Balancing And Route 53

Goal: understand traffic entry.

Learn:
- ALB vs NLB, target groups, health checks, Route 53 records.

Lab:
- Trace request: DNS -> ALB -> target group -> EC2/ECS.

Motivation:
Traffic debugging is one of the most common cloud interview areas.

Interview outcome:
Debug ALB 502/503.

## Day 19 - S3, ECR, CloudFront

Goal: understand storage, registry, CDN.

Learn:
- S3 bucket policy, lifecycle, versioning, ECR push/pull, CloudFront caching.

Lab:
- Compare GCS + Artifact Registry + Cloud CDN with S3 + ECR + CloudFront.

Motivation:
Object storage is simple until access, encryption, and lifecycle matter.

Interview outcome:
Debug S3 AccessDenied and ECR image pull failures.

## Day 20 - RDS, DynamoDB, ElastiCache

Goal: understand AWS data services.

Learn:
- RDS subnet groups, backups, Multi-AZ, read replicas, DynamoDB keys, Redis cache.

Lab:
- Compare Cloud SQL with RDS and Memorystore with ElastiCache.

Motivation:
Cloud engineers must know enough database operations to avoid bad infra decisions.

Interview outcome:
Debug app cannot connect to RDS.

## Day 21 - AWS Containers: ECS, EKS, Fargate

Goal: understand container choices in AWS.

Learn:
- ECS task/service, task execution role, EKS node group, Fargate.

Lab:
- Decide ECS vs EKS for a microservice app and justify.

Motivation:
You are not learning AWS to memorize services. You are learning how to choose tradeoffs.

Interview outcome:
Explain ECS task stuck in stopped/pending.

## Day 22 - AWS Monitoring And Audit

Goal: operate AWS production systems.

Learn:
- CloudWatch Logs/Metrics/Alarms, CloudTrail, VPC Flow Logs.

Lab:
- Design AWS observability for a 3-tier app.

Motivation:
The fastest debug path is always telemetry first.

Interview outcome:
Explain how to find who changed a security group.

## Day 23 - Multi-Cloud Mapping Day

Goal: speak GCP and AWS together confidently.

Learn:
- Service equivalence, architecture tradeoffs, IAM differences, network differences.

Lab:
- Convert a GCP architecture into AWS architecture.

Motivation:
Your GCP strength becomes your AWS learning accelerator.

Interview outcome:
Answer "You know GCP, how will you work in AWS?"

## Day 24 - Production Incident Handling

Goal: handle outages like an engineer.

Learn:
- Severity, triage, rollback, communication, postmortem.

Lab:
- Write a postmortem for "API latency increased after deployment."

Motivation:
Companies hire people who stay calm under production pressure.

Interview outcome:
Explain incident response end to end.

## Day 25 - Security And Compliance Basics

Goal: answer practical cloud security questions.

Learn:
- IAM least privilege, network segmentation, encryption, secrets, audit, patching.

Lab:
- Create a security checklist for Kubernetes and AWS.

Motivation:
Security is not a separate job. It is part of every DevOps decision.

Interview outcome:
Explain secure CI/CD and secret handling.

## Day 26 - Cost Optimization

Goal: understand cloud cost controls.

Learn:
- Right sizing, autoscaling, committed use/savings plans, storage lifecycle, idle resources.

Lab:
- Create cost optimization plan for dev/staging/prod.

Motivation:
Engineers who save money without hurting reliability are valuable.

Interview outcome:
Explain reducing cloud bill by 20%.

## Day 27 - Real-Time Troubleshooting Drill

Goal: fast diagnosis using VERDICT.

Lab:
- Practice 10 random failures: pod crash, ALB 502, CI fail, disk full, DB timeout, DNS fail, IAM denied, image pull fail, high CPU, Terraform drift.

Motivation:
Speed comes from repeated patterns, not memorization.

Interview outcome:
Answer scenario questions smoothly.

## Day 28 - Project Story Preparation

Goal: convert this ecommerce project into interview stories.

Prepare stories:
- CI/CD pipeline.
- Kubernetes deployment.
- Terraform infra.
- Observability.
- Cloud migration or AWS learning from GCP.

Motivation:
Interviews are won by clear stories with measurable impact.

Interview outcome:
Answer "Tell me about your project" with confidence.

## Day 29 - Mock Interview 1

Goal: simulate real interview.

Rules:
- 45 minutes.
- 5 Linux/Python questions.
- 5 Docker/Kubernetes questions.
- 5 AWS/GCP questions.
- 5 scenario questions.

Motivation:
Record yourself. Weak answers become obvious when you listen back.

Interview outcome:
Identify gaps and fix them.

## Day 30 - Final Revision And Switch Plan

Goal: be interview-ready.

Tasks:
- Revise all question banks.
- Polish resume bullets.
- Prepare 3 project stories.
- Prepare 3 incident stories.
- Prepare 3 automation stories.

Motivation:
Switching roles is not about knowing everything. It is about proving you can operate, debug, automate, and learn fast.

Interview outcome:
Clear 2.5-3 year DevOps/Cloud Engineer positioning.

