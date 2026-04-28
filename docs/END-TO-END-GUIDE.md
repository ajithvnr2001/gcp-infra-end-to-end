# End-to-End Project Guide

This document explains how the storefront, services, infrastructure, and delivery workflow fit together after the recent end-to-end cleanup.

## 1. Scope

The project demonstrates a production-style commerce stack with these layers:

- Frontend storefront served by NGINX.
- API gateway that aggregates internal service APIs.
- Catalog, cart, and payment microservices.
- Terraform-managed GCP infrastructure.
- Kubernetes manifests for runtime deployment.
- Cloud Build plus ArgoCD for delivery.
- Monitoring and tracing assets under `monitoring/` and `k8s/tracing/`.

## 2. Application request flow

### Browsing products

1. The browser loads the frontend from `frontend-service`.
2. The frontend requests `GET /api/products`.
3. NGINX proxies `/api/*` to `api-gateway` when the frontend is hit directly.
4. In cluster mode, ingress can route `/api/*` to the gateway as well.
5. The gateway fetches products from `catalog-service`.

### Managing the cart

Cart operations use the shopper session ID stored in local storage:

- `GET /api/cart/{user_id}`
- `POST /api/cart/{user_id}/add`
- `PUT /api/cart/{user_id}/items/{product_id}`
- `DELETE /api/cart/{user_id}/remove/{product_id}`
- `DELETE /api/cart/{user_id}/clear`

The cart service keeps an in-memory cart map keyed by user ID. In a real production deployment, this should move to Redis or a database-backed session layer.

### Placing an order

1. The frontend submits `POST /api/orders`.
2. The gateway forwards the order payload to `payment-service`.
3. The payment service creates an order record and returns the confirmation.
4. The gateway clears the cart for the same user after order creation succeeds.
5. The frontend reloads cart state and order history.

### Viewing order history

The storefront uses:

- `GET /api/orders/user/{user_id}`

This gives the shopper an immediate view of the orders created during the current browser session.

## 3. Frontend structure

The storefront lives in `services/frontend/`.

### Files

- `index.html`: page layout and checkout drawer markup.
- `index.css`: visual system, layout, motion, and responsive rules.
- `app.js`: state management, API calls, filtering, cart behavior, checkout, and order history rendering.
- `nginx.conf`: static file serving and `/api` reverse proxy.
- `Dockerfile`: unprivileged NGINX container image.

### New storefront behavior

Compared to the previous version, the frontend now provides:

- Search by product name or description.
- Category chips generated from the live catalog.
- Sorting by featured order, rating, and price.
- Session-specific shopper identity.
- Quantity changes directly in the cart drawer.
- Structured checkout fields required by the payment contract.
- Live order ledger after checkout.

### Frontend API assumptions

The frontend expects:

- Product objects to include `id`, `name`, `price`, `category`, `stock`, `rating`, `description`, `badge`, and `eta`.
- Cart items to include `product_id`, `product_name`, `price`, `quantity`, and optional `category`.
- Orders to return `order_id`, `status`, `total`, `payment_method`, `created_at`, `address`, and `item_count`.

## 4. Service updates

### API gateway

`services/api-gateway/main.py` now:

- Uses a shared request helper for upstream error handling.
- Exposes cart quantity update and clear/remove routes.
- Exposes order history by user.
- Clears the cart after a successful order.
- Returns upstream status codes instead of silently swallowing them.

### Catalog service

`services/catalog/main.py` now:

- Returns a richer curated catalog for the storefront.
- Keeps Prometheus and tracing support.
- Gracefully degrades if OpenTelemetry instrumentation packages are unavailable or version-mismatched.

That last change matters because test runs were failing previously due to an OpenTelemetry import conflict.

### Cart service

`services/cart/main.py` now:

- Returns a consistent cart response with `item_count`.
- Supports quantity updates through a dedicated route.
- Supports remove and clear behavior with response payloads that the frontend can render directly.
- Uses `model_dump()` for Pydantic v2 compatibility.

### Payment service

`services/payment/main.py` now:

- Requires checkout fields the frontend actually captures.
- Stores payment method, address, customer identity, and item count.
- Returns order history cleanly.
- Uses `model_dump()` for Pydantic v2 compatibility.

## 5. Local development workflow

Use `local-dev/docker-compose.yaml` for a full-stack local run.

### Start the stack

```bash
cd local-dev
docker compose up --build
```

### Local endpoints

- Storefront: `http://localhost:3001`
- API gateway: `http://localhost:8080`
- Catalog: `http://localhost:8000`
- Cart: `http://localhost:8001`
- Payment: `http://localhost:8002`
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`
- Jaeger: `http://localhost:16686`

### Local smoke test

Once the stack is up:

1. Open `http://localhost:3001`.
2. Add at least one product to the cart.
3. Open the cart drawer.
4. Fill name and address.
5. Submit the order.
6. Confirm:
   - Cart total resets to zero.
   - A new order appears in the order ledger.
   - Gateway health shows as healthy.

## 6. Kubernetes runtime notes

Relevant files:

- `k8s/deployments/catalog-deployment.yaml`
- `k8s/deployments/other-deployments.yaml`
- `k8s/deployments/frontend-deployment.yaml`
- `k8s/services/services.yaml`
- `k8s/security/tls/ingress-tls.yaml`

Notable fixes made during this update:

- Added missing `containerPort` entries for cart and payment deployments.
- Added `healthz` probes for the frontend deployment.
- Added a frontend-level NGINX proxy so direct service access still preserves `/api` behavior.

## 7. Validation performed

These checks were run successfully in this environment:

```bash
python -m py_compile services/api-gateway/main.py services/cart/main.py services/payment/main.py services/catalog/main.py
python -m pytest services/catalog/tests/test_catalog.py services/cart/tests/test_cart.py services/payment/tests/test_payment.py
```

Observed result:

- `18 passed`

## 8. What was not validated here

The following were not confirmed in this environment:

- Docker Compose configuration rendering, because `docker` is not installed here.
- A live browser walkthrough against the updated storefront, because the full stack was not started inside this session.
- Cloud Build, ArgoCD, Terraform apply, or a real GKE deploy.

Those are operational checks, not code-level blockers, but they are still worth verifying in your target environment.

## 9. Follow-up recommendations

If you want to take this from strong demo to stronger production baseline, the next useful steps are:

1. Move cart and order state out of memory into persistent storage.
2. Add API gateway integration tests that exercise downstream service orchestration.
3. Add a browser-based smoke test for the storefront.
4. Add Compose or container CI validation once Docker is available.
5. Replace hard-coded catalog seed data with database-backed reads.
