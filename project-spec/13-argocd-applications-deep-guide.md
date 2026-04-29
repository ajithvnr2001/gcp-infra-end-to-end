# ArgoCD Applications Deep Guide

This guide explains how to use `https://localhost:8080/applications` for this ecommerce GCP project, what every important ArgoCD screen means, how it connects to the repository, and how to explain it in interviews.

## 1. What This URL Is

`https://localhost:8080/applications` is the ArgoCD Applications page.

In this project, ArgoCD is the GitOps controller. It continuously compares:

- Desired state: Kubernetes YAML files in Git under `k8s/`
- Actual state: Resources running inside the GKE cluster

If Git and the cluster differ, ArgoCD shows the application as `OutOfSync`. Because this project enables automated sync and self-heal, ArgoCD can also apply Git changes and correct manual drift automatically.

## 2. How To Open ArgoCD

Start the ArgoCD port-forward:

```powershell
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open this URL in the browser:

```text
https://localhost:8080/applications
```

Login details:

```text
Username: admin
Password: use the ArgoCD password shown in log.txt
```

The password is stored in `log.txt` for this local practice setup. In a real company environment, do not store ArgoCD admin passwords in plain text. Rotate the initial admin password and use SSO or RBAC.

If the browser shows a certificate warning, continue only because this is a local port-forward to your own cluster. The URL uses HTTPS with a local/self-signed certificate.

## 3. Why Browser Works Better Than curl Here

The local ArgoCD URL redirects HTTP to HTTPS. A browser can usually handle the local certificate warning.

From this Windows environment, `curl.exe -k https://localhost:8080/...` can fail with a Schannel credential/TLS error even when the service is reachable. That is a local Windows TLS client issue, not necessarily an ArgoCD failure.

For UI learning and interview preparation, use the browser for `https://localhost:8080/applications`.

For API testing, use a curl build that handles local TLS correctly, WSL, Git Bash, or PowerShell `Invoke-RestMethod` if configured properly.

## 4. What Application You Should See

You should see an application named:

```text
ecommerce-catalog
```

It is defined in:

```text
argocd/apps.yaml
```

Important configuration:

```yaml
metadata:
  name: ecommerce-catalog
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/ajithvnr2001/gcp-infra-end-to-end
    targetRevision: main
    path: k8s
    directory:
      recurse: true
  destination:
    server: https://kubernetes.default.svc
    namespace: ecommerce
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Interview explanation:

```text
I used ArgoCD to implement GitOps. The ArgoCD Application watches the main branch of my Git repository, specifically the k8s folder. Any Kubernetes manifest change merged to Git becomes the desired state. ArgoCD compares that desired state with the live GKE cluster and automatically syncs, prunes removed resources, and self-heals manual drift.
```

## 5. Applications Page Navigation

After login, the Applications page is your deployment control center.

Look for these columns or cards:

- `Name`: ArgoCD application name, here `ecommerce-catalog`
- `Sync Status`: whether Git and cluster match
- `Health Status`: whether Kubernetes resources are healthy
- `Repository`: Git repository ArgoCD watches
- `Path`: folder in Git, here `k8s`
- `Target Revision`: Git branch or commit, here `main`
- `Destination`: Kubernetes cluster and namespace, here in-cluster GKE and namespace `ecommerce`

Click:

```text
ecommerce-catalog
```

This opens the detailed application tree.

## 6. Sync Status Meaning

`Synced` means the live cluster matches the manifests in Git.

`OutOfSync` means Git and the cluster differ. Common causes:

- A new commit changed files under `k8s/`
- Someone manually edited a Kubernetes resource using `kubectl edit`
- A generated field changed in the cluster
- A resource was deleted manually
- ArgoCD has not applied the latest desired state yet

`Unknown` means ArgoCD cannot determine the state. Common causes:

- ArgoCD cannot reach the Kubernetes API
- Repository access failed
- Application controller is unhealthy
- RBAC blocks ArgoCD from reading resources

For this project, `ignoreDifferences` ignores deployment replica count:

```yaml
ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
      - /spec/replicas
