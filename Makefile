# Makefile
# One command shortcuts for everything
# Usage: make <target>
# Example: make local-up, make test, make deploy

.PHONY: help local-up local-down test lint build push k8s-deploy argocd-sync status logs rollback

PROJECT_ID  ?= your-gcp-project-id
REGION      ?= asia-south1
SERVICES    := catalog cart payment api-gateway
NAMESPACE   := ecommerce
SHA         := $(shell git rev-parse --short HEAD)

help:   ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ── Local Development ────────────────────────────────────────────────────────
local-up:   ## Start full stack locally (all services + Grafana + Jaeger)
	cd local-dev && docker compose up --build -d
	@echo ""
	@echo "✅ Stack running:"
	@echo "   API:        http://localhost:8080"
	@echo "   Grafana:    http://localhost:3000  (admin/admin)"
	@echo "   Prometheus: http://localhost:9090"
	@echo "   Jaeger:     http://localhost:16686"

local-down:   ## Stop local stack
	cd local-dev && docker compose down

local-logs:   ## Tail local logs
	cd local-dev && docker compose logs -f

local-reset:   ## Reset local stack (delete volumes)
	cd local-dev && docker compose down -v && docker compose up --build -d

# ── Testing ──────────────────────────────────────────────────────────────────
test:   ## Run all service tests
	@for svc in $(SERVICES); do \
	  echo "Testing $$svc..."; \
	  cd services/$$svc && pip install -r requirements.txt -q && \
	  pytest tests/ -v --tb=short; cd ../..; \
	done

test-service:   ## Run tests for a specific service: make test-service SVC=catalog
	cd services/$(SVC) && pip install -r requirements.txt -q && pytest tests/ -v

lint:   ## Lint all services
	@for svc in $(SERVICES); do \
	  echo "Linting $$svc..."; \
	  flake8 services/$$svc/ --max-line-length=120 --ignore=E501,W503; \
	done

# ── Docker Build & Push ───────────────────────────────────────────────────────
build:   ## Build all Docker images
	@for svc in $(SERVICES); do \
	  echo "Building $$svc:$(SHA)..."; \
	  docker build -t gcr.io/$(PROJECT_ID)/$$svc:$(SHA) services/$$svc/; \
	done

push:   ## Push all images to GCR
	@gcloud auth configure-docker --quiet
	@for svc in $(SERVICES); do \
	  echo "Pushing $$svc:$(SHA)..."; \
	  docker push gcr.io/$(PROJECT_ID)/$$svc:$(SHA); \
	done

build-push: build push   ## Build and push all images

# ── Terraform ────────────────────────────────────────────────────────────────
tf-init:   ## Terraform init (GCP)
	cd terraform/envs/prod && terraform init

tf-plan:   ## Terraform plan (GCP)
	cd terraform/envs/prod && terraform plan \
	  -var="project_id=$(PROJECT_ID)" -var="region=$(REGION)" -var="db_password=CHANGE_ME"

tf-apply:   ## Terraform apply (GCP) — prompts for confirmation
	cd terraform/envs/prod && terraform apply \
	  -var="project_id=$(PROJECT_ID)" -var="region=$(REGION)"

tf-plan-aws:   ## Terraform plan (AWS)
	cd aws/terraform/envs/prod && terraform plan

# ── Kubernetes ────────────────────────────────────────────────────────────────
k8s-deploy:   ## Apply all K8s manifests
	kubectl apply -f k8s/namespaces/
	kubectl apply -f k8s/configmaps/
	kubectl apply -f k8s/deployments/
	kubectl apply -f k8s/services/
	kubectl apply -f k8s/hpa/
	kubectl apply -f k8s/ingress/

k8s-security:   ## Apply security policies (RBAC, NetworkPolicies)
	kubectl apply -f security/rbac/
	kubectl apply -f security/network-policies/
	kubectl apply -f security/secrets-management/

argocd-sync:   ## Force ArgoCD sync from git
	argocd app sync ecommerce-catalog --force

status:   ## Show cluster status
	@./scripts/ops.sh status

logs:   ## Tail logs for a service: make logs SVC=catalog-service
	@./scripts/ops.sh logs $(SVC)

rollback:   ## Rollback a service: make rollback SVC=catalog-service
	@./scripts/ops.sh rollback $(SVC)

# ── Observability ─────────────────────────────────────────────────────────────
obs-up:   ## Install full observability stack
	./scripts/setup-observability.sh $(PROJECT_ID)

grafana:   ## Port-forward Grafana to localhost:3000
	kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80

prometheus:   ## Port-forward Prometheus to localhost:9090
	kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090

jaeger:   ## Port-forward Jaeger to localhost:16686 (local dev)
	kubectl port-forward svc/jaeger -n monitoring 16686:16686

# ── Load Testing ──────────────────────────────────────────────────────────────
load-test:   ## Run flash sale load test
	./scripts/load-test.sh http://localhost:8080 50 60

# ── Setup ─────────────────────────────────────────────────────────────────────
setup-gcp:   ## First-time GCP setup
	./scripts/setup-gcp.sh $(PROJECT_ID)

setup-backend:   ## Create Terraform remote state bucket
	./scripts/setup-backend.sh $(PROJECT_ID)

setup-secrets:   ## Seed secrets into GCP Secret Manager
	./security/secrets-management/seed-secrets.sh $(PROJECT_ID)

setup-all: setup-gcp setup-backend tf-init tf-apply k8s-deploy obs-up   ## Full setup from scratch
