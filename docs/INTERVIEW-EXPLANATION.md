# Enterprise Architecture: Production E-Commerce Platform

This architectural reference provides an in-depth technical analysis of our high-availability, high-security e-commerce platform. It is designed to demonstrate architectural proficiency in DevOps, Site Reliability Engineering (SRE), and Platform Engineering.

---

## 🏗️ 1. Infrastructure Architecture (IaC)
**Strategy**: Deterministic Provisioning via Terraform

### Architectural Decision: GKE Standard for Managed Nodes
We transitioned from a serverless-abstraction model to **GKE Standard** to unlock enterprise-grade infrastructure requirements:
-   **Node Level Control**: Implemented custom `kubelet` configurations and specific `e2-standard-2` node pools to ensure performance predictability for latency-sensitive microservices.
-   **Zonal/Regional Strategy**: Optimized for high-availability while strictly adhering to resource quota management and effective cost-governance (FinOps).
-   **Custom Service Accounts**: Each node pool operates under a dedicated, hardened Service Account with **Least Privilege** IAM scopes, ensuring lateral movement prevention in the event of a node compromise.

### Network Topology & Security
-   **Private VPC Architecture**: The cluster is fully private. Nodes have zero public IP exposure, communicating via **Cloud NAT** for outbound traffic and a **Private Service Access** peering layer for our **Cloud SQL (PostgreSQL)** backend.
-   **Workload Identity**: Eliminated long-lived secret keys by leveraging K8s-to-GCP identity mapping, aligning with Modern Security Best Practices (NIST/CIS).

---

## 🔄 2. CI/CD & GitOps Lifecycle
**Strategy**: Continuous Deployment via Pull-Based Reconciliation

### The Enterprise Pipeline
1.  **Continuous Integration (CI)**: **Google Cloud Build** executes parallelized, multi-stage Docker builds. 
    -   **Security Scanning**: Conceptually integrated with Artifact Analysis for vulnerability checks.
    -   **Immutability**: Every build generates a unique, immutable image tag (Git SHA) pushed to a private **Artifact Registry**.
2.  **Continuous Deployment (CD)**: **ArgoCD** implements the **App-of-Apps** pattern.
    -   **GitOps Source of Truth**: The `k8s/` directory in our Git repository is the absolute authority for cluster state.
    -   **Automated Sync & Self-Healing**: ArgoCD continuously reconciles the cluster state. Any "Configuration Drift" caused by manual intervention is automatically corrected within seconds, ensuring environmental stability.

---

## 🛡️ 3. Security Hardening & Compliance
**Strategy**: Defense-in-Depth

-   **Pod Security Admission (PSA)**: Enforced the **"Restricted"** profile globally in the `ecommerce` namespace.
    -   **Seccomp Hardening**: Every pod runs with a `RuntimeDefault` seccomp profile, significantly reducing the Linux kernel attack surface.
    -   **Non-Root Execution**: Strict enforcement of `runAsNonRoot` and dropping of all Linux capabilities (`CAP_SYS_ADMIN`, etc.).
-   **Network Policies (Zero Trust)**: Microsegmentation strategy. We deny all ingress/egress by default, only allowing explicitly defined traffic flows (e.g., `api-gateway` -> `catalog-service`).
-   **External Secrets Management**: We integrated **GCP Secret Manager** with the **External Secrets Operator**. Sensitive credentials never exist in plain text within our GitOps repository, only symbolic references.

---

## 📊 4. Observability & SRE (Monitoring)
**Strategy**: Service Level Objective (SLO) Driven Monitoring

-   **Full-Stack Visibility**: Deployed the `kube-prometheus-stack` to capture:
    -   **Host-Level Metrics**: `NodeExporter` provides visibility into kernel-level resource utilization.
    -   **Golden Signals**: Real-time tracking of Latency, Traffic, Errors, and Saturation.
-   **Grafana Dashboards**: Unified visualization for platform health, including custom SRE dashboards for microservice performance.
-   **Distributed Tracing (OpenTelemetry)**: Leveraging an **OTel Collector** sidecar pattern to export traces to **Cloud Trace**, allowing us to identify latency bottlenecks across the asynchronous microservice topology.

---

## 🚑 5. Resilience & Business Continuity (DR)
**Strategy**: "Everything-as-Code" Recovery

The platform supports a 100% automated **Disaster Recovery (DR)** workflow via `nuke-and-rebuild.sh`. In the event of a regional outage or security breach:
-   **RTO (Recovery Time Objective)**: ~15 minutes to full platform restoration.
-   **RPO (Recovery Point Objective)**: Near-zero, as all configuration and state transitions are captured in Git and Terraform state.

---

## 🎯 Final Summary: Why This Architecture?
"In an enterprise environment, we don't just optimize for 'it works'; we optimize for **Scale, Security, and Maintainability**. By moving to GKE Standard, enforcing Restricted PSA, and adopting a GitOps-first deployment model, we've created a platform that is not only robust under load but also auditable and secure by default."
