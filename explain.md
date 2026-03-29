# GCP & Terraform — Scenario-Based Infrastructure Prep
## Production Troubleshooting | Infrastructure-as-Code | Ajith Kumar

---

# THE INFRA-VERDICT FRAMEWORK
Apply this to every Terraform or GCP infrastructure problem during an interview.

```
V — Version      → Terraform version? Provider version (~> 5.0)? API version?
E — Environment  → Right Project ID? Correct Region (us-central1 vs asia-south1)? 
R — Resources    → Naming collisions (Global vs Local)? Quotas reached?
D — Dependencies → APIs enabled? Service accounts created? VPC Peering active?
I — Infra state  → GCS Backend reachable? State locked? Drift detected?
C — Connectivity → Private IP enabled? Firewall rules? Route conflicts?
T — Telemetry    → TF_LOG=DEBUG output? GCP Cloud Audit logs?
```

---

# SECTION 1 — TERRAFORM & STATE SCENARIOS

---

## SCENARIO 1 — The Syntax "Ghost"
### "Your Terraform init/plan is failing with 'Invalid Character' errors on lines that look perfectly fine. How do you debug?"

**The Troubleshooting Scan:**
- **V**: Did you copy-paste from a different HCL version or documentation?
- **T**: Look at the exact character indicated in the trace (e.g., `;`).

**The Answer:**
"Wait, HCL (HashiCorp Configuration Language) is strictly newline-delimited for block arguments. Beginners often treat it like C++ or Java and add semicolons.

**The Error:**
```hcl
variable "db_password" { type = string; sensitive = true } # Error: Invalid character ';'
```

**The Fix:**
Remove the semicolon and use proper line breaks or just spaces within the block.
```hcl
variable "db_password" { 
  type      = string
  sensitive = true 
}
```
**To Say:** 'I always keep my HCL clean and follow standard linting. If I see syntax errors on valid-looking lines, I check for hidden characters or non-HCL delimiters like semicolons that might have crept in during a quick edit.'"

---

## SCENARIO 2 — The Identity Crisis
### "Terraform fails with 403 Forbidden even though you are logged into your terminal. What's the first thing you check?"

**The INFRA-VERDICT scan:**
- **E**: Which account is active in `gcloud auth list`?
- **D**: Is the identity used by Terraform (ADC) different from the one in your browser?

**The Answer:**
"Logging into the GCP Console is NOT the same as authenticating Terraform. Terraform typically uses **Application Default Credentials (ADC)**.

**The Fix:**
Run the explicit ADC login command to refresh the local credentials file:
```bash
gcloud auth application-default login
```
**To Say:** 'When I see 403s despite being 'logged in,' I immediately verify my ADC identity. I've seen cases where a developer is using their personal gmail for the console but Terraform is still trying to use an old client project account stored in the local credentials file.'"

---

## SCENARIO 3 — The Global Namespace Trap
### "You are creating a GCS bucket, but it fails with '409 Conflict' even though no such bucket exists in your project. Why?"

**The INFRA-VERDICT scan:**
- **R**: Bucket names are **Globally Unique**.
- **E**: Are you using a generic name like `tf-state-prod`?

**The Answer:**
"GCS bucket names are shared across the ENTIRE Google Cloud ecosystem, not just your project. If someone in another company took that name, you can't have it.

**The Fix:**
Always prefix or suffix your buckets with your unique **Project ID**.
```hcl
resource "google_storage_bucket" "tf_state" {
  name = "tf-state-${var.project_id}" # Guaranteed uniqueness
}
```
**To Say:** 'I treat GCS naming like domain names—they are a global resource. My standard practice is to interpolate the Project ID into the resource name to ensure we never hit a 409 conflict during a rollout.'"

---

# SECTION 2 — GKE & NETWORKING SCENARIOS

---

## SCENARIO 4 — GKE Autopilot "Invalid Argument"
### "Your GKE Autopilot cluster fails to create with a generic '400 Bad Request' error. How do you find the root cause?"

**The INFRA-VERDICT scan:**
- **V**: Is the maintenance policy date in the past?
- **C**: Does the subnet have 'Private Google Access' enabled?

**The Answer:**
"GKE Autopilot is highly opinionated. It often fails if the config includes 'illegal' settings or outdated validation fields.

**Common Fixes:**
1. **Maintenance Windows**: If `start_time` is in the past, the API rejects it. Remove it or set a future date.
2. **Private Networking**: For private clusters, the underlying subnet **must** have `private_ip_google_access = true` so nodes can reach Google APIs.
3. **Secondary Ranges**: Ensure the 'Pods' and 'Services' range names in your VPC exactly match what's in the GKE module.

