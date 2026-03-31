# 🔒 Interview Guide: Platform Security & Hardening

In Senior DevOps/SRE interviews, you will be tested on how you move beyond "Standard" security toward **Zero-Trust** and **Least-Privilege** models.

---

## 1. Network Security (Zero-Trust)
**Q: How do you secure microservice communication in your cluster?**
*   **Solid Answer**: "By default, Kubernetes pods can all talk to each other. I implemented a **Zero-Trust Network Model** using Namespace-level `NetworkPolicies`.
    *   **Default Deny**: I applied a global policy that denies all incoming and outgoing traffic by default.
    *   **Least-Privilege Access**: I then added explicit 'Allow' policies. For instance, the `payment-service` only accepts ingress on port 8002 from pods with the label `app: api-gateway`. This ensures that even if our `frontend` is compromised, an attacker cannot reach the sensitive Payment or Database layers."

## 2. Identity & Access (Workload Identity)
**Q: How do your pods authenticate to Google Cloud services (like Storage or Secret Manager)?**
*   **Solid Answer**: "I avoided using long-lived JSON service account keys, which are a major security risk. Instead, I implemented **GKE Workload Identity**.
    *   **How it works**: I mapped a Kubernetes Service Account to a GCP IAM Service Account using an annotation. When a pod needs to write logs or pull secrets, it requests a short-lived token from the GKE Metadata Server. This is completely keyless and much more secure because there is no static credential to steal."

## 3. Container Hardening (Non-Root)
**Q: How do you protect against container breakout attacks?**
*   **Solid Answer**: "I enforced strict **Pod Security Standards (PSS)**.
    *   **Non-Root**: Every `Dockerfile` in the project ends with `USER 1000`. This ensures that even if an attacker exploits a vulnerability in the application, they are running as a low-privilege user and cannot modify system files or install malicious packages.
    *   **Read-Only Root**: I configured our K8s Deployments with `readOnlyRootFilesystem: true`. The application can only write to specific `/tmp` or `/log` volumes. This prevents permanent malware injection into the container image."

## 4. Secret Management (ESO)
**Q: How do you handle rotation of sensitive credentials?**
*   **Solid Answer**: "We use **External Secrets Operator (ESO)** in conjunction with GCP Secret Manager.
    *   Instead of manually updating K8s Secrets, we define an `ExternalSecret` resource that polls GCP Secret Manager every hour. If I rotate a password in the GCP Console, ESO automatically updates the K8s Secret, and our microservices (which watch for file changes) refresh their connection pool without a pod restart."

---

## 💡 Pro-Tip for the Interview:
If they ask, *"What's the most important security layer?"*, answer: *"Defense in depth. We don't rely on just one layer. We use NetworkPolicies for traffic, Workload Identity for auth, and Non-Root containers for runtime security."*
