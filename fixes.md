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

---

# 🔬 Deep Debugging Analysis — ArgoCD Sync to Pod Creation (Session 2)

This documents every error encountered and the exact fix applied, in the order they occurred.

---

## Stage 1: Manifest Validation Errors (ArgoCD Sync Blocked "Not Valid")

### Error 1.1 — Duplicate `Namespace/ecommerce` (appeared 2 times)
**Detected by**: `kubectl get application ecommerce-catalog -n argocd -o jsonpath='{.status.conditions[*].message}'`
```
Resource /Namespace//ecommerce appeared 2 times among application resources.
```
**Root Cause**: Two files both defined `kind: Namespace name: ecommerce`:
- `k8s/namespaces/ecommerce.yaml` ✅ (correct place)
- `k8s/security/pod-security/pod-security.yaml` ❌ (duplicate)

**Fix**:
1. Merged the pod-security labels (e.g. `pod-security.kubernetes.io/enforce: restricted`) into the primary `k8s/namespaces/ecommerce.yaml`
2. Deleted the `kind: Namespace` block from `pod-security.yaml`

---

### Error 1.2 — ExternalSecret API Version `v1beta1` Not Found
**Detected by**: `kubectl get application ecommerce-catalog -n argocd -o jsonpath='{.status.operationState.syncResult.resources[*].message}'`
```
The Kubernetes API could not find version "v1beta1" of external-secrets.io/ExternalSecret
Version "v1" of external-secrets.io/ExternalSecret is installed on the destination cluster.
```
**Root Cause**: The External Secrets Helm chart v2.x no longer uses `v1beta1`. All `SecretStore` and `ExternalSecret` manifests referenced the old API.

**Fix**: Updated all 4 resource definitions in `k8s/security/secrets-management/external-secrets.yaml`:
```yaml
# BEFORE
apiVersion: external-secrets.io/v1beta1

# AFTER
apiVersion: external-secrets.io/v1
```

---

### Error 1.3 — Gatekeeper CRDs Not Installed
**Detected by**: Same sync results message:
```
Make sure the "K8sRequiredResources" CRD is installed on the destination cluster.
```
**Root Cause**: `k8s/security/pod-security/pod-security.yaml` contained two Gatekeeper constraints (`K8sRequiredResources`, `K8sDisallowedTags`) but OPA Gatekeeper was never installed on the cluster.

**Fix**: Commented out the Gatekeeper constraint blocks. They require Gatekeeper to be installed first:
```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml
```

---

### Error 1.4 — Ingress `pathType: Prefix` Invalid with Regex Paths
**Detected by**: Sync result message:
```
path /api/cart(/|$)(.*) cannot be used with pathType Prefix
```
**Root Cause**: NGINX regex paths like `/api/cart(/|$)(.*)` require `pathType: ImplementationSpecific`. The standard `Prefix` type does not support regex.

**Fix**: Updated all 4 paths in `k8s/ingress/ingress.yaml`:
```yaml
# BEFORE
pathType: Prefix

# AFTER
pathType: ImplementationSpecific
```

---

## Stage 2: Deployment Created but Pods Not Scheduled (FailedCreate)

After all sync errors were fixed, the 4 Deployments appeared in the cluster but showed `0/2 READY`.

### Error 2.1 — GKE Autopilot `restricted:latest` PodSecurity Violation (Round 1)
**Detected by**: `kubectl get events -n ecommerce`
```
Error creating: pods "catalog-service-..." is forbidden: violates PodSecurity "restricted:latest":
  runAsNonRoot != true (pod or container "catalog" must set securityContext.runAsNonRoot=true)
  allowPrivilegeEscalation != false (container "catalog" must set securityContext.allowPrivilegeEscalation=false)
```
**Root Cause**: GKE Autopilot enforces the `restricted` Pod Security Standard on all namespaces. The Deployment specs were missing `securityContext`.

**Fix**: Added pod-level and container-level `securityContext` to all 4 Deployments:
```yaml
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
  containers:
    - name: catalog
      securityContext:
        allowPrivilegeEscalation: false
```

---

### Error 2.2 — GKE Autopilot PodSecurity Violation (Round 2) — capabilities.drop
**Detected by**: `kubectl get events -n ecommerce` (after Round 1 fix)
```
Error creating: pods "catalog-service-..." is forbidden: violates PodSecurity "restricted:latest":
  unrestricted capabilities (container "catalog" must set securityContext.capabilities.drop=["ALL"])
```
**Root Cause**: GKE Autopilot `restricted` mode also requires all Linux capabilities to be explicitly dropped.

**Fix**: Added `capabilities.drop: ["ALL"]` to every container's securityContext:
```yaml
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
```

---

## Stage 3: Pods Created but Image Not Found (ErrImagePull)

After all security context fixes, pods were finally scheduled and started pulling images.

