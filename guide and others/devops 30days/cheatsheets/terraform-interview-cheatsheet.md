# Terraform Interview Cheat Sheet

## Core Terms

Provider:

```text
Plugin that talks to cloud API.
```

Resource:

```text
Cloud object managed by Terraform.
```

State:

```text
Mapping between Terraform config and real resources.
```

Plan:

```text
Preview of changes and blast radius.
```

Module:

```text
Reusable infrastructure component.
```

## Strong Interview Lines

```text
I treat terraform plan as a change review artifact.
```

```text
Remote state and locking are required for team usage.
```

```text
Unexpected destroy in plan is a stop condition.
```

## Common Questions

State drift:

```text
Real infrastructure differs from Terraform state/config. Detect with plan and fix through config/import/revert.
```

Secrets:

```text
Avoid hardcoding secrets. Protect state because sensitive values can appear there.
```

Count vs for_each:

```text
for_each gives stable identity by key; count index changes can cause unwanted recreation.
```

