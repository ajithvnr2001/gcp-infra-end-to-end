# Project Spec - GCP Ecommerce DevOps Platform

This folder explains the ecommerce GCP project from an interview and operations perspective.

Use it to learn:

- How to read the repository.
- What each service does.
- How traffic flows.
- How to access each URL from `log.txt`.
- How to check health, logs, metrics, ArgoCD, Kubernetes, and Terraform.
- How to test the project locally and in cluster.
- How to prepare interviews using only this project.

## Recommended Reading Order

1. `01-project-overview.md`
2. `02-how-to-read-this-repo.md`
3. `03-log-links-and-access-guide.md`
4. `04-service-by-service-guide.md`
5. `05-kubernetes-gitops-deployment-guide.md`
6. `06-monitoring-observability-guide.md`
7. `07-testing-validation-guide.md`
8. `08-troubleshooting-runbook.md`
9. `09-interview-preparation-from-this-project.md`
10. `10-gcp-to-aws-project-mapping.md`
11. `11-command-cheatsheet.md`
12. `12-url-navigation-deep-guide.md`
13. `13-argocd-applications-deep-guide.md`
14. `14-end-to-end-project-interview-master-guide.md`
15. `15-free-trial-gke-capacity-fix.md`
16. `16-monitoring-helm-free-trial-fix.md`

## One-Line Project Summary

```text
This is a GCP-based ecommerce microservices platform using Docker, GKE, Terraform, Cloud Build, Artifact Registry, ArgoCD, Kubernetes manifests, Prometheus/Grafana, and production-style security/observability patterns.
```

## Links Found In log.txt

These links are local access URLs after port-forwarding:

- ArgoCD: `https://localhost:8080`
- Grafana: `http://localhost:3000`
- Prometheus: `http://localhost:9090`
- Frontend via ingress port-forward: `https://localhost/`

Do not treat these as public hosted URLs. They work only when the corresponding `kubectl port-forward` command is running.

For detailed click-by-click navigation, curl findings, Prometheus target observations, and how each screen relates to this project, read `12-url-navigation-deep-guide.md`.

For ArgoCD-specific navigation using `https://localhost:8080/applications`, read `13-argocd-applications-deep-guide.md`.

For the full project story across Terraform, GKE, CI/CD, GitOps, Kubernetes, monitoring, security, troubleshooting, AWS mapping, and interview answers, read `14-end-to-end-project-interview-master-guide.md`.

For the catalog-service `Insufficient cpu` and topology spread scheduling fix on a free-trial GKE cluster, read `15-free-trial-gke-capacity-fix.md`.

For the Prometheus/Grafana Helm install stuck on Grafana PVC in a free-trial GKE cluster, read `16-monitoring-helm-free-trial-fix.md`.
