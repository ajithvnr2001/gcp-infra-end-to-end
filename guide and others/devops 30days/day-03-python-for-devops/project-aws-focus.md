# Day 03 Project + AWS Focus

## Project Connection

The backend services are Python FastAPI services. Python is also useful for DevOps automation: validating configs, checking endpoints, reading JSON, and calling cloud APIs.

## GCP To AWS Mapping

GCP Python SDK maps to AWS `boto3`. The automation design remains the same:

```text
authenticate -> call API -> handle errors -> log output -> return useful exit code
```

## Project Question

Where can Python automation help this project?

Answer:

```text
It can validate Kubernetes YAML, check service health endpoints, audit image tags, verify Artifact Registry images, generate deployment reports, and compare GCP-to-AWS resource mappings.
```