```

This matters because HPAs can change replica counts. Without this ignore rule, ArgoCD may continuously detect replica drift caused by autoscaling.

Interview explanation:

```text
I configured ArgoCD to ignore Deployment replica count differences because HPA owns runtime scaling. Git defines the baseline deployment, but Kubernetes autoscaling may change replicas dynamically. Ignoring replicas prevents GitOps from fighting the HPA.
```

## 7. Health Status Meaning

`Healthy` means Kubernetes resources are running as expected.

`Progressing` means rollout is still happening. Common during a new deployment.

`Degraded` means one or more resources are failing. Examples:

- Pod is in `CrashLoopBackOff`
- Pod is in `ImagePullBackOff`
- Deployment does not have enough available replicas
- Readiness probe is failing
- Service has no ready endpoints

`Missing` means the resource exists in Git but not in the cluster.

`Suspended` is usually for paused resources such as suspended Rollouts or CronJobs.

`Unknown` means ArgoCD cannot calculate health.

## 8. Resource Tree: How To Read It

Inside the `ecommerce-catalog` application, ArgoCD shows a tree of Kubernetes resources.

Expected resource groups for this project:

- Namespace resources from `k8s/namespaces`
- ConfigMaps from `k8s/configmaps`
- Deployments from `k8s/deployments`
- Services from `k8s/services`
- HPAs from `k8s/hpa`
- Ingress resources from `k8s/ingress`
- Monitoring resources from `k8s/monitoring`
- Security resources from `k8s/security`
- Tracing resources from `k8s/tracing`

Expected application workloads:

- `frontend`
- `api-gateway`
- `catalog-service`
- `cart-service`
- `payment-service`
- `otel-collector`

How to read the tree:

- Start from the application node.
- Check whether the app is `Synced` and `Healthy`.
- Open each Deployment node.
- Check ReplicaSet and Pod children.
- If a Deployment is unhealthy, click the Pod first.
- Read Events and Logs from the Pod view.

Practical order:

```text
Application -> Deployment -> ReplicaSet -> Pod -> Events/Logs
```

This tells you whether the issue is a GitOps issue, Kubernetes rollout issue, container image issue, application crash, probe failure, or dependency failure.

## 9. Important Buttons In ArgoCD

### Refresh

Refresh asks ArgoCD to re-check Git and cluster state.

Use it when:

- You pushed a new commit and want ArgoCD to detect it
- The UI looks stale
- You fixed a cluster issue and want updated health

### Sync

Sync applies the desired Git state to the cluster.

Use it when:

- Application is `OutOfSync`
- You want to deploy the latest Git changes
- A resource was manually deleted and needs recreation

Be careful with sync options:

- `Prune`: deletes cluster resources removed from Git
- `Dry Run`: previews changes without applying
- `Force`: recreates resources more aggressively
- `Replace`: replaces instead of patching

For interviews, say:

```text
I normally check Diff before Sync. If prune is enabled, I verify that removed resources are intentionally removed from Git because prune can delete live cluster resources.
```

### Diff

Diff shows the difference between Git desired state and live cluster state.

Use it to answer:

- What changed?
- Was this change from Git or manual cluster drift?
- Is the difference safe to apply?

### App Details

App Details shows:

- Repository URL
- Target revision
- Path
- Destination cluster
- Destination namespace
- Sync policy
- Parameters and metadata

Use this to confirm ArgoCD is watching the correct repo and path.

### History And Rollback

History shows previous syncs and revisions.

Rollback can redeploy a previous revision. Use it only after confirming the previous revision is safe.

Interview explanation:

```text
If a deployment introduced a production issue, I would first inspect health, events, logs, and metrics. If the issue is clearly tied to the latest Git revision, I can rollback using ArgoCD history or revert the Git commit and let ArgoCD sync the previous desired state.
```

### Manifest

Manifest shows the YAML ArgoCD is applying.

Use it when:

- You want to confirm the exact image tag
- You want to inspect environment variables
- You want to verify probes, resources, labels, annotations, and service ports

### Logs

Logs show container logs for selected Pods.

Use logs for:

- CrashLoopBackOff
- Readiness probe failures
- Application startup failures
- Dependency connection errors

### Events

Events show Kubernetes scheduling and lifecycle messages.

Use events for:

- Image pull errors
- Failed scheduling
- Probe failures
- Volume mount failures
- RBAC or admission errors

## 10. How ArgoCD Relates To This Project

Project deployment flow:

```text
Developer changes code/YAML
        |
        v
