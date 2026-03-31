# 🎯 Top Production Scenario Questions — E-Commerce Project

Use these questions to demonstrate your deep understanding of the architecture, its failure modes, and operational excellence during your interview.

---

## 🏗️ Networking & Connectivity

**Q: In `services.yaml`, all your microservices are `ClusterIP`. How does an external user actually reach the Catalog service?**
- **Solid Answer**: "External traffic hits the **NGINX Ingress Controller** (LoadBalancer). The Ingress resource defines a rule (e.g., path `/catalog`) that directs traffic to the `api-gateway` service. The `api-gateway` then performs internal routing to the `catalog-service` ClusterIP. This ensures that only the Gateway is exposed, and microservices are kept private."
- **Follow-up**: "What happens if the `api-gateway` pod fails?"
  - **Answer**: "Kubernetes detects the failure via liveness probes and restarts it. Meanwhile, the `api-gateway` Service (ClusterIP) points only to healthy pod IPs, so traffic is automatically rerouted to other replicas. This is why I run at least 2 replicas for the Gateway."

---

## 💾 Infrastructure & State

**Q: You're using Terraform with a GCS backend. What happens if two engineers try to run `terraform apply` at the same time?**
- **Solid Answer**: "GCP Storage buckets support **state locking** naturally when used with Terraform. The second person will get a 'Lock Exception' and their apply will fail. This prevents state corruption or 'last-write-wins' scenarios where infrastructure configurations get conflicted."
- **Follow-up**: "What if the state file gets corrupted or accidentally deleted?"
  - **Answer**: "I enabled **Versioning** on the GCS bucket. I can simply roll back to a previous version of the `terraform.tfstate` file. Also, since all infrastructure is defined in code, I could theoretically perform a `terraform import` to rebuild the state from existing GCP resources."

---

## 🚀 Deployment & GitOps

**Q: If you push a code change that breaks the Payment service, how does ArgoCD handle it?**
- **Solid Answer**: "ArgoCD will attempt to sync the new manifest. If the new pod's **Readiness Probe** fails, Kubernetes will not send traffic to it. The old pods remain running. ArgoCD will show a 'Progressing' status but the cluster remains healthy (Old Version). I can then revert the git commit to 'Self-Heal' back to a known-good state."
- **Follow-up**: "Can you automate the rollback?"
  - **Answer**: "Yes, by enabling `selfHeal: true` in the ArgoCD Application resource. If anyone manually 'teaches' the cluster something (drift) or if a sync fails, ArgoCD tries to reconcile it. For automated rollbacks on failed health checks, we could integrate **Argo Rollouts** for Canary/Blue-Green deployments."

---

## 📉 Scalability & Performance

**Q: Your HPA is scaling pods based on CPU. What if a service is 'Slow' but CPU is 'Low' (e.g., waiting on DB connections)?**
- **Solid Answer**: "CPU-based scaling wouldn't catch this. I would introduce **Custom Metrics** (via Prometheus Adapter). I can then tell HPA to scale based on 'Active Requests' or 'Response Latency'. If latency increases, HPA scales up pods even if CPU is low, providing a better user experience."
- **Follow-up**: "GKE Autopilot manages nodes, but can it scale fast enough for a 10x traffic spike?"
  - **Answer**: "Autopilot scales nodes in roughly 60-90 seconds. To handle 'Instant' spikes, I use **Pod Priority & Preemption**. I keep a 'Dummy' deployment with low priority that reserves space. When a real spike hits, Kubernetes kills the dummy pods to instantly place the Catalog pods while new nodes provision in the background."

---

## 🔒 Security & Compliance

**Q: How do you ensure the `payment-service` cannot be reached by a 'Compromised' `catalog-service`?**
- **Solid Answer**: "By using **Network Policies** located in `k8s/security/network-policies/`. I apply a 'Namespace Isolate' policy that denies incoming traffic by default. I then add a specific policy for Payment that only labels the `api-gateway` as a valid source. Even if an attacker gets shell access to Catalog, they cannot ping or reach the Payment service on any port."
- **Follow-up**: "How do you rotate Database credentials without restarting the app?"
  - **Answer**: "I use GCP Secret Manager with **External Secrets Operator**. The app (FastAPI) is configured to watch for file changes on the mounted secret volume (or periodically re-reads). When I rotate the password in GCP, the Operator updates the K8s Secret, and the app picks it up without a pod restart."

---

## 📈 Monitoring & Reliability

**Q: A user reports 'Some items are missing from the cart' but your dashboard is all Green. Where do you look?**
- **Solid Answer**: "This sounds like a logic error or a 'Partial Success'. I'd jump into **Distributed Tracing (Cloud Trace)**. I'd filter for the user's Trace ID and look at the 'Waterfall'. I might see the Cart service returning a 200 but the internal 'AddItem' function showing a sub-span error or span attribute indicating a 'Silent Failure'. Tracing is critical for these 'Gremlin' bugs that metrics miss."

---

## 🏗️ GKE Autopilot & Platform Hardening

**Q: You are running on GKE Autopilot. Why did you use an 'Unprivileged' NGINX image for the frontend?**
- **Solid Answer**: "GKE Autopilot enforces **strict Pod Security Standards**. It forbids containers from running as root or binding to ports below 1024. Standard NGINX images run as root and use port 80. By using `nginxinc/nginx-unprivileged`, I ensured the pod complies with `Baseline` and `Restricted` security levels while still serving traffic on port 8080."
- **Follow-up**: "What happens if a pod requests 20Gi of RAM but Autopilot only has 4Gi available?"
  - **Answer**: "Autopilot is serverless; it will automatically provision a new node that matches the sum of pod resource requests. It removes the need for manual node pool management, which is why it's ideal for a 'Production' e-commerce site with fluctuating traffic."

**Q: During deployment, your ArgoCD sync failed due to a `cert-manager` webhook timeout. How did you fix this race condition?**
- **Solid Answer**: "This is a classic 'Dependency Race Condition'. When core platform tools like `cert-manager` are installed, their admission webhooks need a few seconds to initialize their internal CA and certificates. If ArgoCD immediately starts applying manifests that use these webhooks, the cluster rejects them with a 'TLS unknown authority' error. I fixed this by adding a **structural 30-second sleep** in the deployment script between the CRD installation and the application sync."

**Q: Why couldn't you use the default `kube-prometheus-stack` values on Autopilot?**
- **Solid Answer**: "The default chart tries to install `nodeExporter` (uses `hostNetwork`) and scrape `kube-system` components like CoreDNS. Autopilot manages these components for you and blocks user-level access to them for security. I had to explicitly **disable NodeExporter and Kubelet metrics** in the Helm values to allow the stack to install without permission errors."

---

## 🌪️ Disaster Recovery & Automation

**Q: Your entire GCP project is deleted by accident. How fast can you recover?**
- **Solid Answer**: "Because I followed an **Infra-as-Code (Terraform)** and **GitOps (ArgoCD)** model, we can recover in under 15 minutes. I built a custom `nuke-and-rebuild.sh` script that automates the entire process: it provisions the VPC/GKE/Cloud SQL via Terraform, bootstraps the platform tools (ingress, cert-manager), and triggers the ArgoCD Root App. The only manual step is a one-time DNS update on the external LoadBalancer."
- **Follow-up**: "What about the database data?"
  - **Answer**: "We have daily **Cloud SQL Automated Backups** and Point-in-Time Recovery (PITR) enabled. Using Terraform, we can restore the database instance to the last known good transaction. For Kubernetes state, since everything is in Git, ArgoCD will automatically redeploy all microservices as soon as the cluster is live."
