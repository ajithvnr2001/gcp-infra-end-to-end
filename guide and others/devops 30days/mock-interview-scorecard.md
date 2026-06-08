# Mock Interview Scorecard

Use this every 3 days. Record yourself answering 10 questions and score honestly.

## Scoring Scale

```text
1 - Weak: unclear, guessed, no structure
2 - Basic: some correct points, but shallow
3 - Interview acceptable: clear, mostly correct, some depth
4 - Strong: structured, practical, commands/checks included
5 - Excellent: production-ready answer with tradeoffs, prevention, and AWS/GCP mapping
```

## Scorecard

| Area | Score 1-5 | Notes | Fix Before Next Mock |
|---|---:|---|---|
| Technical clarity | | | |
| VERDICT structure | | | |
| Linux/debugging confidence | | | |
| Bash/Python automation | | | |
| Docker/Kubernetes depth | | | |
| Terraform/IaC depth | | | |
| CI/CD explanation | | | |
| GCP project explanation | | | |
| AWS mapping from GCP | | | |
| Incident handling | | | |
| Security/cost awareness | | | |
| Communication under pressure | | | |

## Answer Quality Checklist

Before calling an answer strong, confirm it has:

```text
[ ] Clear first sentence
[ ] Failing layer identified
[ ] VERDICT used where relevant
[ ] Exact commands or cloud checks
[ ] Likely root causes
[ ] Fix
[ ] Prevention
[ ] AWS/GCP mapping if cloud question
[ ] No overclaiming
[ ] No panic wording
```

## Red Flags To Remove

Avoid these phrases:

```text
I will just restart it.
I have only worked on GCP, not AWS.
I don't know.
Maybe it is network issue.
I will check everything.
I used Kubernetes but not sure how it works internally.
```

Replace with:

```text
I would first isolate the failing layer.
My hands-on project is GCP, and I map the equivalent AWS services this way.
I have not implemented that exact service, but I know how I would debug it.
I would validate whether it is network by checking route, firewall/security group, DNS, and target health.
```

## Weekly Mock Plan

Day 7:

- Linux, Bash, Python, Docker, Git.

Day 14:

- CI/CD, Kubernetes, Terraform, observability, IAM.

Day 21:

- AWS IAM, VPC, EC2, ALB, S3/ECR, RDS, ECS/EKS.

Day 29:

- Full mixed mock with project deep dive and incident story.

## Final Interview Readiness Target

You are ready when:

```text
[ ] You can explain the project in 30 seconds, 2 minutes, and 5 minutes.
[ ] You can map every GCP component to AWS.
[ ] You can answer unknown AWS questions without freezing.
[ ] You can give 3 incident stories.
[ ] You can explain rollback, monitoring, and security for every deployment.
[ ] You can answer 50 random questions with VERDICT structure.
```

