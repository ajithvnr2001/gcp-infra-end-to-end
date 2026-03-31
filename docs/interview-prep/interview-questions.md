# docs/interview-prep/interview-questions.md
# Interview Prep — DevOps Engineer (3–5 Years)
# Based entirely on THIS project — every answer is backed by real code

---

## 🏗️ TERRAFORM & INFRASTRUCTURE

**Q: Walk me through how you structured your Terraform code.**

> "I used a module-based structure with separate modules for VPC, GKE, and Cloud SQL,
> and an environment entry point in `terraform/envs/prod/`. Remote state is stored in
> a GCS bucket with versioning enabled, so every apply is tracked. I used output variables
> to wire modules together — for example, the VPC module outputs the subnet name which
> the GKE module consumes as input. I also mirrored the same structure for AWS
> with EKS, RDS, and VPC modules under `aws/terraform/`."

**Q: How do you handle Terraform state in a team?**

> "Remote state in GCS with versioning. For AWS I used an S3 backend with a DynamoDB
> table for state locking — that prevents two engineers from running terraform apply
> at the same time and corrupting state. We also ran terraform plan on every PR via
> GitHub Actions so the team could review infra changes before merge."

**Q: What's the difference between Terraform plan and apply?**

> "`plan` shows what WILL change — it's a dry run, safe to run anytime.
> `apply` actually makes the changes. In our CI pipeline, plan runs automatically
> on every PR. Apply only runs on merge to main, and requires manual approval
> for production changes."

---

## ☸️ KUBERNETES

**Q: Explain HPA and how you configured it.**

> "HPA — Horizontal Pod Autoscaler — automatically scales pod count based on
> CPU or memory metrics. I configured it to scale from 2 to 20 replicas when
> CPU exceeds 60%. The key tuning is the `scaleUp.stabilizationWindowSeconds` —
> I set it to 30 seconds so it reacts fast during a flash sale spike. For scale-down
> I set 300 seconds so it doesn't kill pods prematurely and cause a yo-yo effect."

**Q: What's the difference between liveness and readiness probes?**

> "Liveness probe: if it fails, Kubernetes restarts the pod. Used for deadlock
> detection — if the app is running but stuck, restart it.
> Readiness probe: if it fails, Kubernetes stops sending traffic to that pod but
> doesn't restart it. Used during startup — don't send requests until the app
> has connected to the database and is truly ready."

**Q: How do you do zero-downtime deployments?**

> "RollingUpdate strategy with `maxUnavailable: 0` and `maxSurge: 1`. This means
> Kubernetes spins up one new pod, waits for its readiness probe to pass,
> then terminates one old pod. Traffic only switches over once the new pod
> is confirmed healthy. Combined with proper readiness probes, this gives
> true zero downtime."

**Q: What are Network Policies and why do you use them?**

> "Kubernetes Network Policies control which pods can talk to which pods.
> By default I apply a deny-all policy, then explicitly allow only required
> communication. For example, only the API Gateway can reach the Payment service —
> if any other service gets compromised, it cannot lateral-move to Payment.
> This is zero-trust networking inside the cluster."

---

## 🔄 CI/CD & GITOPS

**Q: Explain your CI/CD pipeline end to end.**

> "Code push to main triggers GitHub Actions. It runs tests first — if they fail,
> nothing gets deployed. On success, Docker builds the image tagged with the git
> commit SHA — never `latest`, so every image is traceable. It pushes to GCR,
> then updates the image tag in the K8s deployment YAML and commits that back to
> git. ArgoCD detects the git change and syncs to GKE automatically. Total time
> from push to production: about 8 minutes."

**Q: What is GitOps and why use ArgoCD?**

> "GitOps means Git is the single source of truth for cluster state.
> ArgoCD continuously compares what's in git with what's running in the cluster.
> If they drift — say someone does a manual `kubectl apply` — ArgoCD auto-reverts
> it. This gives us self-healing infrastructure. It also makes rollback trivial:
> just revert the git commit and ArgoCD syncs the old state back."

**Q: How do you handle secrets in CI/CD?**

> "Secrets never touch git. In GitHub Actions, secrets are stored as encrypted
> GitHub Secrets and injected as environment variables at runtime. In the cluster,
> we use External Secrets Operator which pulls from GCP Secret Manager and
> creates K8s Secrets automatically. Secret Manager has full audit logs,
> versioning, and supports rotation."

---

## 📊 OBSERVABILITY

**Q: What's your monitoring stack?**

> "Three pillars: Metrics, Logs, Traces.
> Metrics: Prometheus scrapes a `/metrics` endpoint on each service.
> Grafana visualizes it — I built dashboards tracking request rate, P99 latency,
> error rate, HPA replica count.
> Logs: Services emit structured JSON logs. Promtail ships them to Loki,
> queryable in Grafana. The JSON format includes trace IDs so logs link
> directly to Cloud Trace spans.
> Traces: OpenTelemetry SDK in each service sends spans to an OTel Collector
> which forwards to GCP Cloud Trace. I can see the full request waterfall:
> api-gateway → catalog → DB query."

**Q: Explain SLO burn rate alerting.**

> "An SLO is a target — payment service at 99.9% availability gives us
> 43 minutes of error budget per month. Burn rate measures how fast we're
> consuming that budget. At 14x burn rate, we'd exhaust the budget in 2 hours —
> that fires a critical page. At 6x burn rate over 6 hours, we get a warning.
> This is multi-window alerting from the Google SRE book — it catches both
> fast catastrophic failures and slow degradation."

**Q: What metrics do you track?**

