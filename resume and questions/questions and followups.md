# 🏛️ Enterprise Banking DevOps & SRE Interview Playbook

This master guide is written **100% from the perspective of a real, enterprise production banking platform** running at a major financial institution (managed by LTIMindtree). 

Your hands-on GKE repository represents your personal lab to validate the core technical stack (Terraform, GKE, GitHub Actions, ArgoCD, Istio). In your interviews, you will use this playbook to explain your experience in terms of **enterprise-grade banking infrastructure, strict financial compliance (PCI-DSS/SOC2), high availability, and secure money-transfer workflows.**

---

## 🏗️ PART 1: Core Architecture of an Enterprise Banking Platform
*How to describe your platform, service communication, and architectural flows.*

### Q1: "Describe the architecture of the banking application you supported at LTIMindtree."
> **Answer:** "At LTIMindtree, we managed the core digital banking platform for a major retail banking client. The platform is architected as a highly secure, microservices-based application containerized with Docker and running on **Google Kubernetes Engine (GKE)**.
> 
> The platform is split into several critical microservices:
> * **User Authentication & Session Service:** Handles customer logins and MFA tokens.
> * **Core Account/Balance Service:** Retrieves account balances and interest calculations.
> * **Payment Routing & Transfer Service:** Handles ACH, SEPA, and wire transfers.
> * **Notification Service:** Dispatches SMS, email, and push notifications for transactions.
> * **Audit Ledger Service:** Writes every single transaction to an immutable database for compliance.
> 
> **The Request Flow:**
> When a customer transfers money through the app, the request is received by our external **GCP Global Cloud Load Balancer (GCLB)**. The Load Balancer performs SSL termination and forwards the traffic to our **Istio Ingress Gateway**. 
> 
> Traffic then enters the GKE cluster, where the Istio **VirtualService** routes it to our **API Gateway**. The Gateway validates the customer’s JWT session token and securely calls the internal **Transfer Service** and **Audit Ledger Service** over **mutual TLS (mTLS)**.
> 
> Our stateful data is hosted on highly available, multi-zone **GCP Cloud SQL (PostgreSQL)** databases with point-in-time recovery enabled. The entire infrastructure is deployed using modular **Terraform**, and application deployments are driven by **GitHub Actions and ArgoCD GitOps**."

### Q2: "In a banking environment, security is paramount. How did you isolate different classes of microservices inside Kubernetes?"
> **Answer:** "In an enterprise bank, you cannot run public-facing web servers on the same hardware as your critical transaction-processing databases. We enforced isolation at three distinct layers:
> 
> 1. **Compute Isolation (Node Pools, Taints, and Tolerations):** We created two GKE node pools: a `public-ingress-pool` and a `secure-transaction-pool`. We tainted the transaction pool (`dedicated=transactions:NoSchedule`) and ran our critical services (Ledger, Payment, Database Proxies) on these nodes with matching tolerations. This ensured critical payment processing workloads were physically separated from web portals that are vulnerable to external DDoS or code injection.
> 2. **Network Isolation (Kubernetes NetworkPolicies):** We enforced a default `deny-all` network policy. We then defined explicit NetworkPolicies allowing only validated paths. For instance, the public portal can only talk to the API Gateway. Under no circumstances can the web frontend talk directly to the Database or the Payment service.
> 3. **Namespace Isolation:** We isolated environments into separate Kubernetes namespaces: `banking-apps` (core microservices), `istio-system` (ingress and mesh control plane), and `monitoring` (Prometheus stack), restricting developer access using **RBAC (Role-Based Access Control)**."

---

## 🔒 PART 2: Security, Compliance, & Zero-Trust
*Covering PCIDSS, SOC2, IAM, secrets, and encrypted mesh communication.*

### Q3: "As a bank, you must comply with PCI-DSS and SOC2. How did you handle secrets in GitOps without committing them to version control?"
> **Answer:** "Storing database passwords, payment gateway API keys, or JWT signing secrets in GitHub—even Base64 encoded—is a direct compliance failure under SOC2 and PCI-DSS.
> 
> We implemented the **External Secrets Operator (ESO)** combined with **GCP Secret Manager**. The actual passwords and cryptographic keys are created and rotated automatically inside GCP Secret Manager, protected by strict Cloud IAM permissions.
> 
> In our Git manifest repository, we only store an `ExternalSecret` definition. When ArgoCD syncs the cluster, the External Secrets Operator intercepts the definition, authenticates against GCP using **Workload Identity**, retrieves the secret from Secret Manager over HTTPS, and injects a standard Kubernetes `Secret` dynamically into memory inside GKE. The actual secret value is never written to Git, never printed in CI logs, and never exposed on developer machines."