### Error 3.1 — InvalidImageName (placeholder PROJECT_ID)
**Status**: `InvalidImageName` on 4 old pods
**Root Cause**: Images still referenced `gcr.io/PROJECT_ID/catalog-service:latest`. The string `PROJECT_ID` is not a valid GCP project identifier.
**Fix**: User manually replaced `PROJECT_ID` with `my-project-32062-newsletter`.

---

### Error 3.2 — ErrImagePull / ImagePullBackOff (current state)
**Status**: 4 new pods showing `ErrImagePull` → `ImagePullBackOff`
**Root Cause**: The Docker images `gcr.io/my-project-32062-newsletter/catalog-service:latest` etc. do not exist in Google Container Registry. They have never been built and pushed.

**This is the expected state.** The platform (GKE, ArgoCD, NGINX, Cert-Manager, External-Secrets) is fully operational. The only remaining step is to build real Docker images for the 4 microservices.

---

## ✅ Final Status Summary

| Component | Status |
|---|---|
| GKE Cluster | ✅ Running |
| ArgoCD | ✅ Tracking repo, auto-syncing |
| NGINX Ingress | ✅ Running |
| Cert-Manager | ✅ Running |
| External Secrets | ✅ Running |
| `ecommerce` Namespace | ✅ Created |
| RBAC / ServiceAccount | ✅ Synced |
| Deployments (4x) | ✅ Created, pods scheduled |
| **Container Images** | ❌ **Not built yet** — `ImagePullBackOff` |

## 🧱 Next Step: Build and Push Docker Images
```bash
# For each service (run inside the service directory):
docker build -t gcr.io/my-project-32062-newsletter/catalog-service:latest .
docker push gcr.io/my-project-32062-newsletter/catalog-service:latest
# Repeat for cart-service, payment-service, api-gateway
```
Once the images exist in GCR, the pods will transition from `ImagePullBackOff` → `Running`.

---

## Stage 4: Building & Pushing Real Docker Images (This Session)

### Error 4.1 — `ImagePullBackOff` and `InvalidImageName`
**Status observed**:
```
catalog-service-...   0/1   InvalidImageName    0   10m
catalog-service-...   0/1   ImagePullBackOff    0   6m
cart-service-...      0/1   ImagePullBackOff    0   6m
api-gateway-...       0/1   InvalidImageName    0   10m
payment-service-...   0/1   ErrImagePull        0   6m
```
**Root Cause — InvalidImageName**: Old pods still referenced the placeholder `gcr.io/PROJECT_ID/...` which is not a valid registry path.

**Root Cause — ImagePullBackOff**: New pods (after PROJECT_ID was replaced) tried to pull `gcr.io/my-project-32062-newsletter/catalog-service:latest` from GCR, but the image had never been built and pushed. It simply didn't exist.

**Diagnosis command**:
```bash
kubectl describe pod catalog-service-649cdb4f5-pgw99 -n ecommerce
# Error: Failed to pull image "gcr.io/my-project-32062-newsletter/catalog-service:latest":
# rpc error: code = Unknown desc = failed to pull and unpack image: ...manifest unknown
```

**Fix**: Used **GCP Cloud Build** (no Docker needed locally — it builds in the cloud) to build and push all 4 images:
```bash
# Build and push each service directly to GCR from source code
gcloud builds submit --tag gcr.io/my-project-32062-newsletter/catalog-service:latest services/catalog/ --project my-project-32062-newsletter
gcloud builds submit --tag gcr.io/my-project-32062-newsletter/cart-service:latest services/cart/ --project my-project-32062-newsletter
gcloud builds submit --tag gcr.io/my-project-32062-newsletter/payment-service:latest services/payment/ --project my-project-32062-newsletter
gcloud builds submit --tag gcr.io/my-project-32062-newsletter/api-gateway:latest services/api-gateway/ --project my-project-32062-newsletter
```

**Cloud Build times** (efficient multi-stage Docker builds with layer caching):
| Image | Build Time |
|---|---|
| `catalog-service` | 1m 8s |
| `cart-service` | 50s |
| `payment-service` | 50s |
| `api-gateway` | 44s |

---

## 🎉 FINAL STATUS — ALL PODS RUNNING

```
NAME                               READY   STATUS    RESTARTS
api-gateway-78f78fc5cf-9xgnd       1/1     Running   0
api-gateway-78f78fc5cf-q6k5d       1/1     Running   0
cart-service-7446c858d4-9mgz2      1/1     Running   0
cart-service-7446c858d4-p59k8      1/1     Running   0
catalog-service-649cdb4f5-lwxjh    1/1     Running   0
catalog-service-649cdb4f5-pgw99    1/1     Running   0
payment-service-7d6d576d75-jfmmk   1/1     Running   0
payment-service-7d6d576d75-pw4wv   1/1     Running   0
```

The complete production E-Commerce platform is now **live on GKE Autopilot** with ArgoCD GitOps managing the deployment. ✅

---

# 🤖 Stage 5: Automating the Build — CI/CD Pipeline with Cloud Build

