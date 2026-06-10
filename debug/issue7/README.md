# GKE E-Commerce Platform

Production-style e-commerce platform built around GKE, Terraform, GitOps, and a multi-service checkout flow.

The repository now includes:

- A richer storefront in `services/frontend` with search, category filters, a live cart drawer, checkout details, and order history.
- A completed service contract between the frontend, API gateway, cart service, and payment service.
- A local end-to-end path through `local-dev/docker-compose.yaml`.
- Updated tests for the catalog, cart, and payment services.

## What the project does

The platform models a simple premium commerce experience:

- `catalog-service` serves curated products.
- `cart-service` stores cart state per shopper.
- `payment-service` creates orders and exposes order history.
- `api-gateway` fronts the internal services and clears the cart after successful checkout.
- `frontend-service` serves the static storefront and proxies `/api/*` traffic to the gateway when running locally or directly.

## Architecture

```text
Browser
  -> Frontend (NGINX + static app)
  -> /api/* -> API Gateway
      -> Catalog Service
      -> Cart Service
      -> Payment Service

Terraform
  -> VPC
  -> GKE
  -> Cloud SQL

GitOps / Delivery
  -> Cloud Build
  -> Container registry
  -> ArgoCD
  -> Kubernetes manifests in k8s/
```

## Frontend improvements

The storefront is no longer a demo-only product grid. It now supports:

- Live product search and category filtering.
- Sort controls for featured, rating, and price.
- Quantity update and remove actions in the cart drawer.
- Checkout form with name, email, address, and payment method.
- Automatic order confirmation refresh and session order history.
- Same-origin `/api` behavior through NGINX proxying.

## Backend flow

The end-to-end checkout path is:

1. Frontend loads products from `GET /api/products`.
2. Cart actions call gateway routes such as `POST /api/cart/{user_id}/add` and `PUT /api/cart/{user_id}/items/{product_id}`.
3. Checkout calls `POST /api/orders`.
4. The API gateway forwards the order to the payment service.
5. After a successful order, the gateway clears the shopper cart in the cart service.
6. The frontend reloads cart state and order history from `GET /api/orders/user/{user_id}`.

## Local development

The repo includes a local full-stack path with Docker Compose:

```bash
cd local-dev
docker compose up --build
```

Expected endpoints:

- Storefront: `http://localhost:3001`
- API gateway: `http://localhost:8080`
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`
- Jaeger: `http://localhost:16686`

Note:

- I could not run `docker compose config` here because Docker is not installed in this environment.
- The frontend config assumes the gateway service name is `api-gateway`, which matches the Compose file and Kubernetes service name.

## Test status

Validated in this environment:

```bash
python -m py_compile services/api-gateway/main.py services/cart/main.py services/payment/main.py services/catalog/main.py
python -m pytest services/catalog/tests/test_catalog.py services/cart/tests/test_cart.py services/payment/tests/test_payment.py
```

Result:

- `18 passed`

## Deployment areas

- Terraform: `terraform/`
- Kubernetes manifests: `k8s/`
- ArgoCD app definition: `argocd/apps.yaml`
- CI pipeline: `cloudbuild.yaml`

## Recommended docs to read next

- [Detailed End-to-End Guide](docs/END-TO-END-GUIDE.md)
- [Deployment Guide](docs/deployment/deployment-guide.md)
- [Project Structure](docs/PROJECT-STRUCTURE.md)
- [Observability Hardening](docs/OBSERVABILITY-HARDENING.md)

## Current validation limits

I confirmed Python syntax and the backend test suite. I did not validate:

- Docker Compose rendering, because Docker is not available in this environment.
- A real browser session against the new frontend, because that would require a running stack.

## Verification

### Validation completed in this session

The following validations were completed against the updated codebase on April 20, 2026:

```bash
python -m py_compile services/api-gateway/main.py services/cart/main.py services/payment/main.py services/catalog/main.py
node --check services/frontend/app.js
python -m pytest services/api-gateway/tests/test_gateway.py services/catalog/tests/test_catalog.py services/cart/tests/test_cart.py services/payment/tests/test_payment.py
```

Observed outcomes:

- Python syntax validation passed for `services/api-gateway/main.py`, `services/cart/main.py`, `services/payment/main.py`, and `services/catalog/main.py`.
- Frontend JavaScript syntax validation passed for `services/frontend/app.js`.
- Backend automated test suite passed with `21 passed`.
- API gateway orchestration is now directly covered in tests, including product proxying, order creation, and cart clear behavior after checkout.

### Verification details by area

#### API Gateway verification

Verified behavior in `services/api-gateway/main.py`:

- `GET /products` forwards product reads to the catalog service.
- `GET /orders/user/{user_id}` forwards order history lookups to the payment service.
- `POST /orders` forwards checkout payloads to the payment service.
- After successful order creation, the gateway issues a cart clear request for the same user.
- Shared upstream error handling was introduced so downstream failures are surfaced more cleanly.

