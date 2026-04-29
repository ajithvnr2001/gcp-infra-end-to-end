# Mistake Log

Use this whenever you give a weak answer.

## Template

```text
Date:
Question:
My weak answer:
What was missing:
Correct answer:
Command/check I forgot:
AWS/GCP mapping I forgot:
Repeat date:
Status: Open / Fixed
```

## Common Mistakes To Watch

```text
[ ] I answered with only one command.
[ ] I did not mention logs/metrics.
[ ] I did not mention recent change/version.
[ ] I did not explain rollback.
[ ] I overclaimed AWS hands-on.
[ ] I forgot to map GCP to AWS.
[ ] I said "restart" too quickly.
[ ] I missed security/IAM.
[ ] I missed networking.
[ ] I missed prevention.
```

## Example

```text
Date: 2026-04-29
Question: ALB returns 502. How do you debug?
My weak answer: I will check logs and restart backend.
What was missing: target group health, SG, health path, backend port.
Correct answer: I first check ALB target group health. Then verify listener/rule, target port, health check path, security group from ALB to target, backend app logs, and whether app is listening on correct port.
Command/check I forgot: aws elbv2 describe-target-health
AWS/GCP mapping I forgot: ALB target group maps to GCP backend service health.
Repeat date:
Status: Open
```

