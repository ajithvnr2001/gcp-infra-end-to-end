# docs/PROJECT-STRUCTURE.md
# Complete project structure reference

```
ecommerce-gcp-project/
│
├── README.md                          ← Start here — full setup guide
├── Makefile                           ← One-command shortcuts for everything
├── .gitignore
├── .pre-commit-config.yaml            ← Catches issues before git commit
│
├── services/                          ← Microservices (Python FastAPI)
│   ├── catalog/                       ← Product catalog (port 8000)
│   │   ├── main.py                    ← FastAPI app + Prometheus + OpenTelemetry
│   │   ├── Dockerfile                 ← Multi-stage, non-root user
│   │   ├── requirements.txt
│   │   └── tests/test_catalog.py
│   ├── cart/                          ← Shopping cart (port 8001)
│   ├── payment/                       ← Orders & payment (port 8002)
│   ├── api-gateway/                   ← Single entry point (port 8080)
│   └── frontend/                      ← Premium Vanilla JS Web App (port 8080)
│       ├── index.html                 ← Glassmorphism UI
│       ├── app.js                     ← API Integration & State
│       └── Dockerfile                 ← Unprivileged NGINX (Autopilot-Ready)
│
├── terraform/                         ← GCP Infrastructure as Code
│   ├── envs/prod/
│   │   ├── main.tf                    ← Wires all modules together
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   └── modules/
│       ├── vpc/                       ← VPC, subnets, Cloud NAT, firewall
│       ├── gke/                       ← GKE Autopilot, Workload Identity
│       └── cloudsql/                  ← PostgreSQL, HA, PITR backups
│
├── aws/                               ← AWS Infrastructure as Code
│   └── terraform/
│       ├── envs/prod/main.tf          ← S3 state + DynamoDB lock
│       └── modules/
│           ├── vpc/                   ← VPC, public/private subnets, NAT GW
│           ├── eks/                   ← EKS cluster, node group, ECR repos
│           └── rds/                   ← RDS PostgreSQL, multi-AZ, encrypted
│
├── k8s/                               ← Kubernetes manifests (ArgoCD syncs this)
│   ├── namespaces/ecommerce.yaml
│   ├── deployments/                   ← RollingUpdate, probes, resource limits
│   ├── services/                      ← ClusterIP for all services
│   ├── hpa/hpa.yaml                   ← Scale 2→20 pods, fast scaleUp
│   ├── ingress/                       ← Ingress-Nginx manifests
│   │   └── ingress-tls.yaml          ← HTTPS + Split Routing (Frontend & API)
│   ├── configmaps/                    ← Non-secret config per service
│   ├── secrets/secrets-template.yaml  ← Template only — real secrets via ESO
│   ├── monitoring/                    ← Prometheus scrape annotations patch
│   └── tracing/otel-collector.yaml    ← OTel Collector → Cloud Trace (Hardened for Autopilot)
│
├── argocd/apps.yaml                   ← GitOps: App-of-Apps, auto-sync, self-heal
│
├── github-actions/
│   ├── ci-cd.yaml                     ← Main pipeline: test→build→push→deploy
│   ├── pr-checks.yaml                 ← PR gates: lint, test, tf-plan, k8s-validate
│   └── scheduled-jobs.yaml           ← DR backup, cost check, SSL check, health
│
├── monitoring/
│   ├── OBSERVABILITY.md              ← How to use the full stack
│   ├── prometheus/values.yaml        ← kube-prometheus-stack Helm values + alert rules
│   ├── grafana/
│   │   ├── dashboards/ecommerce-overview.json   ← 10-panel production dashboard
│   │   └── ecommerce-dashboard.yaml             ← ConfigMap for Auto-Importing to Grafana
│   │   └── provisioning/datasources/            ← Auto-wires Prometheus + Loki + Trace
│   ├── loki/loki-values.yaml         ← Log aggregation, 30-day retention
│   ├── slo/
│   │   ├── slo-definitions.yaml      ← Payment 99.9%, Catalog 99.5%, API P95<300ms
│   │   └── burn-rate-alerts.yaml     ← Google SRE multi-window burn rate alerting
│   ├── alerts/alert-policies.yaml    ← GCP native alert policies
│   └── dashboards/dashboard.json     ← GCP Cloud Monitoring dashboard
│
├── security/
│   ├── rbac/rbac.yaml                ← 4 roles: app-sa, developer, oncall, cicd
│   ├── network-policies/             ← Zero-trust: deny-all + explicit allows
│   ├── pod-security/                 ← No root, resource limits enforced
│   ├── secrets-management/
│   │   ├── external-secrets.yaml     ← ESO pulls from GCP Secret Manager
│   │   └── seed-secrets.sh           ← One-time secret seeding script
│   └── tls/
│       ├── cert-manager.yaml         ← Auto SSL via Let's Encrypt
│       └── ingress-tls.yaml          ← HTTPS Ingress with cert-manager
│
├── cost/
│   ├── cost_monitor.py               ← Daily idle resource + spend check
│   └── budget-alerts.tf              ← GCP budget alerts at 50/80/100/120%
│
├── scripts/
│   ├── setup-gcp.sh                  ← FIRST: enables APIs, creates service account
│   ├── setup-backend.sh              ← Creates GCS bucket for Terraform state
│   ├── setup-monitoring.sh           ← GCP native monitoring channels + uptime
│   ├── setup-observability.sh        ← Full stack: Prometheus+Grafana+Loki+OTel
│   ├── health_monitor.py             ← Runs every 60s, alerts after 3 failures
│   ├── log_archival.py               ← Archives pod logs to GCS, prunes old ones
│   ├── load-test.sh                  ← Flash sale simulation
│   └── ops.sh                        ← status, logs, rollback, restart, scale
│
├── disaster-recovery/
│   ├── dr_backup.py                  ← Cloud SQL + K8s state → GCS every 6h
│   └── dr_restore.sh                 ← Full cluster restore from backup
│
├── local-dev/
│   ├── docker-compose.yaml           ← Full stack locally (all services + tools)
│   ├── prometheus.yml                ← Local Prometheus scrape config
│   ├── otel-collector-config.yaml    ← Local OTel → Jaeger
│   └── init-db.sql                   ← Creates tables + seed data for local dev
│
└── docs/
    ├── runbooks/
    │   └── payment-service-outage.md ← P0 runbook: 5 causes + exact commands
    ├── interview-prep/
    │   └── interview-questions.md    ← Q&A for every topic in this project
    └── PROJECT-STRUCTURE.md          ← This file
```

