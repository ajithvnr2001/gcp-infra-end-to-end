# Modern Production GitOps & Governance Architecture

This document provides a breakdown of how a code change moves from a developer's laptop to a **hardened, production-grade GKE Standard environment**, following industry best practices for security and reliability.

---

### 🏗️ Phase 0: Infrastructure as Code (Terraform)
*   **The Action**: Infrastructure is never manually clicked. We use `terraform apply`.
*   **The Detail**: **Terraform** provisions the core platform components:
    *   **VPC Security**: Private Google Access, NAT Gateways (no public IPs on nodes).
    *   **GKE Standard**: Multi-zonal control plane with custom Node Pools and auto-scaling.
    *   **Workload Identity**: Enabled at the cluster level to map K8s Service Accounts to IAM Roles.
*   **Why**: **Reproducibility**. If a region goes down, we can rebuild the entire stack in minutes, not hours.
*   **Interview Tip**: *"I manage infrastructure as code using Terraform modules to ensure environment parity and eliminate 'configuration drift' from day one."*

---

### 📥 Phase 1: Push & Secure CI (GitHub Actions → Artifact Registry)
*   **The Action**: Developer pushes code to `main`.
*   **The Detail**: **GitHub Actions** triggers a multi-stage pipeline:
    1.  **Build**: Creates a Docker image using a `distroless` or `alpine` base for a smaller attack surface.
    2.  **Scan**: The image is automatically scanned for vulnerabilities using **GCP Artifact Analysis** or **Snyk/Trivy**.
    3.  **Signing**: (Optional but recommended) Images are signed to ensure only trusted containers run.
*   **Why**: **Shift Left Security**. We catch vulnerabilities in the CI pipeline before they ever reach the cluster.

---

### 📝 Phase 2: The Heart of GitOps (Update Manifests)
*   **The Action**: CI updates the image tag in the deployment manifests.
*   **The Detail**: A specialized step in the pipeline updates the `catalog-deployment.yaml` in the `k8s/` folder.
*   **Why**: This separates the **Artifact Creation** (CI) from the **Deployment Logic** (CD), providing a clear audit trail in Git.

---

### 🔍 Phase 3: Reconciliation & Self-Healing (ArgoCD → GKE)
*   **The Action**: **ArgoCD** detects the change in Git and syncs the cluster.
*   **The Detail**: ArgoCD isn't just a deployment tool; it's a **reconciliation engine**. It continuously polls Git and compares the **Desired State** (Git) with the **Live State** (GKE). If a manual change is made in the cluster, ArgoCD detects the "Out of Sync" status and automatically resets it to the Git-defined state.
*   **Why**: **Self-Healing**. It prevents "snowflake" clusters where manual tweaks accumulate over time.

---

### 🛡️ Phase 4: Runtime Governance & Hardening
*   **The Action**: The cluster enforces security policies at runtime.
*   **The Detail**:
    1.  **Pod Security Admission (PSA)**: Namespaces are labeled with `pod-security.kubernetes.io/enforce: restricted`, blocking any pods that run as root or require dangerous privileges.
    2.  **Network Policies**: A **Default Deny All** policy is applied. Services are explicitly white-listed to talk only to who they need (e.g., `api-gateway` → `catalog`).
    3.  **Workload Identity**: Pods authenticate to Cloud SQL/GCS using short-lived tokens, eliminating the need for static JSON keys stored in secrets.
*   **Why**: **Zero-Trust**. Even if one microservice is compromised, the blast radius is contained.

---

### 🔑 Phase 5: Secrets Governance (External Secrets Operator)
*   **The Action**: Secrets are pulled securely from **GCP Secret Manager**.
*   **The Detail**: We use **External Secrets Operator (ESO)**. The secret metadata is in Git, but the actual sensitive values stay in Google Cloud Secret Manager. ESO automatically syncs them into Kubernetes `Secrets` for use by the pods.
*   **Why**: **Security Compliance**. We never commit plaintext secrets to Git, and we gain audit logs for every secret access via GCP.

---

### 📊 Phase 6: Observability & Feedback Loop
*   **The Action**: Prometheus and OpenTelemetry monitor the rollout.
*   **The Detail**:
    *   **Prometheus/Grafana**: Tracks "Golden Signals" (Latency, Errors, Traffic, Saturation).
    *   **OpenTelemetry**: Injects trace IDs so we can follow a single request from the Ingress down to the Cloud SQL query in **Cloud Trace**.
*   **Why**: **Mean Time to Recovery (MTTR)**. If a rollout causes a spike in P99 latency, we know instantly and can trigger a manual or automated rollback via ArgoCD.

---

### Summary for your interview:
"My architecture moves past simple CI/CD into **Infrastructure Governance**. We use **Terraform** for IaC, **ArgoCD** for GitOps-led reconciliation, and **Hardened GKE Standard** configurations like PSA and Network Policies to ensure a Zero-Trust environment. By decoupling secret management with **External Secrets** and unifying observability with **OpenTelemetry**, we've built a platform that is secure by default and self-healing by design."