**To Say:** '400 errors in GKE are usually configuration policy violations. I first check the three pillars: networking (Private Access), validation (Maintenance dates), and naming (Secondary ranges).'"

---

## SCENARIO 5 — The "Producer Service" Cleanup Loop
### "You've deleted your Cloud SQL instance, but Terraform destroy fails to delete the VPC Peering. Why?"

**The INFRA-VERDICT scan:**
- **D**: Cloud SQL uses 'Service Networking' peering under the hood.
- **I**: The 'Producer' (Google) project hasn't released the resources yet.

**The Answer:**
"This is a classic 'sticky' resource issue. When you use Private IP for services, GCP creates a peering connection. Even after the SQL instance is 'deleted,' the underlying peering often remains in use by Google's internal cleanup processes for up to 10-15 minutes.

**The Scripted Fix:**
Implement a retry loop with a wait period (60 seconds) in your cleanup scripts.
```bash
for i in {1..3}; do
  gcloud compute networks peerings delete ... && break || sleep 60
done
```
**To Say:** 'In production, we treat VPCs as long-lived. If we must nuke them, we account for the 10-minute 'cooldown' period that GCP service networking requires before it releases the VPC peering connection.'"

---

# SECTION 3 — THE "PROTECTION" SCENARIO

---

## SCENARIO 6 — The Deletion Guardrail
### "Terraform destroy fails, saying you need to set 'deletion_protection' to false. You update the code, but it STILL fails. Why?"

**The Answer:**
"This is a state-vs-code conflict. Terraform's **State File** still thinks the resource is protected because it hasn't successfully talked to the API to update that attribute yet.

**The Step-by-Step Fix:**
1. Update code to `deletion_protection = false`.
2. Run `terraform apply` (this updates only the 'protection' flag in the state and the API).
3. Run `terraform destroy` (now it has permission to delete).

**To Say:** 'I never skip the 'apply' step when disabling protection. Terraform needs to reconcile the new 'unprotected' state with the Cloud Provider's API first before it will even attempt a destructive action.'"


## Architectural Additions: Security, GitOps, and Ingress Theory

### 1. The Reality of ArgoCD `selfHeal`
ArgoCD's `selfHeal: true` configuration is paramount for enforcing Immutable Infrastructure. By continuously treating Git as the source of truth, it prevents unauthorized, ad-hoc `kubectl apply` manual tweaks against live servers ("Configuration Drift"). If an engineer patches a deployment in the cluster natively, ArgoCD instantly recognizes the diff and purges the unauthorized modification within seconds. 

### 2. Ingress Regex Rewriting (`rewrite-target`)
In a microservices paradigm, API endpoints are frequently clustered (e.g., `/api/catalog`, `/api/payment`). However, the backend applications themselves are usually programmed assuming they operate at their own root (`/`). The NGINX Ingress controller patches this via PCRE regex capture groups. Ex: `path: /api/catalog(/|$)(.*)` catches the remainder of the URL into parameter `$2`. By defining the annotation `nginx.ingress.kubernetes.io/rewrite-target: /$2`, NGINX mechanically truncates the `/api/catalog` prefix and passes the naked request to the internal gateway.

### 3. GKE Autopilot Pod Security Standards (PSS)
Serverless Kubernetes structures (like GKE Autopilot) enforce immense hardware-level safety regulations to prevent container escapes. Specifically, they utilize **Pod Security Admission (PSA)** to strictly block any container image demanding OS root privileges. Because traditional web servers (like `nginx` listening on default port 80) require root access to bind to restricted local ports under 1024, they instantly crash during Deployment. The architectural workaround is packaging **unprivileged** containers (running UID 1000) operating on high ports like `8080`.

### 4. Zero-Trust Network Policies & Lateral Movement
A profound best practice implemented in this cluster is the "Default Deny All" `NetworkPolicy`. By casting a net evaluating `podSelector: {}`, the cluster isolates all pods individually, effectively breaking internal East-West traffic. Engineers must deliberately stitch policies (like `frontend-netpol` or `catalog-netpol`) whitelisting microservice interactions. This mathematically neutralizes lateral network hopping; if a malicious actor cracks the Payment microservice, they cannot arbitrarily pivot and curl the internal Catalog database.

### 5. Evaluating `kubectl port-forward` Anomalies
`kubectl port-forward` is an exceptional debugging tool, but often generates "false positive" diagnoses. It creates a physical bridge traversing directly to the pod's `127.0.0.1` loopback namespace. By doing so, it utterly bypasses Kubernetes `Service` endpoints, `Ingress` controllers, and standard `NetworkPolicies`. If a pod serves traffic perfectly over port-forwarding, but times out (`504 Gateway Time-out`) over its public load balancer, the bug mathematically exists within the cluster's internal networking layer (Service configurations or Firewall drops).
