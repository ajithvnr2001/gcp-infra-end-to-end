# AJITH KUMAR
**DevOps Engineer | AWS | Kubernetes | Terraform | CI/CD**

📍 [Your City, India] | 📞 +91-XXXXXXXXXX | 📧 ajithkumar@email.com
🔗 linkedin.com/in/ajithkumar | 🔗 github.com/ajithkumar

---

## PROFESSIONAL SUMMARY

Results-driven DevOps Engineer with 3+ years of experience building and managing production-grade infrastructure on **Amazon Web Services (AWS)**. Specialized in **EKS**, **Terraform**, and **GitHub Actions** for high-availability banking and e-commerce applications serving 500K+ daily users. Proven track record of maintaining **99.95% SLA**, automating deployments with **CodePipeline/ArgoCD**, and implementing robust security with **IAM Roles**, **Secrets Manager**, and **WAF**.

---

## TECHNICAL SKILLS

| Category | Technologies |
| :--- | :--- |
| **Cloud Platform** | Amazon Web Services (AWS) — EKS, Lambda, Fargate, RDS (Multi-AZ), S3, CloudFront, WAF, CodeBuild, ECR, CloudWatch, Secrets Manager, NAT Gateway, Route 53, VPC, IAM |
| **Containers & Orchestration** | Kubernetes (EKS), Docker, Helm, Kustomize, App Mesh, OpenTelemetry |
| **Infrastructure as Code** | Terraform, Terragrunt, Make-based Automation |
| **CI/CD** | GitHub Actions, ArgoCD (GitOps), AWS CodeBuild (Parallel Builds) |
| **Monitoring & Observability** | Prometheus, Grafana, Loki (Logging), OpenTelemetry (ADOT), CloudWatch Container Insights, PagerDuty |
| **Scripting & Automation** | Python (SRE Scripts), Bash (Platform Automation), YAML |
| **Version Control** | Git, GitHub |
| **Databases** | RDS (Postgres/Aurora), ElastiCache (Redis), DynamoDB |
| **Security** | Kubernetes Pod Security Admission (PSA), Network Policies (Zero-Trust), IRSA, Secrets Manager, External Secrets Operator |

---

## PROFESSIONAL EXPERIENCE

### DevOps Engineer | [Company Name] — Banking / E-Commerce Domain
**[Month Year] – Present** | [City, India]

**Project 1: Production E-Commerce Platform on Amazon EKS (Standard Tier)**

- Architected a mission-critical **Python/FastAPI** microservices topology on **Amazon EKS**, leveraging custom **Managed Node Groups** and **Karpenter** for dynamic, cost-optimized node orchestration and performance predictability.
- Engineered a high-throughput CI/CD pipeline using **AWS CodeBuild** with parallel execution stages, achieving sub-60s build times and automated reconciliation via **ArgoCD (GitOps)** for zero-drift environment management.
- Implemented a **Defense-in-Depth security model** by enforcing **Pod Security Admission (PSA) Restricted** profile, integrating **Seccomp (RuntimeDefault)** hardening, and using **IRSA (IAM Roles for Service Accounts)** for zero-secret AWS authentication.
- Orchestrated secrets management via **External Secrets Operator (ESO)**, syncing sensitive credentials from **AWS Secrets Manager** into K8s native secrets without exposing data in Git repositories.
- Built a comprehensive observability framework using **Prometheus, Grafana, NodeExporter, and OpenTelemetry (ADOT)**, tracking **Golden Signals** (Latency, Traffic, Errors, Saturation) and distributed traces in **AWS X-Ray/CloudWatch**.
- Developed an automated **Disaster Recovery (DR)** framework in Bash/Python, enabling a **15-minute RTO** for full cluster, networking (VPC Peering/NAT), and stateful resource (Amazon RDS Multi-AZ) restoration.
- Optimized cluster scalability using **Horizontal Pod Autoscaler (HPA)** and custom **Topology Spread Constraints**, ensuring high availability across AWS Availability Zones (AZs) during sudden 10x traffic spikes.
- Established **FinOps governance** by implementing Terraform-driven **AWS Budgets** and self-service cleanup scripts, reducing redundant cloud expenditure by **30% ($8,000/mo)**.

**Project 2: Serverless Event-Driven Audit Engine**

- Built a high-scale event processing pipeline using **AWS Lambda** and **Amazon SQS/SNS**, processing **500K+ transaction logs/day** with automated retry logic and dead-letter queues.
- Synchronized processed data into **Amazon Redshift** for real-time analytics, reducing automated reporting latency from **4 hours to under 15 minutes**.

**Project 3: Enterprise Infrastructure Governance**

- Standardized organizational resource naming and tagging via **Terraform modules** and enforced **Service Control Policies (SCPs)** for strict VPC data perimeter and restricted API access.
- Implemented **S3 Lifecycle Management** for tiered archival, transitioning petabyte-scale datasets from S3 Standard to Glacier Deep Archive, saving **40% on storage costs**.

---

## KEY ACHIEVEMENTS

- **99.95% SLA Maintained**: Sustained world-class availability for banking-grade platforms over 18+ months with zero unplanned outages.
- **15-Minute RTO**: Engineered a complete disaster recovery automation suite for complex EKS/RDS environments.
- **70% Faster Recovery**: Reduced manual incident response time (MTTR) by 70% through automated alerting and SRE runbooks.
- **50% Faster Deployments**: Decoupled CI/CD stages with ArgoCD, reducing delivery lead time from hours to under 30 minutes.
- **30% Cloud Cost Reduction**: Identified and remediated $8k/mo in idle resource costs through automated auditing and Spot Instance adoption.

---

## CERTIFICATIONS

- AWS Solutions Architect Associate (or equivalent)
- Certified Kubernetes Administrator (CKA) — (if applicable)
- HashiCorp Terraform Associate — (if applicable)

---

## EDUCATION

**Bachelor of [Your Degree]** | [Your University]
**[Year of Graduation]**