> "Four golden signals: Latency (P50/P95/P99), Traffic (RPS), Errors (5xx rate),
> Saturation (CPU/memory, HPA replica count vs max). For each microservice I
> track these individually. Payment gets extra scrutiny — any 5xx triggers
> an immediate SLO alert because it's direct revenue impact."

---

## 🔒 SECURITY

**Q: How do you implement least-privilege in Kubernetes?**

> "RBAC with purpose-built roles. The microservice service account can only
> read ConfigMaps and Secrets — it cannot list pods or touch other namespaces.
> Developers get read-only access to pods and logs. On-call gets pod exec and
> rollback. CI/CD can only patch Deployments in the ecommerce namespace —
> it cannot delete anything or touch other namespaces."

**Q: How do you manage secrets?**

> "No secrets in git, ever. GCP Secret Manager stores all secrets.
> External Secrets Operator syncs them into K8s Secrets every hour — so
> if a secret is rotated in Secret Manager, pods pick it up automatically.
> Workload Identity means pods authenticate to GCP as a service account
> without any key file mounted — no credentials to leak."

---

## 🚨 INCIDENT MANAGEMENT

**Q: Walk me through how you'd handle a payment service outage.**

> "First assess: `kubectl get pods` and `kubectl describe` to see what's happening.
> Check Grafana — is it a sudden spike or gradual degradation? Is it all pods
> or one? If it started after a deployment, rollback immediately:
> `kubectl rollout undo deployment/payment-service`. If it's OOM, patch the
> memory limit temporarily. If it's database connections, restart pods to
> reset the pool. I have a runbook in `docs/runbooks/payment-service-outage.md`
> that covers the 5 most common causes with exact commands. Goal: restore service
> first, investigate root cause second."

**Q: What is your RTO and RPO?**

> "RTO (Recovery Time Objective) — how long to restore: under 1 hour.
> RPO (Recovery Point Objective) — how much data we can lose: under 6 hours,
> because DR backups run every 6 hours. Cloud SQL has PITR (Point-in-Time Recovery)
> which can get us much closer to zero RPO for the database specifically."

---

## ☁️ GCP SPECIFIC

**Q: What GCP services have you worked with?**

> "GKE Autopilot — managed Kubernetes, no node management. Cloud SQL — managed
> PostgreSQL with HA and automated backups. Cloud Monitoring and Cloud Logging —
> metrics, dashboards, and log aggregation. Cloud Trace — distributed tracing.
> GCR — container registry. Cloud NAT — outbound internet for private GKE nodes.
> Secret Manager — secrets storage. Cloud Storage — Terraform state and log archives.
> IAM and Workload Identity — fine-grained access control."

**Q: GKE Autopilot vs Standard — which do you use and why?**

> "Autopilot for production. Google manages the nodes — patching, scaling, bin-packing.
> You only pay for pod resource requests, not idle node capacity. Standard gives more
> control (custom node pools, GPU nodes) but requires more ops overhead.
> For a team focused on application delivery, Autopilot reduces toil significantly."

---

## 💡 BEHAVIOURAL

**Q: Tell me about a time you reduced manual effort.**

> "At Citi, I built Python scripts for disk monitoring, health checks, and log archival.
> Before, engineers manually checked disk usage and cleaned logs. After automation,
> the system monitored itself every 60 seconds, archived logs to GCS automatically,
> and alerted on anomalies. Saved about 5 man-hours per week — about 30% of
> manual operational effort."

**Q: How do you handle a high-severity production incident at 2am?**
 
 > "Follow the runbook — never improvise under pressure. First stabilize:
 > rollback or scale up to stop the bleeding. Then investigate with logs and traces.
 > Communicate clearly in the incident channel — what's affected, what we're trying,
 > ETA for resolution. Once resolved, blameless post-mortem within 48 hours
 > focused on systemic fixes, not individual blame."
 
---

## 🎨 FRONTEND & USER EXPERIENCE

**Q: Why did you choose Vanilla JS instead of React/Next.js for the ecommerce frontend?**

> "For this project, I prioritized **performance and simplicity**. Vanilla JS has zero overhead and requires no complex build/hydration step, making it extremely fast for a serverless environment like GKE Autopilot. It demonstrated my ability to handle DOM manipulation and state management natively. For a larger team, I'd use Next.js for its ecosystem, but for a high-performance, containerized microservice, Vanilla JS + NGINX gives me total control over the bundle size and security."

**Q: How did you secure your frontend container?**

> "I used the `nginx-unprivileged` base image. Standard NGINX runs as root and binds to port 80, which GKE Autopilot blocks for security. My container runs as a non-root user (UID 101) and binds to port 8080. I also configured the NGINX `security_headers` to prevent Clickjacking, XSS, and MIME-type sniffing."

---

## 🛡️ PLATFORM HARDENING (ADVANCED)

**Q: Tell me about a time you had to fix a complex race condition in your CI/CD pipeline.**

> "When I first deployed the stack, ArgoCD failed to sync because the `cert-manager` admission webhook wasn't ready yet. The cluster was rejecting my `Certificate` and `Ingress` resources. I solved this by implementing a **30-second delay** in my `build.sh` script immediately after installing the platform controllers. This 'Cool-down' period ensures that the Kubernetes API server has fully registered the new webhooks before we attempt to sync the application manifests, preventing 'TLS Unknown Authority' errors."

**Q: How did you implement monitoring on GKE Autopilot despite its restrictions?**

> "Autopilot is 'Managed', so it blocks access to the `kube-system` namespace and host-level resources like `/proc` (needed by NodeExporter). I had to create a custom `values.yaml` for the Prometheus Helm chart that **disabled restricted components** while keeping application-level scraping enabled. I also used an OpenTelemetry Collector to 'offload' heavy trace processing to GCP Cloud Trace, keeping the cluster footprint small and complying with resource limits."