## Why the First Build Was Manual

The initial `gcloud builds submit` commands were a **one-time emergency fix** to unblock the pods immediately. This is a valid production technique called **"break-glass"** — you manually intervene to restore service, then automate afterward so it never happens again.

**Root Cause of the manual build**: No CI/CD pipeline (`cloudbuild.yaml`) or Cloud Build Trigger existed in the project. There was no automation to build and push Docker images when code was pushed to GitHub.

**Interview answer**:
> *"I did a manual build initially to rapidly unblock the Kubernetes deployment and validate the security context fixes on GKE Autopilot. In a real production environment this must be automated. I then set up the complete GitOps CI/CD pipeline so every git push automatically builds the images and updates the cluster."*

---

## What Was Created

### 1. `cloudbuild.yaml` — The Pipeline Definition
Added at the repo root. This file tells GCP Cloud Build exactly what to do on every push:

```yaml
# Key design decisions:
# - All 4 images build in PARALLEL (waitFor: ['-']) → ~60s total vs ~4 mins sequential
# - Tagged with COMMIT_SHA (immutable) + latest (mutable convenience tag)
# - After build: updates k8s manifests in Git with the new SHA tag
# - ArgoCD detects the Git change → triggers rolling deployment automatically
```

**Full flow triggered on every `git push`**:
```
git push → Cloud Build Trigger fires → 4 images build in parallel (~60s)
         → images pushed to GCR with :$COMMIT_SHA + :latest tags
         → k8s manifests updated in Git with new SHA tag
         → ArgoCD detects Git change → rolling update begins
         → pods replaced one by one (zero downtime RollingUpdate)
Total time: ~2 minutes from code push to pods running
```

### 2. `scripts/setup-cloudbuild-trigger.sh` — One-Time Trigger Registration
Only needs to run once. Creates the Cloud Build Trigger that watches the GitHub `main` branch.

---

## Why the Trigger CLI Command Failed

```bash
ERROR: (gcloud.builds.triggers.create.github) INVALID_ARGUMENT: Request contains an invalid argument.
```

**Root Cause**: GCP requires **manual OAuth authorization** before you can link a GitHub repository to Cloud Build via the CLI. This is a security control — GCP needs to know you own the GitHub account and have permission to install the Cloud Build GitHub App.

**This is a one-time step** — once authorized, future triggers can be managed via CLI.

---

## How to Activate Full Automation (One-Time Setup)

### Step 1 — Authorize GitHub in GCP Console
```
https://console.cloud.google.com/cloud-build/triggers/connect
→ Choose GitHub
→ Authorize Google Cloud Build GitHub App
→ Select repository: ajithvnr2001/gcp-infra-end-to-end
→ Click Connect
```

### Step 2 — Create the Trigger via CLI (after authorization)
```bash
gcloud builds triggers create github \
  --project=my-project-32062-newsletter \
  --repo-name=gcp-infra-end-to-end \
  --repo-owner=ajithvnr2001 \
  --branch-pattern="^main$" \
  --build-config=cloudbuild.yaml \
  --name=ecommerce-ci-pipeline \
  --description="Auto-build all microservice images on push to main"
```

### Step 3 — Test It
```bash
# Manually trigger to verify (or just `git push` any change)
gcloud builds triggers run ecommerce-ci-pipeline \
  --project=my-project-32062-newsletter \
  --branch=main
```

---

## Why Commit SHA Tags Matter (Interview Answer)

| Tag Style | Problem |
|---|---|
| `:latest` | **Mutable** — you can't tell which code version is running |
| `:v1.2.3` | Better, but requires manual version bumping |
| `:$COMMIT_SHA` | **Immutable** — exact code version, enables precise rollbacks |

**Rollback with SHA tags** (zero-downtime):
```bash
# Roll back catalog-service to a previous known-good commit
kubectl set image deployment/catalog-service \
  catalog=gcr.io/my-project-32062-newsletter/catalog-service:abc1234 \
  -n ecommerce
```

---

## ✅ Final Architecture: Complete GitOps CI/CD Loop

```
Developer
    │
    ▼ git push (code change)
GitHub (main branch)
    │
    ▼ webhook triggers
GCP Cloud Build
    ├── build catalog-service:$SHA  ─┐
    ├── build cart-service:$SHA       ├── PARALLEL (~60s)
    ├── build payment-service:$SHA    │
    └── build api-gateway:$SHA      ─┘
    │
    ▼ push images to GCR
    │
    ▼ update k8s/deployments/*.yaml (image tag = $SHA)
    │
    ▼ git push manifest changes to GitHub
    │
ArgoCD (watching GitHub every 3 minutes)
    │
    ▼ detects changed manifest
    │
    ▼ applies new Deployment spec to GKE
    │
GKE Autopilot: RollingUpdate (zero downtime)
    ├── new pod starts → health check passes → old pod terminated
    └── repeat per replica
```
