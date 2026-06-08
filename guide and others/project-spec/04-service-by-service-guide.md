# 04 - Service By Service Guide

## Service Ports

| Service | Internal Port | Kubernetes Service |
|---|---:|---|
| frontend-service | 8080 | frontend-service:80 |
| api-gateway | 8080 | api-gateway:8080 |
| catalog-service | 8000 | catalog-service:8000 |
| cart-service | 8001 | cart-service:8001 |
| payment-service | 8002 | payment-service:8002 |

## Frontend Service

Path:

```text
services/frontend
```

Main files:

```text
index.html
index.css
app.js
nginx.conf
Dockerfile
```

Purpose:

- Serves ecommerce UI.
- Proxies `/api/*` to API gateway in local/container setup.
- Supports product search, category filters, cart drawer, checkout form, and order history.

Kubernetes:

```text
k8s/deployments/frontend-deployment.yaml
```

Health:

```text
/healthz
```

Check in cluster:

```bash
kubectl get deploy frontend-service -n ecommerce
kubectl get pods -l app=frontend-service -n ecommerce
kubectl logs deploy/frontend-service -n ecommerce
kubectl port-forward svc/frontend-service -n ecommerce 3001:80
```

Interview answer:

```text
The frontend is served by NGINX and separated from backend services. This allows independent scaling and deployment.
```

## API Gateway

Path:

```text
services/api-gateway/main.py
```

Purpose:

- Single API entry point.
- Routes product APIs to catalog.
- Routes cart APIs to cart.
- Routes order APIs to payment.
- Clears cart after successful order creation.

Important env vars:

```text
CATALOG_URL=http://catalog-service:8000
CART_URL=http://cart-service:8001
PAYMENT_URL=http://payment-service:8002
```

Endpoints:

```text
GET /health
GET /ready
GET /products
GET /products/{product_id}
GET /cart/{user_id}
POST /cart/{user_id}/add
PUT /cart/{user_id}/items/{product_id}
DELETE /cart/{user_id}/remove/{product_id}
DELETE /cart/{user_id}/clear
POST /orders
GET /orders/{order_id}
GET /orders/user/{user_id}
```

Check:

```bash
kubectl logs deploy/api-gateway -n ecommerce
kubectl port-forward svc/api-gateway -n ecommerce 8080:8080
curl http://localhost:8080/health
curl http://localhost:8080/ready
curl http://localhost:8080/products
```

Readiness meaning:

```text
API gateway readiness calls health endpoints of catalog, cart, and payment. If one dependency fails, gateway is not ready.
```

Interview answer:

```text
The API gateway hides internal services from the frontend and centralizes routing. It is also where real production systems often add auth, rate limiting, and request tracing.
```

## Catalog Service

Path:

```text
services/catalog/main.py
```

Purpose:

- Product list.
- Product lookup.
- Category filter.
- Product search.
- Prometheus metrics.
- Structured JSON logs.
- OpenTelemetry tracing support.

Endpoints:

```text
GET /health
GET /ready
GET /metrics
GET /products
GET /products?category=workspace
GET /products/{product_id}
GET /products/search/{query}
```

Check:

```bash
kubectl logs deploy/catalog-service -n ecommerce
kubectl port-forward svc/catalog-service -n ecommerce 8000:8000
curl http://localhost:8000/health
curl http://localhost:8000/products
curl http://localhost:8000/metrics
```

Metrics:

```text
http_requests_total
http_request_duration_seconds
```

Interview answer:

```text
Catalog is a read-heavy service. It exposes health, readiness, and metrics endpoints, making it easy to monitor request rate, latency, and errors.
```

## Cart Service

Path:

```text
services/cart/main.py
```

Purpose:

- Maintains user cart in memory.
- Add item.
- Update quantity.
- Remove item.
- Clear cart.
- Return cart total and item count.

Endpoints:

```text
GET /health
GET /ready
GET /cart/{user_id}
POST /cart/{user_id}/add
PUT /cart/{user_id}/items/{product_id}
DELETE /cart/{user_id}/remove/{product_id}
DELETE /cart/{user_id}/clear
```

Check:

```bash
kubectl logs deploy/cart-service -n ecommerce
kubectl port-forward svc/cart-service -n ecommerce 8001:8001
curl http://localhost:8001/health
curl http://localhost:8001/cart/test-user
```

Important limitation:

```text
Cart uses in-memory state in this project. In production, replace it with Redis or a persistent store.
```

Interview answer:

```text
The cart service demonstrates stateful behavior. For real production I would use Redis or a database because in-memory state is lost when pods restart or scale.
```

## Payment Service

Path:

```text
services/payment/main.py
```

Purpose:

- Creates orders.
- Generates order ID.
- Calculates total.
- Stores orders in memory.
- Returns order by ID.
- Returns order history by user.

Endpoints:

```text
GET /health
GET /ready
POST /orders
GET /orders/{order_id}
GET /orders/user/{user_id}
```

Check:

```bash
kubectl logs deploy/payment-service -n ecommerce
kubectl port-forward svc/payment-service -n ecommerce 8002:8002
curl http://localhost:8002/health
```

Important limitation:

```text
Orders are stored in memory in this project. In production, use Cloud SQL/RDS and make order creation idempotent.
```

Interview answer:

```text
Payment/order service is critical. I would focus on idempotency, persistence, audit logs, retry safety, and secure secret handling in production.
```

