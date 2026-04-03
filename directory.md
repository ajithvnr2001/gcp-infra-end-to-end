# 📂 Project Directory Guide: GCP Implementation Focus

This directory guide highlights the critical folders and files in this repository, with a specific focus on **Google Cloud Platform (GCP)** implementations. Use this as a map when reviewing the codebase or explaining the GCP-specific architecture during technical interviews.

---

## 🏗️ 1. Infrastructure as Code (Terraform)
*Where the foundational GCP resources are provisioned.*

*   **`terraform/`**
    *   **`envs/prod/`**: The main entry point for the production environment. Contains `main.tf` which orchestrates calling the underlying modules to build the GCP infrastructure.
    *   **`modules/`**: Contains the reusable GCP resource definitions using the `google` and `google-beta` providers.
        *   **`vpc/`**: Provisions the Custom VPC, Subnets, **Cloud NAT** (critical for private node egress), and **VPC Peering** (setup for Cloud SQL private access).
        *   **`gke/`**: Provisions the **GKE Standard (Zonal)** cluster. *Interview Focus*: Look here for custom node pools (`e2-standard-2`), Workload Identity enablement, and Private Cluster configurations.
        *   **`cloudsql/`**: Provisions the **Cloud SQL PostgreSQL** High-Availability (HA) instance configured for private IP access via the VPC network.
        *   **`iam/`**: Manages the GCP Service Accounts (GSAs) and IAM bindings required for fine-grained access control and Workload Identity.

## ☸️ 2. Kubernetes Manifests (GKE & Security)
*Where the application, security, and observability stacks are defined.*

*   **`k8s/`**
    *   **`deployments/`**: Contains the Kubernetes Deployments and Services for the microservices (`frontend`, `catalog`, `cart`, `payment`, `api-gateway`).
        *   *GCP Focus*: Look here for the `seccompProfile: { type: RuntimeDefault }` and `runAsNonRoot: true` which are necessary to comply with the cluster's Pod Security Admission.
    *   **`security/`**:
        *   **`pod-security/`**: Contains the `Namespace` labeling (`pod-security.kubernetes.io/enforce: restricted`) that enforces the PSA restricted profile on our GKE cluster.
        *   **`external-secrets/`**: Configuration for the **External Secrets Operator (ESO)**.
            *   *GCP Focus*: Look for `SecretStore` definitions connecting to **GCP Secret Manager** and `ExternalSecret` manifests defining the sync process.
    *   **`monitoring/`** & **`tracing/`**:
        *   *GCP Focus*: Look for the OpenTelemetry (**OTel**) Collector configuration (`otel-collector.yaml`), which is configured to export distributed traces directly to **GCP Cloud Trace**.

## ⚙️ 3. Automation and DevOps Scripts
*Where the operational heavy lifting happens.*

*   **`scripts/`**
    *   **`build.sh`**: The end-to-end bootstrap script for infrastructure and apps.
        *   *GCP Focus*: Heavy usage of `gcloud` CLI. Look for API enablers, GKE cluster credential fetching (`gcloud container clusters get-credentials`), and Cloud SQL configurations.
    *   **`nuke.sh`** & **`nuke-and-rebuild.sh`**: The Disaster Recovery (DR) and full cleanup scripts.
        *   *GCP Focus*: Look for `terraform destroy` commands targeting specific GCP states and forceful cleanup of GCP Load Balancers or orphaned GCP Disks to prevent shadow billing.

## 🚀 4. CI/CD & Delivery
*Where the GitOps delivery pipeline and GitHub Actions / Cloud Build artifacts reside.*

*   **`argocd/`**:
    *   **`apps.yaml`**: The "App-of-Apps" pattern definition. Instructs ArgoCD to sync the `k8s/` directory into our GKE cluster.
*   **`cloudbuild.yaml`** (if present) / **`github-actions/`**:
    *   *GCP Focus*: Pipeline steps defining the multi-stage Docker builds, pushing to **Google Container Registry (GCR) / Artifact Registry**, and triggering ArgoCD syncs.

## 📚 5. Documentation & Interview Prep
*Where technical narratives, interview scripts, and reference materials are stored.*

*   **`docs/`**
    *   **`INTERVIEW-EXPLANATION.md`**: Master-level architectural narrative detailing our **GCP**, GKE Standard, and Security design choices. This is the main document to study for interviews.
    *   **`GITOPS-TROUBLESHOOTING.md`**: Runbooks for solving ArgoCD drift and sync issues within the GKE cluster.
*   **`resume_gcp.md`**: Your enterprise-level, ATS-friendly CV fully mapped to the achievements of this GCP project.
