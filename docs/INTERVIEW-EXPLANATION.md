# End-to-End Architecture: Production E-Commerce Platform

This document provides a comprehensive technical explanation of the platform's architecture, designed for deep-dive technical interviews (DevOps/Platform Engineering).

---

## 🏗️ 1. Infrastructure Layer (IaC)
**Technology**: Terraform, GCP (Google Cloud Platform)

### Philosophy: Zonal GKE Standard over Autopilot
While Autopilot is excellent for serverless-like simplicity, we migrated to **GKE Standard (Zonal)** to achieve:
-   **Granular Node Control**: Manual management of node pools using `e2-standard-2` machine types for predictable performance and custom `kubelet` configurations.
-   **Security Hardening**: Full access to the node-level security context, allowing us to implement the **PodSecurity Admission (PSA) "restricted"** profile across namespaces.
-   **Cost Optimization**: Moving from Regional to Zonal clusters allowed us to fit the full microservice + observability stack (Prometheus/Grafana/ArgoCD) within standard GCP trial quotas while maintaining 99.9% availability for dev/test.

### Networking & Security
-   **VPC Peering**: Secure, private connection between GKE and Cloud SQL (Postgres).
-   **Cloud NAT**: Private nodes with no public IPs; outbound internet access is secured via Cloud NAT.
-   **Workload Identity**: Zero-trust authentication where K8s Service Accounts are mapped to GCP IAM Roles, eliminating the need for long-lived JSON keys.

---

## 🔄 2. CI/CD & GitOps Pipeline
**Technology**: GitHub, Cloud Build, ArgoCD

### The Flow
1.  **Commit**: Developer pushes to the `main` branch.
2.  **Continuous Integration (CI)**: **Google Cloud Build** triggers parallel builds for all 5 microservices.
    -   Images are tagged with the short-SHA and `:latest`.
    -   Pushed to **Google Container Registry (GCR)**.
3.  **Continuous Deployment (GitOps)**: **ArgoCD** (running in-cluster) monitors the `k8s/` directory.
    -   ArgoCD detects the change in the repository.
    -   **Automated Reconciliation**: ArgoCD "pulls" the new state into the cluster, ensuring the live state matches the Git source of truth.
    -   **Self-Healing**: If a manual `kubectl delete` occurs, ArgoCD immediately detects the drift and recreates the resource.

---

## 🛡️ 3. Kubernetes Security & Hardening
**Technology**: PodSecurity Admission (PSA), RBAC, NetworkPolicies

-   **Restricted PSA**: The `ecommerce` namespace is labeled with `pod-security.kubernetes.io/enforce: restricted`. 
    -   Requires `seccompProfile: { type: RuntimeDefault }`.
    -   Enforces `runAsNonRoot: true`.
    -   Drops all Linux capabilities.
-   **Network Policies**: Least-privileged traffic flow. For example, the `frontend` only communicates with the `api-gateway`, and the `catalog-service` is the only service allowed to reach the database.
-   **External Secrets Operator**: Syncs sensitive parameters from **GCP Secret Manager** into K8s Secrets, ensuring no credentials ever touch the Git repository.

---

## 📊 4. Observability (O11y)
**Technology**: Prometheus, Grafana, NodeExporter, OTel

-   **Prometheus & Grafana**: Automatically deployed via the `kube-prometheus-stack` Helm chart.
-   **NodeExporter**: Unlocked via GKE Standard migration to provide host-level metrics (CPU, Memory, Disk, I/O) that are often hidden in serverless/autopilot environments.
-   **OpenTelemetry (OTel)**: Distributed tracing from microservices is sent to a central **OTel Collector**, which exports data to **GCP Cloud Trace** for end-to-end request visibility.

---

## 🚑 5. Disaster Recovery Strategy
**Script**: `nuke-and-rebuild.sh`

In a total regional failure or compromise event:
1.  The script performs a clean wipe of all infrastructure.
2.  Terraform re-provisions the entire VPC, Cloud SQL, and GKE cluster.
3.  ArgoCD is bootstrapped and immediately restores the 10+ microservices and 100+ networking rules.
4.  **RTO (Recovery Time Objective)**: ~15 minutes (mostly GKE control plane provision time).

---

## 🎯 Interview Talking Points (Quick-Fire)
-   **Why GKE Standard?** "I wanted manual control over node scaling and security profiles (PSA restricted) that Autopilot abstracts away."
-   **Why GitOps?** "To ensure environmental consistency and enable 'Push-to-Deploy' while maintaining a perfect audit log in Git."
-   **How do you handle secrets?** "External Secrets Operator + GCP Secret Manager. We store pointers in Git, not the actual secrets."
-   **Biggest challenge?** "Migrating to a restricted security profile required adding seccomp profiles to all legacy deployments and right-sizing node resources to avoid OOM kills during the ArgoCD sync burst."
