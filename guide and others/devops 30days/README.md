# DevOps 30 Days - Python, Scripting, AWS, GCP Interview Track

Role target: DevOps / Cloud Engineer with 2.5 to 3 years experience.

Primary advantage: you are GCP-native. This plan teaches AWS by mapping it to GCP concepts, then trains interview answers with the same scenario style as the Docker prep file.

## How To Use This Folder

Daily time requirement: 2.5 to 3.5 hours.

Daily flow:
1. Open the matching `day-XX-*` folder and read its `README.md`.
2. Read that day's `project-aws-focus.md` to connect the topic to your ecommerce GCP project and AWS mapping.
3. Learn the AWS-for-GCP mapping from `aws-for-gcp-native.md`.
4. Do the lab from that day's folder.
5. Practice that day's 10 questions in `interview-question-bank.md` out loud.
6. Use `verdict-framework.md` for every scenario answer.
7. Update `daily-tracker.md`.
8. End the day by writing one incident-style note: symptom, checks, root cause, fix, prevention.

## VERDICT Framework

Use this for every interview answer:

```text
V - Version: What changed? Which runtime/tool/image/API version?
E - Environment: Local, CI, staging, prod, one region, one account/project?
R - Resources: CPU, memory, disk, network quota, IAM quota, cost pressure?
D - Dependencies: DB, registry, DNS, secrets, APIs, third-party services?
I - Infra health: Nodes, cluster, VPC, load balancer, NAT, service health?
C - Connectivity: DNS, ports, security groups/firewalls, routes, IAM auth?
T - Telemetry: Logs, metrics, traces, events, audit logs, exact error?
```

5-second opener:

```text
I will first identify the failing layer: code, container, CI/CD, network, IAM, or cloud service. Then I will verify the exact error from logs and compare what changed.
```

## Files

- `day-01-*` to `day-30-*` - separate in-depth folder for each day.
- Each daily folder contains `README.md` and `project-aws-focus.md`.
- `daily-plan.md` - 30-day learning schedule with tasks, labs, motivation, and outcomes.
- `aws-for-gcp-native.md` - AWS concepts explained through GCP equivalents.
- `project-deep-dive-interview-ready.md` - detailed explanation of your current GCP ecommerce project.
- `gcp-project-to-aws-mapping.md` - maps this exact project from GCP to AWS.
- `aws-question-response-playbook.md` - safe answers when interviewers ask AWS questions.
- `interview-question-bank.md` - 10 scenario interview questions per day with VERDICT-style answers.
- `verdict-framework.md` - reusable answer templates and interview speaking structure.
- `daily-tracker.md` - checklist and confidence tracker.
- `resume-interview-stories.md` - resume bullets and project-story templates.
- `resume-bullets-final.md` - polished resume bullets for DevOps/Cloud Engineer applications.
- `mock-interview-scorecard.md` - scoring rubric for mock interviews.
- `last-3-days-rapid-revision.md` - final interview revision checklist and top scenarios.
- `daily-labs-index.md` - practical lab task index for all 30 days.
- `aws-mini-project-plan.md` - 7-day AWS mini-project plan mapped from your GCP ecommerce platform.
- `cheatsheets/` - quick revision sheets for Linux, Kubernetes, Terraform, AWS, and AWS-GCP mapping.
- `flashcards.md` - fast Q&A memory revision.
- `hr-behavioral-interview.md` - HR and behavioral answer templates.
- `mistake-log.md` - track weak answers and corrected versions.
- `final-one-page-interview-sheet.md` - final 30-minute pre-interview sheet.
- `round-1-screening.md` to `round-4-managerial.md` - round-wise interview preparation.
- `labs/` - runnable starter labs and templates.

## Recommended Learning Order

For each day:

1. Daily folder `README.md`.
2. Daily folder `project-aws-focus.md`.
3. Relevant section from `interview-question-bank.md`.
4. Relevant cheat sheet if needed.
5. Update `daily-tracker.md`.

After day 30:

1. Complete `aws-mini-project-plan.md`.
2. Revise `last-3-days-rapid-revision.md`.
3. Practice with `mock-interview-scorecard.md`.
4. Finalize resume using `resume-bullets-final.md`.
5. Use `final-one-page-interview-sheet.md` before interviews.
6. Track weak answers in `mistake-log.md`.

## Daily Folders

- `day-01-linux-basics`
- `day-02-bash-scripting`
- `day-03-python-for-devops`
- `day-04-git-release-workflow`
- `day-05-docker-build-runtime`
- `day-06-docker-compose-local-dev`
- `day-07-week-1-mock`
- `day-08-cicd-fundamentals`
- `day-09-kubernetes-basics`
- `day-10-kubernetes-networking`
- `day-11-terraform-fundamentals`
- `day-12-observability`
- `day-13-secrets-and-iam`
- `day-14-week-2-mock`
- `day-15-aws-iam-for-gcp-native`
- `day-16-aws-vpc-for-gcp-native`
- `day-17-ec2-asg-ebs`
- `day-18-alb-route53`
- `day-19-s3-ecr-cloudfront`
- `day-20-aws-databases`
- `day-21-ecs-eks-fargate`
- `day-22-aws-monitoring-audit`
- `day-23-multicloud-mapping`
- `day-24-production-incidents`
- `day-25-security-basics`
- `day-26-cost-optimization`
- `day-27-troubleshooting-drill`
- `day-28-project-story-prep`
- `day-29-mock-interview`
- `day-30-final-revision-switch-plan`

## Weekly Outcomes

Week 1: Linux, shell, Python automation, Git, Docker basics.

Week 2: CI/CD, Kubernetes, Terraform, monitoring, secrets.

Week 3: AWS from a GCP-native view: IAM, VPC, EC2, ALB, ECS/EKS, RDS, S3, CloudWatch.

Week 4: Production scenarios, incident debugging, cost, security, multi-cloud interview readiness.

Final 2 days: mock interviews, project storytelling, resume-ready answers.
