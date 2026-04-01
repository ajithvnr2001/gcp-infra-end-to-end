# AJITH KUMAR
**DevOps Engineer | Azure | Kubernetes | Terraform | CI/CD**

📍 [Your City, India] | 📞 +91-XXXXXXXXXX | 📧 ajithkumar@email.com
🔗 linkedin.com/in/ajithkumar | 🔗 github.com/ajithkumar

---

## PROFESSIONAL SUMMARY

Results-driven DevOps Engineer with 3+ years of experience designing, deploying, and managing production-grade infrastructure on **Microsoft Azure**. Specialized in **AKS**, **Terraform**, and **Azure DevOps Pipelines** for high-availability banking and enterprise applications serving 500K+ daily users. Proven track record of maintaining **99.95% SLA**, building zero-downtime CI/CD pipelines, and implementing robust security with **Entra ID**, **Key Vault**, and **Azure WAF**.

---

## TECHNICAL SKILLS

| Category | Technologies |
| :--- | :--- |
| **Cloud Platform** | Microsoft Azure — AKS, Azure Functions, Azure SQL Database (HA), Blob Storage, Front Door, Azure Firewall, Azure Pipelines, ACR, Azure Monitor, Key Vault, Virtual Network, Entra ID (Azure AD), NAT Gateway |
| **Containers & Orchestration** | Kubernetes (AKS), Docker, Helm, Kustomize, Azure Service Mesh, OpenTelemetry |
| **Infrastructure as Code** | Terraform, Terragrunt, Make-based Automation |
| **CI/CD** | GitHub Actions, ArgoCD (GitOps), Azure Pipelines (Parallel Jobs) |
| **Monitoring & Observability** | Prometheus, Grafana, Loki (Logging), OpenTelemetry, Azure Monitor (App Insights), PagerDuty |
| **Scripting & Automation** | Python (SRE Scripts), Bash (Platform Automation), YAML |
| **Version Control** | Git, Azure Repos, GitHub |
| **Databases** | Azure SQL (PostgreSQL/SQL Server), Azure Cache for Redis, Cosmos DB |
| **Security** | Kubernetes Pod Security Admission (PSA), Network Policies (Zero-Trust), Managed Identities, Azure Key Vault, External Secrets Operator |

---

## PROFESSIONAL EXPERIENCE

### DevOps Engineer | [Company Name] — Banking / Enterprise Domain
**[Month Year] – Present** | [City, India]

**Project 1: Production E-Commerce Platform on Azure Kubernetes Service (AKS)**

- Architected a mission-critical **Python/FastAPI** microservices topology on **AKS**, leveraging custom **System/User Node Pools** and **manual scaling** to optimize resource utilization and performance predictability.
- Engineered a high-throughput CI/CD pipeline using **Azure Pipelines** with parallel execution stages, achieving sub-60s build times and automated reconciliation via **ArgoCD (GitOps)** for zero-drift environment management.
- Implemented a **Defense-in-Depth security model** by enforcing **Pod Security Admission (PSA) Restricted** profile, integrating **Seccomp (RuntimeDefault)** hardening, and using **User-Assigned Managed Identities** for zero-secret Azure authentication.
- Orchestrated secrets management via **External Secrets Operator (ESO)**, syncing sensitive credentials from **Azure Key Vault** into K8s native secrets without exposing data in Git repositories.
- Built a comprehensive observability framework using **Prometheus, Grafana, NodeExporter, and OpenTelemetry**, tracking **Golden Signals** (Latency, Traffic, Errors, Saturation) and distributed traces in **Azure Monitor (App Insights)**.
- Developed an automated **Disaster Recovery (DR)** framework in Bash/Python, enabling a **15-minute RTO** for full cluster, networking (VNET Peering/NAT), and stateful resource (Azure SQL Database) restoration.
- Optimized cluster scalability using **Horizontal Pod Autoscaler (HPA)** and custom **Topology Spread Constraints**, ensuring high availability across Azure Availability Zones during sudden 10x traffic spikes.
- Established **FinOps governance** by implementing Terraform-driven **Azure Cost Management** alerts and self-service cleanup scripts, reducing redundant cloud expenditure by **30% ($8,000/mo)**.

**Project 2: Serverless Event-Driven Audit Engine**

- Built a high-scale event processing pipeline using **Azure Functions (Durable)** and **Azure Service Bus**, processing **500K+ transaction logs/day** with automated retry logic and dead-letter queues.
- Synchronized processed data into **Azure Synapse Analytics** for real-time reporting, reducing automated reporting latency from **4 hours to under 15 minutes**.

**Project 3: Enterprise Infrastructure Governance**

- Standardized organizational resource naming and tagging via **Terraform modules** and enforced **Azure Policy** for strict VNET data perimeter and restricted API access.
- Implemented **Blob Storage Lifecycle Management** for tiered archival, transitioning petabyte-scale datasets from Hot to Cool to Archive, saving **40% on storage costs**.

---

## KEY ACHIEVEMENTS

- **99.95% SLA Maintained**: Sustained world-class availability for banking-grade platforms over 18+ months with zero unplanned outages.
- **15-Minute RTO**: Engineered a complete disaster recovery automation suite for complex AKS/Azure SQL environments.
- **70% Faster Recovery**: Reduced manual incident response time (MTTR) by 70% through automated alerting and SRE runbooks.
- **50% Faster Deployments**: Decoupled CI/CD stages with ArgoCD, reducing delivery lead time from hours to under 30 minutes.
- **30% Cloud Cost Reduction**: Identified and remediated $8k/mo in idle resource costs through automated auditing and Spot VM adoption.

---

## CERTIFICATIONS

- Microsoft Certified: Azure Administrator Associate (AZ-104) — (if applicable)
- Certified Kubernetes Administrator (CKA) — (if applicable)
- HashiCorp Terraform Associate — (if applicable)

---

## EDUCATION

**Bachelor of [Your Degree]** | [Your University]
**[Year of Graduation]**