### Q4: "Explain GKE Workload Identity. Why is it an absolute requirement for an enterprise banking setup?"
> **Answer:** "Traditionally, to access GCP resources (like GCS buckets for backup, or Secret Manager), you had to download a JSON Service Account key and mount it inside the pod. In a banking platform, static keys are a major risk: they do not expire, they are difficult to rotate, and if a pod is compromised, the attacker can extract the JSON key and access your cloud environment.
> 
> We enforced **Workload Identity**, which links a GKE Kubernetes Service Account (KSA) directly to a Google Cloud IAM Service Account (GSA). When a pod runs, the GKE metadata server automatically intercepts any GCP API calls and issues a short-lived (one hour) OAuth2 access token to the pod. There are zero JSON keys stored, zero rotation scripts to maintain, and the credentials automatically expire if a container is terminated."

### Q5: "How did you implement Istio Service Mesh to enforce Zero-Trust inside GKE?"
> **Answer:** "Without a service mesh, Kubernetes service-to-service communication travels over the internal network in plain text. If an attacker compromises a single container, they could potentially sniff network packets and steal transaction data.
> 
> We deployed **Istio Service Mesh** and configured a namespace-wide `PeerAuthentication` policy set to **STRICT mTLS**. This forces Envoy sidecars injected into our pods to authenticate both sides of a connection using mutual TLS. Istio acts as our internal Certificate Authority, automatically issuing and rotating short-lived x509 certificates to each pod. 
> 
> We also applied **Istio AuthorizationPolicies**. For example, we defined a policy stating that the `audit-ledger` service will *only* accept traffic if the client pod has the identity `cluster.local/ns/banking/sa/payment-service-sa`. This blocks any unauthorized pods from querying or writing to our ledger service."

---

## 🏗️ PART 3: Infrastructure as Code (Terraform)
*Enterprise state management, disaster recovery, and module structures.*

### Q6: "How did you structure your Terraform code to manage different banking environments (Dev, UAT, Prod)?"
> **Answer:** "To ensure consistency and safety, we utilized a **Modular Terraform structure** combined with isolated environment directories. 
> 
> We built core modules for the **VPC (including Cloud NAT and Firewall rules), GKE (Standard multi-zone clusters), and Cloud SQL (PostgreSQL with High Availability)**. These modules are generic and parameterized.
> 
> Under our environment folders (such as `envs/prod/`), we define our remote backend pointing to a GCS bucket, and we call our modules by passing environment-specific values. For example, in `dev`, we provision small GKE node pools and a shared Cloud SQL instance to save costs. In `prod`, we pass variables for multi-zone node pools, highly available Cloud SQL with read-replicas, and strict VPC Service Controls."

### Q7: "What is your backup and DR (Disaster Recovery) strategy for your database infrastructure?"
> **Answer:** "For our PostgreSQL database, we configured **High Availability (HA)** natively within GCP Cloud SQL. This spins up a primary database in zone `us-central1-a` and a standby instance in zone `us-central1-b` with synchronous replication. If the primary zone fails, GCP triggers an automatic failover to the standby in less than 60 seconds with zero data loss.
> 
> For cold backups, we configured:
> 1. **Automated daily backups** with **Point-In-Time Recovery (PITR)** enabled. This stores transaction logs (`write-ahead logs`) every few minutes, allowing us to restore our database to the exact second of any corrupt transaction.
> 2. An automated Python backup script that exports database schemas daily, compresses them, and uploads them to a **dual-region GCS bucket** with a strict 7-year retention policy to satisfy banking compliance audits."

---

## 🔄 PART 4: Enterprise CI/CD & GitOps
*Security scanning, quality gates, and automated delivery.*

### Q8: "Walk me through your CI/CD workflow for a release. What security checks are in place before code reaches GKE?"
> **Answer:** "Because we are in a regulated banking environment, we enforce strict **fail-fast security gates** in our pipelines.
> 
> 1. **Pre-Merge:** When a developer raises a PR to `main`, our **GitHub Actions** CI pipeline triggers. It runs static code analysis (using SonarQube) to check for security vulnerabilities and code coverage.
> 2. **Vulnerability Scanning:** The pipeline builds the Docker image and runs a security scan using **Trivy** to check for OS-level and package vulnerabilities. If any High or Critical vulnerabilities are found, the build automatically fails and blocks the PR.
> 3. **Artifact Promotion:** Once the PR is merged, the image is tagged with the Git commit SHA and pushed to our secure **GCP Artifact Registry (GAR)**.
> 4. **GitOps Manifest Update:** The GitHub Action automatically updates our deployment manifests repository with the new image tag and pushes the change.
> 5. **ArgoCD Reconciliation:** ArgoCD detects the change in the manifest repo and synchronizes the GKE cluster, performing a zero-downtime rolling update deployment."

