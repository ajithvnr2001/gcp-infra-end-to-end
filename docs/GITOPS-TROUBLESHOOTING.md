# 🔄 GitOps & CI/CD Troubleshooting: Core Platform Sync

This guide documents the complex synchronization challenges solved during the automation of the E-Commerce platform.

---

## 🏗️ 1. The Cert-Manager Webhook Race Condition
**Scenario**: ArgoCD fails to sync the entire application because it cannot validate the `Certificate` or `Ingress` resources. Errors like `Internal error: failed calling webhook` or `TLS: unknown authority` appear.

**Cause**: Custom Resource Definitions (CRDs) for platform controllers (like `cert-manager`) are registered immediately, but their internal admission webhooks (which validate any new resources) take a few seconds to generate certificates and start serving.

**Fix**:
Implemented a **Structural 30s Wait Period** in the `scripts/build.sh` pipeline:
```bash
# 1. Install controllers
helm install cert-manager ...
# 2. COOL-DOWN PERIOD (Critical for GKE Autopilot)
sleep 30 
# 3. Apply applications
kubectl apply -f argocd/apps.yaml
```
This ensures the cluster is "Ready to Validate" before the first app sync occurs.

---

## 🏗️ 2. Cloud Build Repo Authorization (`INVALID_ARGUMENT`)
**Scenario**: Running `setup-cloudbuild-trigger.sh` fails with `ERROR: (gcloud.alpha.builds.triggers.create.github) INVALID_ARGUMENT: Repo does not exist`.

**Cause**: Google Cloud Build requires manual "Handshake" authorization for GitHub repositories before the CLI can create a trigger. This cannot be fully automated via a standard Service Account.

**Fix**:
1.  **Manual Link**: Visit the Google Cloud Console -> Cloud Build -> Triggers -> Manage Repositories.
2.  **Auth Flow**: Follow the OAuth flow to link your GitHub App with the GCP project.
3.  **CLI Retry**: Once linked in the UI, the `gcloud` command will succeed. Documented this in the `fixes.md` to prevent future troubleshooting delays.

---

## 🏗️ 3. "Inch-by-Inch" Manifest Updates
**Scenario**: How to ensure the frontend uses the exact image built in the pipeline?

**Cause**: Using `latest` tags causes cache-poisoning and makes rollbacks impossible.

**Fix**:
Our pipeline utilizes a **Manifest Patching** pattern. After the Docker image is pushed to Artifact Registry with a specific Git SHA, we use `sed` or `kustomize` to update the image tag in the `k8s/` manifests before ArgoCD syncs:
```bash
sed -i "s|image: .*|image: gcr.io/${PROJECT_ID}/${SERVICE}:${GIT_SHA}|g" k8s/deployments/${SERVICE}-deployment.yaml
```
This ensures **Immutable Deployments** and allows for instant Git-based rollbacks.
