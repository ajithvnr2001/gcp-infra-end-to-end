# AJITH KUMAR
**DevOps Engineer | GCP | Kubernetes | Terraform | CI/CD**

📍 [Your City, India] | 📞 +91-XXXXXXXXXX | 📧 ajithkumar@email.com
🔗 linkedin.com/in/ajithkumar | 🔗 github.com/ajithkumar

---

## PROFESSIONAL SUMMARY

Results-driven DevOps Engineer with 3+ years of experience designing, deploying, and managing production-grade infrastructure on **Google Cloud Platform (GCP)**. Specialized in **Kubernetes (GKE)**, **Terraform**, and **GitOps (ArgoCD)** for high-availability banking and fintech applications serving 500K+ daily users. Proven track record of maintaining **99.95% SLA**, reducing deployment times by 50%, and building zero-downtime CI/CD pipelines.

---

## TECHNICAL SKILLS

| Category | Technologies |
| :--- | :--- |
| **Cloud Platform** | Google Cloud Platform (GCP) — GKE (Standard), Cloud Run, Cloud Functions, Cloud SQL (HA), Cloud Storage, Cloud CDN, Cloud Armor, Cloud Build, Artifact Registry, Cloud Monitoring, Cloud Logging, Secret Manager, Cloud NAT, Cloud DNS, VPC, IAM |
| **Containers & Orchestration** | Kubernetes (GKE), Docker, Helm, Kustomize, Istio Service Mesh, OpenTelemetry |
| **Infrastructure as Code** | Terraform, Terragrunt, Makefile-based Automation |
| **CI/CD** | GitHub Actions, ArgoCD (GitOps), Cloud Build (Parallel Pipelines) |
| **Monitoring & Observability** | Prometheus, Grafana, Loki (Logging), OpenTelemetry (Tracing), Cloud Monitoring, PagerDuty |
| **Scripting & Automation** | Python (SRE Scripts), Bash (Platform Automation), YAML |
| **Version Control** | Git, GitHub |
| **Databases** | Cloud SQL (PostgreSQL), Redis (Memorystore), Firestore |
| **Security** | Pod Security Admission (PSA), Network Policies (Zero-Trust), Workload Identity, Secret Manager, External Secrets Operator, Trivy |

---

## PROFESSIONAL EXPERIENCE

### DevOps Engineer | [Company Name] — Banking / Fintech Domain
**[Month Year] – Present** | [City, India]

**Project 1: Production E-Commerce Platform on GKE (Standard Tier)**

- Architected a mission-critical **Python/FastAPI** microservices topology on **GKE Standard (Zonal)**, leveraging custom **e2-standard-2** node pools and **manual bin-packing** to optimize resource utilization and performance predictability.
- Engineered a high-throughput CI/CD pipeline using **GCP Cloud Build** with parallel execution stages, achieving sub-60s build times and automated reconciliation via **ArgoCD (GitOps)** for zero-drift environment management.
- Implemented a **Defense-in-Depth security model** by enforcing **Pod Security Admission (PSA) Restricted** profile, integrating **Seccomp (RuntimeDefault)** hardening, and using **Workload Identity** for zero-secret IAM authentication.
- Orchestrated secrets management via **External Secrets Operator (ESO)**, syncing sensitive credentials from **GCP Secret Manager** into K8s native secrets without exposing data in Git repositories.
- Built a comprehensive observability framework using **Prometheus, Grafana, NodeExporter, and OpenTelemetry (OTel)**, tracking **Golden Signals** (Latency, Traffic, Errors, Saturation) and distributed traces in **Cloud Trace**.
- Developed an automated **Disaster Recovery (DR)** framework in Bash/Python, enabling a **15-minute RTO** for full cluster, networking (VPC Peering/NAT), and stateful resource (Cloud SQL) restoration.
- Optimized cluster scalability using **Horizontal Pod Autoscaler (HPA)** and custom **Topology Spread Constraints**, ensuring high availability across failure domains during sudden 10x traffic spikes.
- Established **FinOps governance** by implementing Terraform-driven budget alerts and self-service cleanup scripts, reducing redundant cloud expenditure by **30% ($8,000/mo)**.

**Project 2: Serverless Event-Driven Audit Engine**

- Built a high-scale event processing pipeline using **Cloud Functions (2nd Gen)** and **Pub/Sub**, processing **500K+ transaction logs/day** with automated retry logic and dead-letter queues.
- Synchronized processed data into **BigQuery** for real-time analytics, reducing automated reporting latency from **4 hours to under 15 minutes**.

**Project 3: Enterprise Infrastructure Governance**

- Standardized organizational resource naming and tagging via **Terraform providers** and enforced **GCP Organization Policies** for strict VPC Service Control and restricted API access.
- Implemented **Cloud Storage Lifecycle Management** for tiered archival, transitioning petabyte-scale datasets from Standard to Coldline/Archive, saving **40% on storage costs**.

---

## KEY ACHIEVEMENTS

- **99.95% SLA Maintained**: Sustained world-class availability for banking-grade platforms over 18+ months with zero unplanned outages.
- **15-Minute RTO**: Engineered a complete disaster recovery automation suite for complex GKE/Cloud SQL environments.
- **70% Faster Recovery**: Reduced manual incident response time (MTTR) by 70% through automated alerting and SRE runbooks.
- **50% Faster Deployments**: Decoupled CI/CD stages with ArgoCD, reducing delivery lead time from hours to under 30 minutes.
- **30% Cloud Cost Reduction**: Identified and remediated $8k/mo in idle resource costs through automated auditing and Spot VM adoption.

---

## CERTIFICATIONS

- Google Cloud Associate Cloud Engineer (or equivalent)
- Certified Kubernetes Administrator (CKA) — (if applicable)
- HashiCorp Terraform Associate — (if applicable)

---

## EDUCATION

**Bachelor of [Your Degree]** | [Your University]
**[Year of Graduation]**