### Q9: "Why did your team adopt GitOps (ArgoCD) over traditional push-based deployment tools?"
> **Answer:** "We shifted to GitOps for three primary reasons:
> 
> 1. **Auditability and Compliance:** In banking, every single change must have an audit trail. With GitOps, because Kubernetes manifests are stored in Git, our Git commit log is our audit log. We know exactly who authorized a change, when it was merged, and what lines were altered.
> 2. **Security (No Shared Keys):** Traditional tools (like Jenkins) require giving the CI server administrative access keys (`kubeconfig`) to the Kubernetes cluster to push changes. If Jenkins is hacked, the attacker gets full control of your cluster. ArgoCD operates on a **pull-based model**. It runs inside the cluster and pulls manifests from Git, meaning no external server has administrative access to GKE.
> 3. **Config Drift Correction (Self-Healing):** If an engineer manually edits a deployment in the Google Cloud Console, ArgoCD detects that GKE has drifted from our Git repository. It instantly triggers a self-heal, rewriting the cluster back to the authorized Git state, preventing unauthorized manual changes in production."

---

## 🔍 PART 5: SRE, Observability, & Day-2 Operations
*Proving your 99.95% SLA, Golden Signals, and automation scripting.*

### Q10: "You mention a '99.95% SLA Maintained'. How did you configure GKE and your applications to guarantee this?"
> **Answer:** "Maintaining a 99.95% SLA (allowing less than 22 minutes of downtime per month) requires designing for failure at every layer:
> 
> * **Infrastructure Layer:** We used a **GKE Regional Cluster** with GKE worker nodes spread across three Availability Zones. If a zone is lost, our nodes in the other two zones handle the load.
> * **Application Layer (Scaling & Anti-Affinity):** We configure `PodAntiAffinity` on our core services to guarantee that replicas of the same microservice never run on the same physical node or zone. We also run **Horizontal Pod Autoscalers (HPA)** to scale pods dynamically from 2 to 20 replicas based on CPU and memory thresholds.
> * **Traffic Management:** We configured strict Readiness and Liveness probes. During a rolling update, GKE waits for the Readiness probe to pass before destroying the old container, ensuring 100% availability during code deployments."

### Q11: "Explain how you monitor the health of your banking microservices."
> **Answer:** "We follow the **SRE Golden Signals framework** using **Prometheus, Grafana, and GCP Cloud Monitoring**.
> 
> * **Metrics:** We configure Prometheus to scrape metrics from our microservices. We track **Latency** (P95/P99 transaction response times), **Traffic** (RPS on Ingress), **Errors** (rate of HTTP 5xx codes), and **Saturation** (GKE node memory and DB connection pool usage).
> * **Centralized Logging:** GKE pod stdout/stderr logs are collected using **Google Cloud Logging** and Loki, structured as JSON so we can quickly query trace IDs and error logs.
> * **Distributed Tracing (OpenTelemetry):** For cross-service transaction analysis, we use **OpenTelemetry**. When a payment is made, a unique `trace-id` is generated at the API Gateway and propagated through the account, payment, and database services. If a transaction fails or experiences latency, we can trace the exact flow across services and locate the bottleneck instantly."

### Q12: "Give me an example of an SRE automation script you built using Python or Bash."
> **Answer:** "To ensure regulatory compliance and prevent cluster performance degradation, I built an automated **Python log archival and storage optimizer script** that runs as a Kubernetes CronJob.
> 
> * **The Problem:** Our banking applications generate highly verbose logs for auditing. Retaining these on GKE node disks created high disk pressure, and keeping them in hot GCS storage buckets was driving up costs.
> * **My Script:** I wrote a Python script utilizing the `google-cloud-storage` SDK. The script runs every midnight, fetches transaction logs older than 7 days, compresses them, and moves them to a secure **Coldline/Archive GCS bucket**. 
> * **Compliance Control:** To satisfy banking regulations, the script locks the archive folder under a GCP GCS Object Retention policy, making the files completely undeletable for 7 years. It then generates a cryptographically signed SHA-256 hash of the archive for tamper-evidence and posts a success summary to our Slack operations channel. This script saved our on-call team roughly 5 hours of manual disk cleanup a week and reduced storage costs by 30%."