GitHub repository
        |
        v
Cloud Build builds Docker images
        |
        v
Artifact Registry stores images
        |
        v
Kubernetes manifests under k8s/ reference images
        |
        v
ArgoCD watches k8s/
        |
        v
GKE cluster runs ecommerce services
```

ArgoCD does not build Docker images. It deploys Kubernetes manifests.

Cloud Build handles build and push.

Artifact Registry stores images.

GKE runs containers.

ArgoCD keeps GKE matching Git.

## 11. What To Check For Each Service

### frontend

Check:

- Deployment is Healthy
- Pod is Running
- Service routes port `80` to container port `8080`
- Ingress routes browser traffic to frontend

Interview angle:

```text
Frontend is the user entry point. In Kubernetes, it is exposed internally through a Service and externally through ingress-nginx.
```

### api-gateway

Check:

- Deployment is Healthy
- Readiness probe passes
- Service exposes port `8080`
- Gateway can reach catalog, cart, and payment services

Interview angle:

```text
API Gateway centralizes external API routing. It forwards product, cart, and order requests to backend microservices using Kubernetes service discovery.
```

### catalog-service

Check:

- Deployment is Healthy
- `/health` and `/ready` pass
- `/metrics` is exposed
- Prometheus target is up

Interview angle:

```text
Catalog service is the strongest observability example in this project because it exposes Prometheus metrics and application health endpoints.
```

### cart-service

Check:

- Deployment is Healthy
- `/health` and `/ready` pass
- Service discovery from API Gateway works

Known monitoring note:

```text
The Kubernetes manifests include Prometheus scrape annotations, but this service does not expose /metrics in the same way catalog does. In Prometheus this can appear as a down scrape target if Prometheus tries to scrape /metrics.
```

### payment-service

Check:

- Deployment is Healthy
- `/health` and `/ready` pass
- Order/payment endpoints work through API Gateway

Known monitoring note:

```text
Like cart-service, payment-service has health endpoints but does not expose full Prometheus metrics. This is a realistic improvement point for interviews.
```

## 12. Troubleshooting From ArgoCD UI

### If Application Is OutOfSync

Steps:

1. Click `ecommerce-catalog`.
2. Click `Diff`.
3. Check which resources changed.
4. Confirm whether the change came from Git or manual cluster drift.
5. If Git is correct, click `Sync`.
6. If live cluster is correct and Git is wrong, fix Git first.

Interview answer:

```text
I do not blindly sync. I check the diff first, identify whether it is expected Git change or manual drift, then sync or fix Git depending on the source of truth.
```

### If Application Is Degraded

Steps:

1. Open the application tree.
2. Find the red or yellow resource.
3. Click the unhealthy Deployment or Pod.
4. Check Events.
5. Check Logs.
6. Check image, probes, resources, and dependencies.

Common causes:

- Wrong image tag
- Artifact Registry permission issue
- Container crash
- Readiness probe path wrong
- Service dependency unavailable
- Resource limits too low

### If Pod Shows ImagePullBackOff

Check:

- Image path in manifest
- Image exists in Artifact Registry
- GKE node service account can read Artifact Registry
- Cloud Build pushed image successfully
- Image tag is correct

GCP-specific explanation:

```text
For GKE pulling from Artifact Registry, the node service account needs Artifact Registry reader permissions. If images are built but Pods cannot pull them, I check IAM, image path, and tag.
```

AWS mapping:

```text
In AWS, this maps to EKS pulling images from ECR. Worker node IAM role or IRSA-related permissions must allow ECR image pulls.
```

### If Pod Shows CrashLoopBackOff

Check:

- Pod logs
- Environment variables
- ConfigMaps and Secrets
- Application startup command
- Downstream service URLs
- Database connectivity
- Resource limits

Interview answer:

```text
For CrashLoopBackOff, I start with container logs, then describe the Pod for events, then verify config, secrets, command, probes, and dependencies. ArgoCD tells me what is unhealthy, but Kubernetes logs and events tell me why.
```

### If Sync Fails

Check:

- Invalid YAML
- Missing namespace
- Missing CRD
- RBAC permission denied
- Immutable field changed
- Admission controller rejected resource
- Resource quota blocked creation

Useful command:

```powershell
kubectl describe application ecommerce-catalog -n argocd
```

## 13. Commands That Match The ArgoCD UI

List ArgoCD applications:

```powershell
kubectl get applications -n argocd
```

Describe this application:

```powershell
kubectl describe application ecommerce-catalog -n argocd
```

Check application YAML:

```powershell
kubectl get application ecommerce-catalog -n argocd -o yaml
```

Check ecommerce resources:

```powershell
kubectl get all -n ecommerce
```

Check events:

```powershell
kubectl get events -n ecommerce --sort-by=.lastTimestamp
```

Check ArgoCD application controller logs:

```powershell
kubectl logs deploy/argocd-application-controller -n argocd
```

Check Pods:

```powershell
kubectl get pods -n ecommerce -o wide
```

Check a failing Pod:

```powershell
kubectl describe pod <pod-name> -n ecommerce
kubectl logs <pod-name> -n ecommerce
```

## 14. Optional ArgoCD API Checks

Browser UI is enough for learning. If you want API practice, ArgoCD exposes an API.

Create a session token:

```powershell
curl.exe -k -X POST https://localhost:8080/api/v1/session `
  -H "Content-Type: application/json" `
  -d "{\"username\":\"admin\",\"password\":\"<password-from-log.txt>\"}"
```