---

## Technology Map

| Layer | Technology | File |
|-------|-----------|------|
| Compute | GKE Autopilot | `terraform/modules/gke/` |
| Compute (AWS) | EKS + Managed Node Group | `aws/terraform/modules/eks/` |
| Networking | VPC, Cloud NAT, Firewall | `terraform/modules/vpc/` |
| Database | Cloud SQL PostgreSQL | `terraform/modules/cloudsql/` |
| Database (AWS) | RDS PostgreSQL Multi-AZ | `aws/terraform/modules/rds/` |
| Container Registry | GCR + ECR | CI/CD pipeline |
| IaC | Terraform (modular) | `terraform/` + `aws/terraform/` |
| CI/CD | GitHub Actions | `github-actions/ci-cd.yaml` |
| GitOps | ArgoCD | `argocd/apps.yaml` |
| Metrics | Prometheus + Grafana | `monitoring/prometheus/` |
| Logs | Loki + Promtail | `monitoring/loki/` |
| Traces | OpenTelemetry + Cloud Trace | `k8s/tracing/` |
| SLOs | Burn-rate alerting | `monitoring/slo/` |
| Secrets | GCP Secret Manager + ESO | `security/secrets-management/` |
| TLS | cert-manager + Let's Encrypt | `security/tls/` |
| RBAC | K8s Roles + Workload Identity | `security/rbac/` |
| Network Security | K8s NetworkPolicies | `security/network-policies/` |
| DR | Cloud SQL export + K8s backup | `disaster-recovery/` |
| Cost | Budget alerts + idle detection | `cost/` |
| Local Dev | Docker Compose + Jaeger | `local-dev/` |