Test coverage added:

- `services/api-gateway/tests/test_gateway.py`
  - product fetch proxying
  - order creation
  - cart clear after successful checkout
  - order history by user

#### Catalog verification

Verified behavior in `services/catalog/main.py`:

- health endpoint responds successfully
- readiness endpoint responds successfully
- product listing works
- category filtering works
- product lookup by ID works
- search route works

Catalog improvements verified in code:

- richer product payload with `description`, `badge`, and `eta`
- better category coverage for the expanded storefront
- OpenTelemetry startup made tolerant to local import/version mismatch so tests do not fail during import

#### Cart verification

Verified behavior in `services/cart/main.py`:

- empty cart returns a stable cart payload
- add-to-cart returns updated cart state
- total is recalculated correctly
- quantity update route works
- clear-cart works
- full cart responses now include `item_count`

Cart improvements verified in code:

- full response payload returned from add, update, remove, and clear operations
- quantity mutation support added with `PUT /cart/{user_id}/items/{product_id}`
- Pydantic v2-safe `model_dump()` used instead of deprecated `.dict()`

#### Payment verification

Verified behavior in `services/payment/main.py`:

- order creation works with the updated checkout contract
- order lookup by ID works
- order history by user works
- invalid order IDs return not found

Payment improvements verified in code:

- `customer_name` added to the request contract
- optional `customer_email` added to the request contract
- `payment_method`, `address`, and `item_count` included in the modeled response path
- Pydantic v2-safe `model_dump()` used instead of deprecated `.dict()`

#### Frontend verification

Verified at source level in `services/frontend/`:

- `app.js` passes JavaScript syntax validation
- the storefront now includes:
  - live search
  - category chips
  - sort controls
  - cart drawer
  - quantity updates
  - remove item actions
  - checkout form
  - order history
  - gateway health display
- `nginx.conf` was added so `/api/*` is proxied to `api-gateway`
- `Dockerfile` was updated to copy the new NGINX config

Frontend files changed:

- `services/frontend/index.html`
- `services/frontend/index.css`
- `services/frontend/app.js`
- `services/frontend/Dockerfile`
- `services/frontend/nginx.conf`

### Changes completed across the project

#### Frontend and user flow changes

The storefront was upgraded from a basic demo page to a more complete e-commerce flow:

- rebuilt layout with hero, catalog, cart, checkout, and order history sections
- stronger responsive styling and visual system
- session-based shopper identity
- same-origin API behavior through frontend NGINX proxying
- order history refresh after successful purchase

#### Backend service contract changes

The end-to-end contract between frontend and services was aligned:

- cart payloads now return consistent state to the frontend
- payment payloads now match real checkout form fields
- gateway supports the missing cart update and order history routes
- checkout flow now clears the cart after order creation succeeds

#### Kubernetes manifest changes

Deployment manifest improvements made:

- `k8s/deployments/frontend-deployment.yaml`
  - added liveness probe
  - added readiness probe
  - probes now use `/healthz`
- `k8s/deployments/other-deployments.yaml`
  - added missing `containerPort` values for cart and payment containers

#### Local development and docs changes

- `local-dev/docker-compose.yaml` updated to include the frontend service and expose the storefront on `http://localhost:3001`
- `README.md` rewritten to match the updated project state
- `docs/END-TO-END-GUIDE.md` added with a detailed architecture and flow guide
- `.gitignore` adjusted so the new detailed guide and local compose file can be tracked if needed

### Bugs found during verification and fixed

These issues were discovered while validating the changes:

- OpenTelemetry import mismatch in `services/catalog/main.py`
  - This caused test collection failure during import.
  - Fixed by making instrumentation setup resilient when OTEL components are missing or version-mismatched.
- Test module import collision across services
  - Multiple test files were importing `from main import app`, which caused pytest to reuse the wrong module.
  - Fixed by loading each service `main.py` with `importlib.util.spec_from_file_location(...)` under a unique module name.
- Pydantic deprecation warnings
  - `.dict()` usage caused warnings under Pydantic v2.
  - Fixed by replacing those calls with `.model_dump()`.

### What is verified vs not fully verified

Verified:

- Python syntax for core backend services
- JavaScript syntax for the rewritten frontend app
- backend test suite for gateway, catalog, cart, and payment
- request/response contract alignment in the updated code

Not fully verified in this environment:

- live Docker Compose execution, because `docker` is not installed here
- live browser walkthrough of the storefront
- full Kubernetes rollout on GKE
- Cloud Build, ArgoCD sync, ingress routing, and public runtime validation

### Confidence summary

Current confidence is strong for source-level correctness in the changed paths because:

- automated backend tests passed with `21 passed`
- syntax validation passed for the Python services
- syntax validation passed for the rewritten frontend JavaScript
- the main issues found during verification were fixed and re-tested

The remaining risk is runtime environment validation, not currently known code-level breakage.
