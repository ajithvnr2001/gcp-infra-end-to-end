# 📘 Master Technical Reference: GKE Standard Architecture

This document serves as the absolute source of truth for the technical design, security model, and operational logic of the project. It is designed for deep-dive technical reviews and architectural audits.

---

## 🏗️ 1. GKE Standard: Managed Node Pools
Unlike Autopilot's serverless model, **GKE Standard** gives us manual control over the underlying infrastructure.
*   **Node Pools**: We define and manage specific node pools (e.g., `e2-standard-2`). This allows for precise resource bin-packing and cost optimization.
*   **Full Control**: Standard GKE allows for privileged containers, node-level access, and custom machine types, which were restricted in Autopilot.
*   **Operational Impact**: This migration enables full observability (NodeExporter) and admission webhooks, providing the "precision" needed for SRE operations.

---

## 🔒 2. Zero-Trust Networking & Identity
### 2.1 Workload Identity
We eliminated static GCP JSON keys. Instead, we use **Workload Identity**:
1.  A K8s Service Account (KSA) is created.
2.  An IAM Service Account (GSA) is created with specific permissions (e.g., `roles/monitoring.metricWriter`).
3.  The KSA is "bound" to the GSA via an annotation: `iam.gke.io/gcp-service-account`.
4.  When a pod runs, the GKE Metadata Server provides it a temporary OAuth2 token, allowing it to act as the GSA securely.

### 2.2 Private Service Access (Database Connectivity)
Our Cloud SQL instance is **Private-Only**.
*   It has no public IP.
*   We use **VPC Peering** (established via Terraform) between our VPC and Google's Producer VPC.
*   Microservices connect via an internal IP (e.g., `10.x.x.x`), ensuring database traffic never traverses the public internet.

---

## 🔄 3. GitOps & Sync Mechanics (ArgoCD)
ArgoCD implements a **Control Loop** that runs every ~3 minutes:
1.  **State Comparison**: Compares the `Live State` (K8s cluster) with the `Desired State` (Git repo).
2.  **Drift Detection**: If an engineer manually changes a replica count via `kubectl`, ArgoCD flags it as `OutOfSync`.
3.  **Self-Healing**: If `selfHeal: true` is set, ArgoCD immediately applies the Git version over the manual change, maintaining the source-of-truth.
4.  **Sync Waves**: We use sync waves to ensure namespaces are created *before* deployments, and platform tools (like `cert-manager`) are ready *before* the application.

---

## 📊 4. The Observability Data Pipeline
### 4.1 Metrics Pathway
`App (/metrics)` → `Prometheus (Scrape)` → `Prometheus DB` → `Grafana (Query)`.
*   We use **ServiceMonitors** and scrape-annotations to auto-discover new pods.

### 4.2 Tracing Pathway
`App (OTel SDK)` → `OTLP Header Propagation` → `OTel Collector (Pod)` → `Batch Processor` → `GCP Cloud Trace Exporter` → `Cloud Trace Console`.
*   **Correlation**: Every log entry includes a `trace_id`, allowing a 1-to-1 jump from a log line to a visual waterfall span in Cloud Trace.

---

## 🌪️ 5. Automated Disaster Recovery (Nuke & Rebuild)
The `scripts/nuke-and-rebuild.sh` is an idempotency engine:
1.  **Wipe**: Deletes the ArgoCD apps and wipes the Terraform state (if requested).
2.  **Infra**: Re-runs `terraform apply` to ensure the VPC, GKE, and SQL are in the desired state.
3.  **Bootstrap**: Installs Ingress, Cert-Manager, and ESO.
4.  **App Sync**: Applies the `argocd/apps.yaml` to trigger the final application rollout.
*   **Result**: A mathematically identical environment is restored from the code.

---

## 🏁 Technical Reference Map
*   **Infrastructure**: `terraform/modules/`
*   **Kubernetes Manifests**: `k8s/`
*   **CI/CD Logic**: `.github/workflows/`
*   **Observability Logic**: `monitoring/prometheus/values.yaml` + `k8s/tracing/`