Use the token:

```powershell
curl.exe -k https://localhost:8080/api/v1/applications `
  -H "Authorization: Bearer <token>"
```

If Windows `curl.exe` fails with a Schannel TLS error, use the browser, WSL curl, Git Bash curl, or a curl build using OpenSSL.

## 15. GCP To AWS Mapping For ArgoCD

| This GCP Project | AWS Equivalent | Interview Explanation |
|---|---|---|
| GKE | EKS | Managed Kubernetes cluster where workloads run |
| Artifact Registry | ECR | Private container image registry |
| Cloud Build | CodeBuild / CodePipeline / GitHub Actions | Builds and pushes container images |
| ArgoCD | ArgoCD on EKS | Same GitOps deployment controller |
| GCP IAM for image pull | EKS node role / IRSA permissions for ECR | Grants cluster permission to pull private images |
| Ingress NGINX on GKE | Ingress NGINX or AWS Load Balancer Controller on EKS | Routes external traffic into services |
| Cloud Monitoring / Prometheus | CloudWatch / Managed Prometheus | Metrics and alerting |

Interview answer:

```text
The GitOps pattern is cloud-agnostic. In GCP I used GKE, Artifact Registry, and Cloud Build. In AWS I would map that to EKS, ECR, and CodeBuild or GitHub Actions. ArgoCD remains the same controller. The main cloud-specific changes are IAM permissions, registry URL, ingress/load balancer integration, and observability services.
```

## 16. Interview Questions And Strong Answers

### 1. What is ArgoCD doing in your project?

ArgoCD implements GitOps. It watches my Git repository path `k8s/` and continuously compares it with the live GKE cluster. If there is drift, it shows `OutOfSync`, and because automated sync is enabled, it can apply the Git state back to the cluster.

### 2. What is the source of truth?

Git is the source of truth. Kubernetes should match the manifests stored in Git. Manual cluster changes are treated as drift.

### 3. What happens if someone manually changes a Deployment?

ArgoCD detects drift. Since `selfHeal: true` is enabled, it can revert the manual change and restore the Git-defined desired state. Replica count is an exception because this project ignores `/spec/replicas` to avoid fighting the HPA.

### 4. Why did you enable prune?

Prune removes resources from the cluster when they are removed from Git. This prevents orphaned resources. It is powerful but risky, so I check diffs carefully before relying on pruning in production.

### 5. How do you troubleshoot a degraded ArgoCD app?

I open the application tree, identify the unhealthy resource, inspect Kubernetes events and logs, then validate image pulls, probes, config, secrets, service dependencies, and resource limits. ArgoCD identifies where the issue is; Kubernetes tells me the root cause.

### 6. How does ArgoCD know what to deploy?

The `Application` manifest defines the Git repo, branch, path, destination cluster, destination namespace, and sync policy. In this project it watches the `main` branch and `k8s/` folder.

### 7. Does ArgoCD build Docker images?

No. ArgoCD deploys Kubernetes manifests. Cloud Build builds and pushes Docker images to Artifact Registry. ArgoCD applies the manifests that reference those images.

### 8. What is the difference between Sync and Health?

Sync means Git and cluster desired state match. Health means the live Kubernetes resources are working correctly. An app can be `Synced` but `Degraded` if the YAML was applied successfully but Pods are crashing.

### 9. How would this project work in AWS?

I would use EKS instead of GKE, ECR instead of Artifact Registry, and CodeBuild or GitHub Actions instead of Cloud Build. ArgoCD would still watch the Git repo and sync manifests to Kubernetes. The main changes would be IAM, registry paths, and load balancer integration.

### 10. What production improvements would you add?

I would add SSO and RBAC for ArgoCD, remove plain-text admin credentials, enforce branch protection, use image tag promotion, add notifications for sync failures, improve metrics for cart and payment services, and use progressive delivery for safer rollouts.

## 17. VERDICT Framework Example

Question:

```text
Your ArgoCD app is OutOfSync and Degraded. How will you troubleshoot?
```

Answer using VERDICT:

```text
V - Verify:
I first verify the application status in ArgoCD: sync status, health status, affected resources, latest Git revision, and destination namespace.

