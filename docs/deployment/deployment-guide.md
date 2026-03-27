# 🚀 GCP Deployment Guide — E-Commerce Platform

This guide provides the exact commands to deploy the entire stack to your GCP project: **my-project-32062-newsletter**.

---

## 📋 Prerequisites
Ensure you have the following installed:
- `gcloud` CLI
- `terraform`
- `kubectl`
- `helm`

---

## 🛠️ Step 1: Initial GCP Setup
This script enables required APIs and creates a Service Account for GitHub Actions.

```bash
# Set your project ID
export PROJECT_ID="my-project-32062-newsletter"

# Authenticate both gcloud AND Application Default Credentials (ADC)
gcloud auth login
gcloud auth application-default login

# Run the setup script
chmod +x scripts/setup-gcp.sh
./scripts/setup-gcp.sh $PROJECT_ID
```
> [!IMPORTANT]
> This script will generate a `github-sa-key.json` file. Follow the instructions in the output to add this to your GitHub Secrets, then **delete the file**.

---

## 🏗️ Step 2: Infrastructure Provisioning (Terraform)
First, we need to create the GCS bucket for Terraform state, then provision the VPC, GKE, and Cloud SQL.

### 2.1 Setup Remote State
```bash
chmod +x scripts/setup-backend.sh
./scripts/setup-backend.sh $PROJECT_ID
```

### 2.2 Terraform Config (tfvars)
I have already created a `terraform.tfvars` file for you in `terraform/envs/prod/`. You can edit it to change your region or database password if you wish.

### 2.3 Terraform Apply
```bash
cd terraform/envs/prod

# Initialize with the backend
terraform init

# Plan and Apply will now use your terraform.tfvars automatically!
terraform plan
terraform apply
```

---

## ☸️ Step 3: GKE Connectivity & Secret Management
Once Terraform finishes, your cluster is up, but it's an empty shell. We need to connect to it and securely inject the database credentials.

### 3.1 Connect to Cluster
```bash
# Get credentials for kubectl
gcloud container clusters get-credentials ecommerce-cluster \
  --region us-central1 --project $PROJECT_ID
```
*   **What**: Downloads the kubeconfig file and credentials for your GKE cluster.
*   **Why**: Your local `kubectl` doesn't know how to talk to the new cluster yet. This command bridges that gap by setting up the authentication context.

### 3.2 Securely Creating Application Secrets
```bash
# Create the namespace for the apps
kubectl create namespace ecommerce || true
```
*   **What**: Creates a logical isolation boundary named `ecommerce`.
*   **Why**: In production, you never deploy everything to the `default` namespace. It's best practice for security and organization.

```bash
# Inject the Database Password as a K8s Secret
kubectl create secret generic postgres-secret \
  --namespace ecommerce \
  --from-literal=username=appuser \
  --from-literal=password="<DB_PASSWORD>" \
  --from-literal=database=catalog
```
*   **What**: Stores sensitive database credentials in an encrypted-at-rest format inside Kubernetes.
*   **Why**: Hardcoding passwords in YAML files is a security risk. By using a Secret, the application can "mount" these values as environment variables at runtime without them ever being in source control.

---

## 🐙 Step 4: Bootstrapping GitOps (ArgoCD)
We use a **"GitOps Pull"** model. Instead of us pushing code to GKE, ArgoCD "pulls" the desired state from Git.

### 4.1 Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
*   **What**: Creates the `argocd` namespace and applies the official manifest to install all ArgoCD components (Server, Controller, Repo Server).
*   **Why**: ArgoCD is the "brain" of our deployment. It continuously compares your Git repo to your Cluster state.

### 4.2 Access the Dashboard
```bash
# Get the admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
or
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | % { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```
*   **What**: Retrieves the auto-generated admin password from a K8s secret and decodes it from Base64.
*   **Why**: You need this to log into the web UI or CLI for the first time.

```bash
# Port-forward to access the UI at http://localhost:8080
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
*   **What**: Securely tunnels traffic from your local machine (port 8080) to the ArgoCD Service in the cluster.
*   **Why**: Since we haven't set up an external LoadBalancer for ArgoCD yet, this is the safest way to access the dashboard.
*   ### 4.3 The "App of Apps" Pattern
We don't deploy services one by one. We deploy a single "Root App" that manages all other applications in the `argocd/` folder.

> [!IMPORTANT]
> Before applying the next step, you **MUST** open `argocd/apps.yaml` and change the `repoURL` to point to **YOUR** GitHub repository. If you don't, ArgoCD will try to pull from a repository that doesn't exist.

```bash
# Apply the ArgoCD "App of Apps" manifest
kubectl apply -f argocd/apps.yaml
```

---

## 🌐 Step 5: Installing the Ingress Controller
ArgoCD deploys your *routing rules*, but your cluster still needs the *actual engine* to handle traffic. We use **NGINX Ingress Controller**.

```bash
# Add the Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install the controller
helm install ingress-nginx ingress-nginx/ingress-nginx `
  --namespace ingress-nginx --create-namespace `
  --set controller.service.type=LoadBalancer