---

## 💥 PART 6: Real Enterprise Outage & Troubleshooting Playbook
*How you act and lead under pressure during high-severity production failures.*

### Scenario A: Payment Routing Service is experiencing High Latency & HTTP 504 Timeouts
* **The Interviewer:** *"During peak transaction hours, customers are getting timeout errors. Our Grafana dashboard shows HTTP 504 errors on the API Gateway. How do you troubleshoot this?"*
* **Your Answer:** 
  > 1. **Determine the Scope:** "First, I'll check our **OpenTelemetry trace dashboard**. I'll look up the active HTTP 504 trace IDs to see where the latency is bottlenecking. Does the latency happen *before* the API Gateway, inside the Gateway, or in the downstream Payment service?
  > 2. **Analyze Resource Saturation:** If the traces point to the Payment service, I will immediately run `kubectl top pods -l app=payment-service -n banking-apps` to check CPU and Memory usage.
  > 3. **Identify Downstream Bottlenecks:** If CPU/Memory are normal, the latency is likely caused by the database connection pool or an external third-party API timeout (e.g., waiting on Visa/Mastercard processing networks). I will check our database connection metrics in GCP Cloud SQL. If database connections are exhausted, our payment pods are stuck waiting to acquire a socket.
  > 4. **Mitigation Action:** 
  >    * If pods are CPU/Memory throttled and HPA is maxed out, I will manually scale up the replicas using `kubectl scale deployment payment-service --replicas=15`.
  >    * If the external payment gateway is slow, I will coordinate with developers to activate our **Istio Circuit Breaker** policy. This immediately fails-fast and returns a friendly 'Processing retry' response to users instead of letting connections pile up and crash the API Gateway."

### Scenario B: GKE Pod is Stuck in `CrashLoopBackOff` after a Deployment
* **The Interviewer:** *"You ran a new deployment, and one of your critical pods is stuck in a `CrashLoopBackOff` state. What is your exact diagnostic workflow?"*
* **Your Answer:**
  > 1. **Inspect Cluster Events:** "I will run `kubectl describe pod <pod-name> -n banking-apps`. I'll scroll to the **Events** section and check the termination exit code:
  >    * **Exit Code 137 (OOMKilled):** This means the pod exceeded its hard memory limit. I will increase the memory `resources.limits.memory` in our Git manifest.
  >    * **Exit Code 1 (Application Crash):** This is a code/configuration runtime error.
  > 2. **Check Application Logs:** If it is an exit code 1, I will run `kubectl logs <pod-name> -n banking-apps --previous`. The `--previous` flag is critical—it pulls the logs of the container *before* it crashed, allowing me to see the python startup traceback.
  > 3. **Verify Configuration & Secrets:** If the log shows database connection failures, I'll verify if the **External Secrets Operator** successfully injected our database password. I will run `kubectl get secrets -n banking-apps` and check if our `SecretStore` is in a `Valid` state. If the secret is missing, it means the GKE Workload Identity binding to GCP Secret Manager was broken or deleted."

### Scenario C: ArgoCD app is "Synced" but Pods are not Updating
* **The Interviewer:** *"ArgoCD shows everything is Synced and Healthy, but your developers complain that the GKE pods are still running the old version of the code. What is wrong?"*
* **Your Answer:**
  > "This is a classic GitOps mismatch. 
  > 
  > 1. **The Root Cause:** This happens when developers build a new container image but push it using the **`latest` tag** instead of a unique commit SHA tag, and our Kubernetes manifest in Git still references `image: payment-service:latest`.
  > 2. **Why ArgoCD missed it:** ArgoCD compares the Git manifest against GKE. In Git, the manifest says `latest`. In GKE, the running pod has `latest`. ArgoCD assumes there is zero drift, so it marks the application as 'Synced' and does nothing. It does not know the actual bytes of the image behind the `latest` tag changed.
  > 3. **The Quick Fix:** I will manually trigger a rollout restart of the deployment to force GKE to pull the new image from the registry: `kubectl rollout restart deployment payment-service -n banking-apps`.
  > 4. **The Permanent Process Fix:** We enforce **immutable semantic image tagging** in our CI pipeline. We configure GitHub Actions to tag every image with the unique **Git commit SHA** (e.g., `payment-service:sha-a1b2c3d`) and update the manifest repository. This guarantees that every code change changes the string in Git, forcing ArgoCD to detect a true diff and execute a rolling update deployment."
