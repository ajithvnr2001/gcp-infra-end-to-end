# Master Architecture Reference: Enterprise E-Commerce Platform

This document serves as the high-level technical authority for the platform's architecture. It is designed to facilitate deep-dive discussions during Principal/Lead Engineer interviews, focusing on **Reliability, Security, Scalability, and Operational Excellence**.

---

## 🏗️ 1. Infrastructure Architecture & Governance (IaC)
**Core Stack**: Terraform Cloud/CLI, Google Cloud Platform (GCP)

### Micro-Segmented Network Topology
-   **VPC Design**: A custom-tier VPC with a `/20` subnet for the production environment, ensuring zero-overlap with other projects.
-   **Private Environment (Cloud NAT)**: The GKE cluster operates with **Private Nodes**. All outbound traffic for third-party APIs (Payment Gateways, etc.) is tunneled through **Cloud NAT** with dedicated IPs for IP-white-listing compatibility.
-   **VPC Peering & Service Networking**: We leverage the `servicenetworking.googleapis.com` API to create a private peering range (`10.102.0.0/16`) for our **Cloud SQL PostgreSQL** instance, ensuring database traffic never traverses the public internet.

### GKE Standard Tier vs. Autopilot Rationale
We utilize **GKE Standard (Zonal)** to maintain absolute control over the data plane:
-   **Node Orchestration**: Custom `e2-standard-2` node pools allow for precise resource bin-packing and preemption strategies.
-   **Advanced Kubelet Config**: Ability to tune `max-pods-per-node` and `log-level` which is restricted in Autopilot.
-   **Custom Mutating Webhooks**: Standard tier allows us to run specialized admission controllers (like the OTel Sidecar Injector) without abstraction limitations.

---

## 🛡️ 2. Zero-Trust Security & Compliance Matrix

### Identity: GKE Workload Identity Deep-Dive
Operating on a **Zero-Secret principle**, we use Workload Identity to bridge Kubernetes and GCP IAM:
1.  **K8s Service Account (KSA)**: Created in the `ecommerce` namespace.
2.  **GCP Service Account (GSA)**: Created with least-privilege IAM roles (e.g., `roles/cloudsql.client`).
3.  **Mapping**: We annotate the KSA with the GSA email and grant the `roles/iam.workloadIdentityUser` role.
4.  **Result**: Pods receive an ephemeral OIDC token via the metadata server, authenticated directly by GCP APIs—no static JSON keys needed.

### Data Protection: External Secrets & KMS
To prevent "Secret Sprawl" in Git:
-   **Encrypted-at-Rest**: Secrets are stored in **GCP Secret Manager**.
-   **Runtime Injection**: The **External Secrets Operator (ESO)** monitors a `SecretStore` resource. It periodically fetches the secret from GCP and creates a native K8s Secret in the `ecommerce` namespace.
-   **Encapsulation**: Developers only committed `ExternalSecret` manifests (pointers), never actual credentials.

### PodSecurity Admission (PSA) "Restricted" Profile
We enforce the highest level of cluster hardening:
-   **Seccomp Profiles**: All workloads are restricted to `RuntimeDefault`, preventing potential container breakouts via system call filtering.
-   **Forbidden Privileges**: `allowPrivilegeEscalation: false` and `runAsNonRoot: true` are mandatory.
-   **Read-Only Filesystem**: Backend services (Catalog, Cart) use `readOnlyRootFilesystem: true` with ephemeral `emptyDir` mounts for temporary scratch space.

---

## 🔄 3. CI/CD & GitOps Distribution (Continuous Delivery)

### Parallel High-Performance Builds
-   **Google Cloud Build**: Leverages parallel execution steps to build 5 unique Docker images simultaneously.
-   **Multi-Stage Dockerfiles**: We utilize multi-stage builds to produce "Distroless" or Alpine-based lean images, reducing the image size by ~70% and minimizing the vulnerability surface area.
-   **Artifact Registry**: Images are stored with immutable tags, and we leverage **GKE Binary Authorization** (conceptually) to ensure only signed/scanned images run in production.

### ArgoCD: Continuous Reconciliation
We implement the **"App-of-Apps"** pattern for GitOps:
-   **Self-Healing**: If a configuration drift is detected (e.g., someone manually edits a LoadBalancer), ArgoCD triggers a `Sync` to restore the Git state.
-   **Blue/Green & Canary Capability**: The architecture is set up to support progressive delivery using **Argo Rollouts** (extension ready).

---

## 📊 4. Observability & Site Reliability Engineering (SRE)

### Metrics: kube-prometheus-stack
-   **Service Discovery**: Prometheus automatically scrapes any pod annotated with `prometheus.io/scrape: "true"`.
-   **Golden Signals**: We track Latency, Traffic, Errors, and Saturation (LTES).
-   **Node-Level Health**: `NodeExporter` provides visibility into I/O wait times and disk pressure, critical for database-heavy microservices.

### Distributed Tracing: OpenTelemetry (OTel)
-   **OTel Collector Sidecar**: Spans are collected at the application layer and forwarded to an in-cluster OTel Collector.
-   **Export Pipeline**: The collector exports traces to **GCP Cloud Trace**, providing a single pane of glass for long-tail latency analysis.

---

## 🚑 5. Resilience & High Availability (HA)

### Fault Tolerance
-   **HPA (Horizontal Pod Autoscaling)**: Backend services scale horizontally based on CPU utilization (threshold 70%).
-   **Topology Spread Constraints**: We use `topologySpreadConstraints` to ensure pods of the same service are spread across different nodes and zones, preventing entire-service downtime during a node failure.
-   **Pod Disruption Budgets (PDB)**: Enforced to ensure a minimum number of replicas are available during planned maintenance or node upgrades.

### Disaster Recovery (DR)
-   **Automated Re-Bootstrapping**: The `nuke-and-rebuild.sh` script provides a **Self-Service DR** capability. 
-   **RTO**: 15 Minutes to full restoration of Global VPC, Regional Cloud SQL, Zonal GKE, and GitOps Layer.
-   **RPO**: State is recovered via Cloud SQL Point-in-Time Recovery (PITR) and Git history.

---

## 🎯 The "Lead Engineer" Final Word
"Our architecture isn't just about running containers; it's about **Systemic Integrity**. By combining **GitOps for consistency**, **Workload Identity for security**, and **OTel for visibility**, we created a platform that treats infrastructure as a disposable, highly-reproducible asset. This allows our developers to focus on feature velocity while the platform handles the 'Hard Things'—Security, Resilience, and Observation."