```
*   **What**: Downloads the NGINX software and deploys it as a set of Pods in the `ingress-nginx` namespace.
*   **Why**: GKE doesn't come with an Ingress Controller by default. This creates the **GCP External Load Balancer** that gives you your public entry point.

---

## 🛠️ Step 5.1: Installing Platform Controllers (Cert-Manager & External-Secrets)
ArgoCD is currently in an `OutOfSync` or `Missing` state because your manifests use custom resource types (`Certificate`, `ExternalSecret`) that the cluster doesn't recognize yet. You must install the "engines" for these services:

### A. Cert-Manager (For HTTPS/TLS)
```powershell
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager `
  --namespace cert-manager --create-namespace `
  --set installCRDs=true
```
*   **What**: Installs a controller that automatically manages SSL/TLS certificates.
*   **Why**: Required for the `Certificate` and `ClusterIssuer` resources in the `k8s/security` folder. This handles your automated HTTPS renewal.

### B. External Secrets (For GCP Secret Manager integration)
```powershell
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets `
  --namespace external-secrets --create-namespace `
  --set installCRDs=true
```
*   **What**: A bridge between Google Secret Manager and your K8s cluster.
*   **Why**: Securely syncs your passwords/keys stored in GCP into the cluster without you having to manually run `kubectl create secret`.

---

## 🚀 Step 6: The "Inch-by-Inch" CI/CD Flow
This is the "Golden Thread" of modern DevOps. Here is exactly what happens:

1.  **Code Push**: 
    *   *Action*: Developer pushes code to `services/catalog-service/`.
    *   *Why*: Centralizes collaboration in GitHub.
2.  **GitHub Actions**: 
    *   *Action*: `.github/workflows/catalog.yaml` triggers.
    *   *Why*: Automates the build process (CI) to ensure no manual steps are needed.
3.  **Build & Test**: 
    *   *Action*: Docker build creates a new container image.
    *   *Why*: Ensures the application is packaged with all its dependencies.
4.  **Secure Push**: 
    *   *Action*: Image is pushed to **GCP Artifact Registry**.
    *   *Why*: Cloud-native way to store images securely within your project boundary.
5.  **Manifest Update**: 
    *   *Action*: CI script updates the image tag in `k8s/catalog-service/deployment.yaml`.
    *   *Why*: This is the trigger for GitOps. ArgoCD only reacts when the **Git repository** changes.
6.  **ArgoCD Detection**: 
    *   *Action*: ArgoCD polls the Git repo every 3 minutes.
    *   *Why*: Decouples the CI (Building) from the CD (Deploying).
7.  **Automated Sync**: 
    *   *Action*: ArgoCD updates the Pods in GKE.
    *   *Why*: Guaranteed consistency. If a Pod crashes or someone manually changes something in the cluster, ArgoCD will revert it back to the state defined in Git.

---

## 🔍 Step 6: Verification & Observability

### 6.1 Check Application Status
```bash
kubectl get pods -n ecommerce -w
```
*   **What**: Lists all pods in the ecommerce namespace and "watches" (-w) for changes.
*   **Why**: Allows you to see the real-time rollout (ContainerCreating -> Running).

```bash
kubectl get svc -n ingress-nginx
```
*   **What**: Retrieves the status of the NGINX Ingress Controller.
*   **Why**: You are looking for the `EXTERNAL-IP`. This is the single entry point for your entire e-commerce site.

### 6.2 View Logs (The "Prod" way)
*   **Command**: GCP Console -> Logs Explorer -> `resource.type="k8s_container"`
*   **Why**: In a cluster with hundreds of pods, `kubectl logs` is too slow. Cloud Logging aggregates everything, allowing you to search across multiple services at once.

---

## 🏁 Your Deployment is Live!
Once the Ingress LoadBalancer provides an external IP, you can access your API Gateway at that IP.
For production, map your domain (e.g., `shop.yourdomain.com`) to this IP in your DNS provider.
