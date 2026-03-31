# 🛡️ GKE Autopilot Observability Hardening Guide

This document details the production challenges and solutions for implementing a full observability stack (Prometheus, Grafana, OpenTelemetry) on GKE Autopilot.

---

## 🏗️ The Autopilot Constraint Model
GKE Autopilot is a "Serverless" Kubernetes offering. While it simplifies node management, it imposes strict security boundaries:
1.  **No Host Access**: Modules like `nodeExporter` that require `hostNetwork` or access to `/proc` and `/sys` on the node are blocked.
2.  **Managed Namespaces**: The `kube-system` namespace is managed by Google. Users cannot patch or scrape its components (CoreDNS, Kube-Proxy) using standard Helm values.
3.  **Restricted Pod Security**: All pods must comply with `Baseline` or `Restricted` standards (no root, no privileged ports < 1024).

---

## 🛠️ The Solution: "Hardened" Observability-as-Code

### 1. Prometheus Stack Overrides
We used the `kube-prometheus-stack` but overrode the restricted defaults in `monitoring/prometheus/values.yaml`:
*   **Disabled NodeExporter**: Autopilot provides its own managed metrics for nodes; we disabled the Helm-managed daemonset to avoid forbidden `hostNetwork` requests.
*   **Disabled Admission Webhooks**: Attempting to create internal admission controllers often conflicts with the Autopilot control plane. We disabled these to ensure the Operator starts reliably.
*   **Namespace Filtering**: Configured Prometheus to focus exclusively on the `ecommerce` and `monitoring` namespaces, avoiding forbidden `kube-system` components.

### 2. OTel Collector (Trace Exporter)
The OpenTelemetry Collector was tailored for serverless execution:
*   **Unprivileged Image**: Uses a non-root UID to comply with Autopilot security policies.
*   **Cloud Trace Integration**: Instead of running a heavy local storage backend like Jaeger, we export all traces directly to **GCP Cloud Trace** (managed service) using a simplified `googlecloud` exporter.
*   **Config Unmarshaling Fix**: Resolved a common "CrashLoopBackOff" by upgrading the legacy `logging` exporter to the modern `debug` exporter and flattening the YAML schema for GKE compatibility.

---

## 📈 Value Proposition for Production
This setup provides **Managed Reliability** without sacrifice:
*   **Zero-Trust**: No container runs as root.
*   **Cloud-Native**: Low cluster footprint by leveraging GCP's managed tracing and logging.
*   **SRE-Ready**: Includes 10+ premium Grafana panels tracking P99 latency and HPA scaling events.
