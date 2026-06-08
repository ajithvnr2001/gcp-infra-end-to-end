# 🚀 Actual 3-Year DevOps Engineer Interview Flow

This guide is structured exactly how a real technical interview will flow based on your resume. Interviewers don't ask dictionary definitions (e.g., "What is Kubernetes?"); they ask **scenario-based** questions (e.g., "Why did you choose ArgoCD over Jenkins?").

*Note: You mentioned "Banking" in your intro, but the code is E-commerce (cart, catalog, payment). If they ask for your architecture, you map it mentally: Catalog = Account Service, Cart = Transaction Queue, Payment = Payment Gateway.*

---

## 🏗️ Phase 1: Architecture & System Design
*After your introduction, they will immediately ask you to explain your project.*

**1. "You mentioned you manage infrastructure for microservices. Can you walk me through the architecture of a request coming from a user to your backend?"**
> "Sure. When a user makes a request, it hits our Cloud Load Balancer which routes traffic to our **Istio Ingress Gateway** inside our GKE cluster. Istio acts as our service mesh. The VirtualService routes `/api` traffic to our **API Gateway (FastAPI)**. From there, the API Gateway communicates with our backend microservices (like the account/catalog service or payment service) using **mTLS** enforced by Istio. Our stateful data is stored securely in **Google Cloud SQL (PostgreSQL)**, and the pods authenticate to GCP services using **Workload Identity** rather than static JSON keys."

**2. "Why did you decide to use Istio Service Mesh instead of standard Kubernetes networking?"**
> "We needed two things for our banking/finance requirements: **Zero-Trust Security** and **Observability**. With standard K8s, pods can talk to each other in plain text. By injecting the Istio sidecar (Envoy proxy), we enforced **STRICT mTLS**, meaning all pod-to-pod communication is encrypted. It also gave us out-of-the-box distributed tracing without having to heavily modify our application code."

**3. "You mentioned you achieved 99.95% SLA. How exactly did you configure GKE to ensure that high availability?"**
> "We implemented three main K8s native strategies:
> 1. **Horizontal Pod Autoscalers (HPA)** to scale pods dynamically based on CPU/Memory thresholds.
> 2. **Topology Spread Constraints & Anti-Affinity** to ensure our replicas are spread across different GCP Availability Zones (us-central1-a, b, c). If one zone goes down, the application stays up.
> 3. Strict **Readiness and Liveness probes** so the Load Balancer never routes traffic to a pod that isn't fully initialized."

---

## 🔄 Phase 2: CI/CD & GitOps
*They will test your knowledge of how code actually gets to production.*

**4. "Walk me through your CI/CD pipeline. What happens when a developer pushes code?"**
> "We use a decoupled CI/CD approach. 
> For CI, we use **GitHub Actions**. When a developer merges a PR, the Action runs unit tests, performs security scans using **Trivy**, builds the Docker image, and pushes it to **GCP Artifact Registry**. Then, the Action updates the Kubernetes manifest with the new image tag.
> For CD, we use **ArgoCD (GitOps)**. ArgoCD constantly monitors the Git repository. When it sees the updated image tag in the manifests, it automatically reconciles and pulls the new state into the GKE cluster."

**5. "Why use ArgoCD? Why not just have GitHub Actions run `kubectl apply`?"**
> "Using `kubectl apply` from a CI pipeline is a push-based model, which requires giving the CI server administrative cluster credentials. That's a security risk. **ArgoCD is pull-based**. It sits inside the cluster and pulls from Git. Additionally, if someone manually edits a deployment in the console (configuration drift), ArgoCD will instantly detect it and self-heal the cluster back to the Git state."

**6. "Since you are using GitOps, all your manifests are in Git. How do you handle sensitive passwords like database credentials so they aren't exposed in GitHub?"**
> "We strictly follow zero-trust. We do not store any Base64 encoded secrets in Git. Instead, we use the **External Secrets Operator (ESO)**. We store the actual passwords in **GCP Secret Manager**. ESO runs in the cluster, authenticates via Workload Identity, fetches the secret from GCP, and injects it into a native Kubernetes Secret dynamically. Git only contains the 'ExternalSecret' custom resource definition."

---

## 🌍 Phase 3: Infrastructure as Code (Terraform)
*Testing your knowledge of state and modularity.*

**7. "You used Terraform for your GCP infrastructure. How did you structure your Terraform code?"**
> "I used a modular approach. Instead of a monolithic `main.tf`, I created reusable modules for the **VPC, GKE cluster, and Cloud SQL**. In the environment folder (like `envs/prod`), I call these modules. This allows us to easily spin up a staging environment that mirrors production just by passing different variables."

**8. "How did you manage the Terraform State file, especially working in a team?"**
> "We store the Terraform state remotely in a **GCS (Google Cloud Storage) bucket** with versioning enabled. This prevents the state from being stored locally on developer machines. (Note: In AWS, I would use S3 with DynamoDB for state locking, but GCP handles locking natively through GCS)."

---

## 🔍 Phase 4: SRE, Day-2 Operations & Python/Bash
*This validates your "30% manual effort reduction" claim.*

**9. "You mentioned building Python/Bash scripts to automate cloud operations. Can you give me an example of a script you wrote?"**
> "Yes, one major issue we had was cloud storage costs creeping up from old logs and database backups. I wrote a **Python script using the `google-cloud-storage` library (Boto3 equivalent for GCP)**. The script runs as a cron job, checks the creation dates of objects in our backup buckets, and automatically moves objects older than 30 days to **Coldline storage**, and deletes objects older than 90 days. This directly contributed to our cost optimization goals."

**10. "If an alert fires saying the 'Payment Service' is returning 500 errors, what are the exact steps you take to troubleshoot?"**
> 1. First, I check the **Grafana dashboard** to see if there is a CPU/Memory spike or if the database connections are exhausted.
> 2. Then, I use `kubectl get pods -n ecommerce` to see if the payment pods are crashing or stuck in a CrashLoopBackOff.
> 3. I check the logs using `kubectl logs -l app=payment-service --tail=100` to find the exact Python traceback.
> 4. If the error is network-related, I check **OpenTelemetry/GCP Cloud Trace** to see where the latency or failure happened (e.g., did the API Gateway timeout waiting for the Payment service?).
> 5. If it was a bad deployment, I simply go to the ArgoCD UI and click **Rollback** to the previous working Git commit.

---

## 🎯 Behavioral / Closing
**11. "What was the most challenging technical issue you faced in this project?"**
> "The hardest part was implementing **Workload Identity** and transitioning away from static service account keys. Initially, our pods couldn't authenticate to Cloud SQL because the Kubernetes Service Account wasn't properly bound to the GCP Service Account. I had to deep-dive into IAM policy bindings and annotate the K8s service accounts correctly. It took time to debug the IAM permissions, but it massively improved our security posture."
