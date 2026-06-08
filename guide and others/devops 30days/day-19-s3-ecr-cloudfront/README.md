# Day 19 - S3, ECR, CloudFront

## Target

Understand object storage, registry, and CDN.

## Learn Deeply

- S3 bucket policy.
- Block Public Access.
- Object ownership.
- Versioning.
- Lifecycle.
- KMS encryption.
- ECR image push/pull.
- CloudFront cache behavior and invalidation.

## Hands-On Lab

Map:

```text
GCS -> S3
Artifact Registry -> ECR
Cloud CDN -> CloudFront
```

Write troubleshooting steps for S3 AccessDenied and ECR image pull failure.

## Interview Angle

Say:

```text
For S3 AccessDenied I check IAM policy, bucket policy, block public access, object ownership, and KMS key policy.
```

## AWS/GCP Mapping

S3 and GCS are conceptually close, but AWS bucket policy/object ownership/KMS combinations appear often in interviews.

## Daily Motivation

Storage looks simple until access control and encryption matter. Learn those deeply.

## Practice

Use `interview-question-bank.md` Day 19 questions 1-10.

