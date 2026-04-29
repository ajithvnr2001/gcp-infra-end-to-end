# AWS Question Response Playbook For A GCP-Native Candidate

Use this when an interviewer asks AWS questions and your direct project is GCP.

## Honest But Strong Opener

```text
My hands-on project is GCP-native, but I map it directly to AWS service equivalents. The cloud layers are the same: IAM, network, compute, registry, CI/CD, database, observability, and security. I will answer using the AWS equivalent and call out AWS-specific differences like IAM roles and VPC route tables.
```

## If Asked: "You used GCP only. Can you work on AWS?"

Strong answer:

```text
Yes. My GCP experience gives me the cloud operating model: VPC networking, IAM, Kubernetes, container registry, CI/CD, managed SQL, monitoring, and audit logs. In AWS I map those to VPC, IAM Roles, EKS/ECS, ECR, CodeBuild/CodePipeline, RDS, CloudWatch, and CloudTrail. The main AWS-specific areas I focus on are IAM role assumption, security groups/NACLs, route tables, NAT Gateway, ALB target groups, and ECR/ECS/EKS integrations.
```

## If Asked: "Explain AWS VPC."

Answer:

```text
AWS VPC is an isolated network boundary. Inside it we create subnets across Availability Zones. Public subnets have a default route to an Internet Gateway. Private subnets use a NAT Gateway for outbound internet. Security Groups are stateful firewalls attached to resources, while NACLs are stateless subnet-level rules. Route tables control traffic path at subnet level.
```

GCP mapping:

```text
This maps to GCP VPC, subnets, routes, firewall rules, and Cloud NAT. The difference is AWS route tables are explicitly associated with subnets and AWS uses Security Groups heavily.
```

## If Asked: "Explain AWS IAM Role."

Answer:

```text
An IAM role is an assumable identity that gives temporary credentials. A trust policy defines who can assume it, and a permission policy defines what it can do. For workloads, roles are preferred over static keys.
```

GCP mapping:

```text
The closest GCP equivalent is a service account. In AWS, role assumption through STS is a key concept.
```

## If Asked: "ECS vs EKS?"

Answer:

```text
EKS is managed Kubernetes and is best when the team needs Kubernetes APIs, manifests, operators, or portability. ECS is AWS-native container orchestration and is simpler operationally, especially with Fargate. For my current Kubernetes-based project, EKS is the direct migration path. For lower operational overhead, ECS Fargate is a good alternative.
```

## If Asked: "How Would Your GCP Project Look On AWS?"

Answer:

```text
Frontend, API gateway, catalog, cart, and payment services would be containerized and pushed to ECR. For Kubernetes continuity, I would run them on EKS with ALB Ingress. Terraform would provision VPC, public/private subnets, NAT Gateway, EKS, RDS, IAM roles, and security groups. CodeBuild or GitHub Actions would build/push images, ArgoCD would sync manifests, CloudWatch would collect logs/metrics, CloudTrail would audit changes, and Secrets Manager would store secrets.
```

## AWS Scenario Answer Templates

### ALB 502

```text
I would check target group health first. Then verify app port, health check path, security group from ALB to target, container logs, and whether the app is listening on the expected interface and port. If target health is failing, ALB is usually fine; the backend or connectivity is the issue.
```

### ECS Task Stopped

```text
I would check the ECS stopped reason, container exit code, CloudWatch logs, task definition env/secrets, CPU/memory, ECR image pull, and execution role permissions. Execution role is for pulling image/logging/secrets, task role is for application AWS API access.
```

### EKS Pod Cannot Pull ECR Image

```text
I would check image name/tag, ECR repo region/account, node/pod IAM pull permissions, network path to ECR/NAT/VPC endpoints, and Kubernetes pod events. This is similar to Artifact Registry pull issues in GKE.
```

### RDS Connection Timeout

```text
I would check RDS status, endpoint, port, app security group to RDS security group, subnet routing, public/private setting, NACL, credentials, and DB connection limits. Timeout usually points to network/security group; auth failure points to credentials.
```

### S3 AccessDenied

```text
I would check IAM identity policy, bucket policy, block public access, object ownership, ACLs if used, KMS key policy, and whether the request is going to the correct account and region.
```

## Interview Rule

Do not say "I only know GCP." Say:

```text
I implemented this in GCP, and here is how I would map and operate it in AWS.
```