E - Examine:
I open Diff to see why it is OutOfSync. Then I inspect the degraded resource in the tree, usually Deployment, ReplicaSet, or Pod.

R - Reason:
If Git changed, it may need sync. If live state changed manually, it is drift. If the resource is degraded, the issue may be image pull, crash, probe failure, config, secret, or dependency failure.

D - Decide:
If Git is correct, I sync. If Git is wrong, I fix or revert the commit. If the app is degraded after sync, I troubleshoot the Kubernetes resource.

I - Implement:
I check events and logs, fix the image/config/probe/permission issue, commit the manifest change if needed, and let ArgoCD deploy it.

C - Confirm:
I confirm ArgoCD becomes Synced and Healthy, Pods are ready, service endpoints exist, and Prometheus/Grafana show healthy signals.

T - Tell:
I document the root cause, commands used, fix applied, and prevention step such as better CI validation, alerts, or RBAC controls.
```

## 18. Daily Practice Checklist

Use this checklist when studying `https://localhost:8080/applications`:

- Login to ArgoCD using `admin` and the password from `log.txt`.
- Open `ecommerce-catalog`.
- Check Sync status.
- Check Health status.
- Open App Details and confirm repo, branch, path, and namespace.
- Open the resource tree and identify each service.
- Click one Deployment and inspect Pods.
- Click one Pod and inspect Logs and Events.
- Open Diff even if the app is Synced, so you understand the screen.
- Explain why replicas are ignored due to HPA.
- Map GKE, Artifact Registry, and Cloud Build to EKS, ECR, and CodeBuild.
- Practice the VERDICT answer for OutOfSync and Degraded scenarios.

## 19. One-Minute Interview Pitch

```text
In my ecommerce GCP project, I used ArgoCD for GitOps-based Kubernetes deployment. The ArgoCD Application named ecommerce-catalog watches the main branch of my GitHub repository under the k8s folder and deploys those manifests into the ecommerce namespace on GKE. Cloud Build builds and pushes images to Artifact Registry, while ArgoCD handles deployment and drift correction. I enabled automated sync, pruning, and self-healing, and I ignored Deployment replica differences because HPA controls scaling at runtime. During troubleshooting, I use ArgoCD to identify sync and health issues, then drill into Kubernetes events, logs, image pulls, probes, and service dependencies. The same architecture maps cleanly to AWS using EKS, ECR, CodeBuild, and ArgoCD.
```
