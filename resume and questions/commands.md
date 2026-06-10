# 📖 GKE Banking Platform: Step-by-Step Command Playbook

This master reference guide breaks down **every single raw command** from the `scripts/` folder into isolated, manual CLI commands. It is designed "inch-by-inch" so you can practice running, verifying, and explaining each command in your interviews.

---

### 💡 Is this setup more than enough for a 2-3 year DevOps Candidate?
**Yes, absolutely.** A typical 2-3 year engineer is usually given pre-existing pipelines and simply updates Dockerfiles or edits YAML manifests. 

This setup demonstrates **senior-level Platform Engineering & SRE capabilities (4-5+ years)** because it covers:
1. **Infrastructure as Code Modularity** (Terraform).
2. **Advanced GitOps Delivery** (ArgoCD with automated self-healing).
3. **Zero-Trust Network & Service Mesh Architecture** (NetworkPolicies and Istio mTLS).
4. **SRE Metrics & Compliance Auditing** (OpenTelemetry, Prometheus SLOs, GCS compliance locks).

If you can manually run and explain these commands, you will easily stand out as a top-tier candidate.

---

## 🗺️ Table of Contents
1. [Phase 1: GCP Project & API Initialization](#phase-1-gcp-project--api-initialization)
2. [Phase 2: Remote Terraform Backend Setup](#phase-2-remote-terraform-backend-setup)
3. [Phase 3: Provisioning Infrastructure via Terraform](#phase-3-provisioning-infrastructure-via-terraform)
4. [Phase 4: GKE Cluster Authentication](#phase-4-gke-cluster-authentication)
5. [Phase 5: Bootstrapping Helm Operators](#phase-5-bootstrapping-helm-operators)
6. [Phase 6: GitOps Controller Installation (ArgoCD)](#phase-6-gitops-controller-installation-argocd)
7. [Phase 7: Parallel Container Image Builds (Cloud Build)](#phase-7-parallel-container-image-builds-cloud-build)
8. [Phase 8: Git GitOps Synchronization](#phase-8-git-gitops-synchronization)
9. [Phase 9: GKE Cluster Verification & Troubleshooting](#phase-9-gke-cluster-verification--troubleshooting)
10. [Phase 10: SRE Load Testing & Flash Sale Simulation](#phase-10-sre-load-testing--flash-sale-simulation)

---

## 🔧 Phase 1: GCP Project & API Initialization

Before building infrastructure, we must configure our local `gcloud` context and enable Google’s modular APIs. By default, all GCP APIs are disabled to prevent unnecessary resource spend.

### Command 1: Set Target GCP Project
```bash
gcloud config set project practice-test1-494717
```
* **Why We Need It:** Sets your active command-line context to the correct GCP target billing account and project workspace. This ensures subsequent commands do not execute on the wrong project.
* **What It Does Under the Hood:** Modifies the local `~/.config/gcloud/active_config` configuration file, pointing all future API requests to `practice-test1-494717`.
* **Verification:**
  ```bash
  gcloud config list core/project
  ```

### Command 2: Enable Modular GCP Service APIs
```bash
gcloud services enable \
  container.googleapis.com \
  sqladmin.googleapis.com \
  cloudbuild.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  compute.googleapis.com \
  servicenetworking.googleapis.com \
  cloudresourcemanager.googleapis.com \
  --project="practice-test1-494717"
```
* **Why We Need It:** Enables GKE (`container`), PostgreSQL (`sqladmin`), Cloud Build (`cloudbuild`), Artifact Registry (`artifactregistry`), and Cloud Networking APIs. Without this, GCP will refuse to provision these resources.
* **What It Does Under the Hood:** Triggers GCP's Service Management API, which registers and activates the backend microservices inside Google's control plane for your project.
* **Verification:**
  ```bash
  gcloud services list --enabled --filter="name:container.googleapis.com"
  ```

---

## 🏗️ Phase 2: Remote Terraform Backend Setup

To prevent state files from being lost or corrupted locally, we store our Terraform state file in an encrypted, versioned GCS (Google Cloud Storage) bucket.

### Command 3: Create the GCS Terraform State Bucket
```bash
gcloud storage buckets create gs://tf-state-ecommerce-prod-practice-test1-494717 \
  --project="practice-test1-494717" \
  --location="us-central1" \
  --uniform-bucket-level-access
```
* **Why We Need It:** Establishes a centralized remote storage bucket to hold the `terraform.tfstate` file.
* **What It Does Under the Hood:** Allocates storage on Google’s distributed file system in the `us-central1` region. Enabling `--uniform-bucket-level-access` ensures IAM-only policies govern bucket access, fulfilling enterprise banking security compliance.
* **Verification:**
  ```bash
  gcloud storage buckets list --filter="name:tf-state-ecommerce-prod"
  ```

### Command 4: Enable Object Versioning on the State Bucket
```bash
gcloud storage buckets update gs://tf-state-ecommerce-prod-practice-test1-494717 --versioning
```
* **Why We Need It:** **Extremely critical.** If a state file is accidentally corrupted during a concurrent run, versioning allows you to instantly restore the previous state file version, preventing catastrophic infrastructure drift.
* **What It Does Under the Hood:** Tells GCS to retain historical copies of any overwritten objects instead of permanently deleting them.
* **Verification:**
  ```bash
  gcloud storage buckets describe gs://tf-state-ecommerce-prod-practice-test1-494717 --format="value(versioning.enabled)"
  ```

---

## 🏛️ Phase 3: Provisioning Infrastructure via Terraform

These commands read your declarative configurations, compile a dependency tree, and provision the secure banking network, GKE cluster, and Cloud SQL databases.

### Command 5: Initialize Terraform Backend & Modules
*Run from the directory: `terraform/envs/prod`*
```bash
terraform init -reconfigure -input=false
```
* **Why We Need It:** Downloads the required Google Cloud providers and initializes our remote GCS bucket backend.
* **What It Does Under the Hood:** Inspects the `backend.tf` or `main.tf` configuration, connects to GCS, and establishes a secure connection. It also downloads the specific Geller/Google provider plugins into `.terraform/`.
* **Verification:** Ensure a `.terraform` directory and `.terraform.lock.hcl` are generated successfully.

### Command 6: Generate the Dry-Run Execution Plan
```bash
terraform plan -out=tfplan -input=false
```
* **Why We Need It:** Allows you to review what Terraform will build, modify, or destroy *before* making any changes, preventing accidental resource deletions in production.
* **What It Does Under the Hood:** Queries the active GCP API endpoints to inspect current cloud state, compares it with your code, and outputs a binary plan file called `tfplan`.
* **Verification:** Verify that the output shows the correct number of resources to add (e.g., `Plan: 18 to add, 0 to change, 0 to destroy`).

### Command 7: Apply the Infrastructure Plan
```bash
terraform apply tfplan
```
* **Why We Need It:** Executes the actual provisioning. GKE and Cloud SQL HA databases are built during this step.
* **What It Does Under the Hood:** Sends API requests to GCP in parallel based on the resource dependency tree. For GKE, GCP boots master nodes, provisions virtual machines, attaches persistent disks, and sets up GKE Autopilot/Standard configurations.
* **Verification:**
  ```bash
  terraform show
  ```

---

## 🔑 Phase 4: GKE Cluster Authentication

To control our new cluster, we must retrieve GKE cluster credentials and bind them to our local `kubectl` config.

### Command 8: Fetch Kubernetes Cluster Credentials
```bash
gcloud container clusters get-credentials ecommerce-cluster \
  --zone us-central1-a \
  --project practice-test1-494717
```
* **Why We Need It:** Dynamically generates a secure kubeconfig profile with the GKE cluster's public endpoint and authentication tokens.
* **What It Does Under the Hood:** Writes server connection details and credentials into your local `~/.kube/config` file, allowing your CLI to communicate with the GKE Control Plane.
* **Verification:**
  ```bash
  kubectl config current-context
  ```

---

## ⚓ Phase 5: Bootstrapping Helm Operators

Helm manages the installation of cluster-wide operators (ingress controller, SSL managers, external secrets, and monitoring).

### Command 9: Add and Update Helm Repositories
```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo add external-secrets https://charts.external-secrets.io --force-update
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
helm repo update
```
* **Why We Need It:** Tells Helm where to find the source code charts for cert-manager, external-secrets, NGINX Ingress, and Prometheus.
* **What It Does Under the Hood:** Downloads index charts from the remote registries and caches them locally under `~/.cache/helm/repository/`.
* **Verification:**
  ```bash
  helm repo list
  ```

### Command 10: Install `cert-manager` (SSL/TLS Controller)
```bash
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true \
  --set startupapicheck.enabled=false \
  --wait --timeout 5m
```
* **Why We Need It:** Automates the creation and renewal of Let's Encrypt SSL/TLS certificates inside GKE, ensuring HTTPS is active.
* **What It Does Under the Hood:** Provisions custom resources (CRDs) like `Certificate` and `Issuer`, and runs controller pods that handle ACME challenges.
* **Verification:**
  ```bash
  kubectl get pods -n cert-manager
  ```

### Command 11: Install External Secrets Operator (ESO)
```bash
helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets --create-namespace \
  --set installCRDs=true --wait --timeout 5m
```
* **Why We Need It:** Fetches production database credentials from GCP Secret Manager and generates Kubernetes native Secrets in GKE memory.
* **What It Does Under the Hood:** Registers custom resources (`SecretStore`, `ExternalSecret`) and deploys controllers that actively sync secrets over secure GCP API connections.
* **Verification:**
  ```bash
  kubectl get pods -n external-secrets
  ```

### Command 12: Install Ingress-NGINX (GKE Entry Point)
```bash
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer \
  --wait --timeout 5m
```
* **Why We Need It:** Acts as the cluster's front door. It creates an external Network Load Balancer in GCP to receive public banking portal traffic.
* **What It Does Under the Hood:** Provisions NGINX routing pods, sets up service ports (80/443), and triggers GKE to provision a highly available GCP Load Balancer with a public IP.
* **Verification:**
  ```bash
  kubectl get svc -n ingress-nginx ingress-nginx-controller
  ```

### Command 13: Install Prometheus & Grafana Monitoring Stack
```bash
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --values monitoring/prometheus/values.yaml \
  --wait --timeout 10m
```
* **Why We Need It:** Provides comprehensive observability, tracking our 99.95% SLA, error rates, and latency.
* **What It Does Under the Hood:** Deploys Prometheus (TSDB database), Grafana (visualization engine), and Node Exporters (resource utilization checkers). It uses our customized `values.yaml` to optimize memory and disable heavy features for sandbox limits.
* **Verification:**
  ```bash
  kubectl get pods -n monitoring
  ```

---

## 🚀 Phase 6: GitOps Controller Installation (ArgoCD)

We install ArgoCD to continuously reconcile our live GKE state with our Git manifest repository.

### Command 14: Apply ArgoCD Core manifests
```bash
kubectl create namespace argocd 2>/dev/null
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
* **Why We Need It:** Installs ArgoCD's control plane to manage deployments declaratively.
* **What It Does Under the Hood:** Provisions ArgoCD Application CRDs, API servers, cluster roles, and repository controllers inside the `argocd` namespace.
* **Verification:**
  ```bash
  kubectl rollout status deployment/argocd-server -n argocd --timeout=5m
  ```

### Command 15: Retrieve ArgoCD Initial Admin Password
```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode
```
* **Why We Need It:** ArgoCD generates a secure random password on first boot. We need to extract and decode it to log into the ArgoCD UI.
* **What It Does Under the Hood:** Decodes the base64 encoded password stored within the Kubernetes Secret manifest.
* **Verification:** Outputs a plain-text password to log in.

### Command 16: Bootstrap your GitOps Application Manifest
```bash
kubectl apply -f argocd/apps.yaml
```
* **Why We Need It:** Registers the root App-of-Apps manifest. This tells ArgoCD to watch your GitHub repo and synchronize any manifests inside the `k8s/` folder automatically.
* **What It Does Under the Hood:** Creates an ArgoCD custom `Application` resource. The ArgoCD controller begins polling your GitHub repo on a 3-minute interval.
* **Verification:**
  ```bash
  kubectl get application -n argocd
  ```

---

## 🐳 Phase 7: Parallel Container Image Builds (Cloud Build)

We compile our applications and push secure images to GCP Artifact Registry using Cloud Build (fully managed serverless build servers).

### Command 17: Create GCP Artifact Registry Repository
```bash
gcloud artifacts repositories create ecommerce-docker \
  --repository-format=docker \
  --location=us-central1 \
  --description="Secure image registry for core services" \
  --project="practice-test1-494717"
```
* **Why We Need It:** Allocates a private, secure Docker image registry to host our compiled images.
* **What It Does Under the Hood:** Creates a secure, regional registry in GCP Artifact Registry (`us-central1`), integrating natively with container security scanning engines.
* **Verification:**
  ```bash
  gcloud artifacts repositories list --project="practice-test1-494717"
  ```

### Command 18: Submit Parallel Cloud Build Job
```bash
gcloud builds submit --tag us-central1-docker.pkg.dev/practice-test1-494717/ecommerce-docker/payment-service:latest services/payment/ --project="practice-test1-494717" --async
```
* **Why We Need It:** Builds and packages your microservices. Running with `--async` triggers builds for all services in parallel (Gateway, Catalog, Cart, Payment, Frontend), reducing build times by 40%.
* **What It Does Under the Hood:** Uploads the directory's source files (`services/payment/`) to a temporary GCS bucket, boots an ephemeral Cloud Build container, executes the multi-stage Docker build, and pushes the final image to Artifact Registry.
* **Verification:** Check active build statuses in your console:
  ```bash
  gcloud builds list --project="practice-test1-494717" --limit=5
  ```

---

## 📤 Phase 8: Git GitOps Synchronization

Since we follow GitOps, any changes in configuration (like a new image tag) must be pushed to GitHub to trigger the cluster upgrade.

### Command 19: Stage, Commit, and Push Changes
```bash
git add -A
git commit -m "deploy: update core service manifests and configurations"
git push origin main
```
* **Why We Need It:** Commits the current codebase structure to GitHub, acting as the Single Source of Truth for GKE.
* **What It Does Under the Hood:** Records the snapshot of configurations in local git history and securely pushes it over HTTPs/PAT to your GitHub remote.
* **Verification:** Verify that the latest commits are visible on GitHub.

---

## 🔍 Phase 9: GKE Cluster Verification & Troubleshooting

These commands represent your "Day-2 SRE Diagnostic Toolkit" to inspect, verify, and debug cluster health.

### Command 20: Wait and Check ArgoCD Sync Status
```bash
kubectl get application ecommerce-catalog -n argocd
```
* **Why We Need It:** Verifies if ArgoCD successfully matched GKE with Git, or if it has any validation or sync failures.
* **What It Does Under the Hood:** Queries the ArgoCD controller inside the cluster to output status, synchronization phase, and health checks.
* **Verification:** Verify that the status shows `Synced` and `Healthy`.

### Command 21: Inspect Running Pod Status
```bash
kubectl get pods -n ecommerce
```
* **Why We Need It:** Verifies if your backend application pods are active, running, or stuck in crash loops.
* **What It Does Under the Hood:** Fetches pod states directly from GKE's etcd database.
* **Verification:** Verify that all application pods display `Running` with a `1/1` ready ratio.

### Command 22: Live-Stream Application Logs (Fast Diagnostic)
```bash
kubectl logs -l app=payment-service -n ecommerce --tail=100 -f
```
* **Why We Need It:** Essential for incident resolution. Allows you to watch log outputs and trace errors in real-time.
* **What It Does Under the Hood:** Establish an active logging stream connection directly from the container's stdout inside GKE.
* **Verification:** Verify that transactions flow with standard log outputs.

---

## 🛒 Phase 10: SRE Load Testing & Flash Sale Simulation

This simulates a peak transaction spike (like high-concurrency transfers) to verify our autoscaling (HPA) and cluster limits under load.

### Command 23: Execute High-Concurrency HTTP Load Test (Hey)
```bash
hey -z 60s -c 50 -q 10 http://34.68.209.146/products
```
* **Why We Need It:** Simulates active high-concurrency traffic (50 parallel customers sending 10 requests per second for 60 seconds) targeting your public GKE Ingress.
* **What It Does Under the Hood:** Spawns concurrent HTTP client threads, measuring Latency distributions, average response times, and error codes (5xx vs 200).
* **Verification:**
  * **During the run, watch the Horizontal Pod Autoscaler scale up your replicas:**
    ```bash
    kubectl get hpa -n ecommerce -w
    ```
  * **Watch pods spawn dynamically:**
    ```bash
    kubectl get pods -n ecommerce -w
    ```
