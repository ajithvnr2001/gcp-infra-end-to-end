# Day 02 Project + AWS Focus

## Project Connection

This repo uses scripts such as `build.sh`, `setup-gcp.sh`, and rebuild scripts to automate cloud setup and deployment. Bash is used to glue together `gcloud`, `terraform`, `kubectl`, `helm`, and `git`.

## GCP To AWS Mapping

`gcloud` automation maps to `aws` CLI automation. The scripting principles are identical: strict mode, validation, idempotency, readable logs.

AWS equivalent example:

```text
gcloud artifacts repositories create -> aws ecr create-repository
gcloud builds submit -> aws codebuild start-build
```

## Project Question

Why should build scripts create Artifact Registry explicitly?

Answer:

```text
Because relying on implicit registry creation can fail due to missing create-on-push permissions. Explicit creation makes the setup repeatable and interview-safe.
```

