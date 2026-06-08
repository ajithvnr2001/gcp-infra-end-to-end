# Day 20 - AWS Databases

## Target

Understand managed database operations in AWS.

## Learn Deeply

- RDS.
- Aurora.
- Subnet group.
- Security group.
- Multi-AZ.
- Read replica.
- Automated backup.
- DynamoDB keys.
- ElastiCache Redis.

## Hands-On Lab

Write a debug checklist for:

```text
Application cannot connect to RDS
```

Include endpoint, port, SG, subnet, route, credentials, DB state, and connection limits.

## Interview Angle

Say:

```text
For database connectivity I check network path, security group, endpoint, credentials, DB health, and connection limits.
```

## AWS/GCP Mapping

Cloud SQL maps to RDS. Memorystore maps to ElastiCache. Firestore/Bigtable patterns may map partly to DynamoDB depending on access pattern.

## Daily Motivation

You do not need to be a DBA, but you must debug app-to-database reliability.

## Practice

Use `interview-question-bank.md` Day 20 questions 1-10.

