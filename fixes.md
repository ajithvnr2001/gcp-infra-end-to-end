# 🛠️ Terraform Fixes — Root Cause Analysis

I have analyzed the errors in your `error.md` and identified the following fixes:

### 1. Global Bucket Name Conflict (409)
**Problem**: Google Cloud Storage bucket names are globally unique. `tf-state-ecommerce-prod` is already taken by another user.
**Fix**: Updated `main.tf` and `setup-backend.sh` to use a unique name: `tf-state-ecommerce-prod-my-project-32062-newsletter`.

### 2. Network Already Exists (409)
**Problem**: Terraform is trying to create the VPC named `prod-ecommerce-vpc`, but it already exists from a previous partial run. Since your state file is currently "empty" in the new bucket, Terraform doesn't know it already owns that VPC.

**Fix (Option A - Recommended for Clean Start)**:
I have created a dedicated cleanup script that handles all resource dependencies (firewalls, routers, subnets) in the correct order.
```bash
chmod +x scripts/cleanup-gcp.sh
./scripts/cleanup-gcp.sh my-project-32062-newsletter
```

**Fix (Option B - Import)**:
Tell Terraform to "adopt" the existing VPC into its state.
```bash
cd terraform/envs/prod
terraform import module.vpc.google_compute_network.vpc projects/my-project-32062-newsletter/global/networks/prod-ecommerce-vpc
```

### 3. Redundant Bucket Resource
**Problem**: I previously had a `resource "google_storage_bucket"` in `main.tf`. This was causing a conflict because the `setup-backend.sh` script already creates the bucket for you.
**Fix**: I have removed that resource from `main.tf`.

---

## 📋 Next Steps to Deploy

1. **Delete any partial local state** (optional but safer):
   ```bash
   rm -rf .terraform/ .terraform.lock.hcl
   ```

2. **Run the updated Backend Setup**:
   ```bash
   chmod +x scripts/setup-backend.sh
   ./scripts/setup-backend.sh my-project-32062-newsletter
   ```

3. **Re-initialize Terraform**:
   ```bash
   cd terraform/envs/prod
   terraform init -reconfigure
   ```

4. **Deploy again**:
   ```bash
   terraform apply
   ```

---

# 🚀 GKE & ArgoCD Deployment Fixes (Added today)

I have identified and fixed the following issues preventing your microservices from appearing in the cluster:

### 1. Cluster Context Mismatch (403/NotFound)
**Problem**: Your `kubectl` was accidentally pointing to an old cluster (`gke_youtube-292903_asia-south1_ha-ecommerce-cluster`). You could see ArgoCD but it was on the *wrong* project.
**Fix**: Re-connected your terminal to the new cluster:
```bash
gcloud container clusters get-credentials ecommerce-cluster --region us-central1 --project my-project-32062-newsletter
```

### 2. ArgoCD Directory Recursion
**Problem**: All your manifest files are in subfolders (e.g., `k8s/namespaces`, `k8s/deployments`). By default, ArgoCD only looks in the root of the `path: k8s` folder.
**Fix**: Updated `argocd/apps.yaml` to include `directory.recurse: true`.

### 3. Manifest Naming Conflict ("Appeared 2 times")
**Problem**: The file `k8s/monitoring/prometheus-scrape-patch.yaml` was defining the same `catalog-service` Deployment as the main file. This caused a sync conflict.
**Fix**: 
1. Merged the Prometheus annotations directly into `k8s/deployments/catalog-deployment.yaml`.
2. Deleted the conflicting `prometheus-scrape-patch.yaml` file.

### 4. Missing Platform Controllers (CRDs)
**Problem**: Your cluster was missing **Cert-Manager** and **External-Secrets**. Since your code uses `Certificate` and `ExternalSecret` types, ArgoCD was failing to sync because the cluster didn't understand those types.
**Fix**: Provided the Helm commands to install these controllers and their CRDs.

### 5. Git Push Permission (403 Forbidden)
**Problem**: Pushing via HTTPS with a password no longer works on GitHub.
**Fix**: Provided the instruction to use a **Personal Access Token (PAT)** in the remote URL to bypass the credential issue.

---

## ✨ Current Status: 
ArgoCD is now successfully tracking all **46 resources**. Once the platform controllers (Helm) are installed, your pods will turn green!
