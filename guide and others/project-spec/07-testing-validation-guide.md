# 07 - Testing And Validation Guide

## Local Development Test

Start local stack:

```bash
cd local-dev
docker compose up --build
```

Open:

```text
Frontend: http://localhost:3001
API gateway: http://localhost:8080
Prometheus: http://localhost:9090
Grafana: http://localhost:3000
Jaeger: http://localhost:16686
```

## Service Health Tests

API gateway:

```bash
curl http://localhost:8080/health
curl http://localhost:8080/ready
curl http://localhost:8080/products
```

Catalog:

```bash
curl http://localhost:8000/health
curl http://localhost:8000/products
curl http://localhost:8000/products/p1
curl http://localhost:8000/products?category=workspace
```

Cart:

```bash
curl http://localhost:8001/health
curl http://localhost:8001/cart/test-user
```

Payment:

```bash
curl http://localhost:8002/health
```

## Full API Flow Test Through Gateway

Get products:

```bash
curl http://localhost:8080/products
```

Add item:

```bash
curl -X POST http://localhost:8080/cart/test-user/add \
  -H "Content-Type: application/json" \
  -d '{"product_id":"p1","product_name":"Astra Wireless Headphones","price":1999,"quantity":1,"category":"audio"}'
```

Get cart:

```bash
curl http://localhost:8080/cart/test-user
```

Create order:

```bash
curl -X POST http://localhost:8080/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test-user","items":[{"product_id":"p1","product_name":"Astra Wireless Headphones","price":1999,"quantity":1}],"address":"123 Test Street Chennai","payment_method":"razorpay","customer_name":"Ajith","customer_email":"ajith@example.com"}'
```

Check order history:

```bash
curl http://localhost:8080/orders/user/test-user
```

## Python Unit/API Tests

Existing tests:

```text
services/api-gateway/tests/test_gateway.py
services/catalog/tests/test_catalog.py
services/cart/tests/test_cart.py
services/payment/tests/test_payment.py
```

Run:

```bash
python -m pytest services/api-gateway/tests/test_gateway.py services/catalog/tests/test_catalog.py services/cart/tests/test_cart.py services/payment/tests/test_payment.py
```

Syntax checks:

```bash
python -m py_compile services/api-gateway/main.py services/catalog/main.py services/cart/main.py services/payment/main.py
node --check services/frontend/app.js
```

## Kubernetes Validation

Cluster:

```bash
kubectl get nodes
kubectl get ns
kubectl get all -n ecommerce
```

Pods:

```bash
kubectl get pods -n ecommerce
kubectl describe pod <pod> -n ecommerce
kubectl logs <pod> -n ecommerce
```

Rollout:

```bash
kubectl rollout status deployment/api-gateway -n ecommerce
kubectl rollout status deployment/catalog-service -n ecommerce
kubectl rollout status deployment/cart-service -n ecommerce
kubectl rollout status deployment/payment-service -n ecommerce
kubectl rollout status deployment/frontend-service -n ecommerce
```

Services:

```bash
kubectl get svc -n ecommerce
kubectl get endpoints -n ecommerce
```

HPA:

```bash
kubectl get hpa -n ecommerce
```

ArgoCD:

```bash
kubectl get application ecommerce-catalog -n argocd
```

## CI/CD Validation

Check Cloud Build:

```bash
gcloud builds list --project <PROJECT_ID>
gcloud builds log <BUILD_ID> --project <PROJECT_ID>
```

Check Artifact Registry images:

```bash
gcloud artifacts docker images list us-central1-docker.pkg.dev/<PROJECT_ID>/ecommerce-docker
```

Check specific image:

```bash
gcloud artifacts docker images describe us-central1-docker.pkg.dev/<PROJECT_ID>/ecommerce-docker/api-gateway:latest
```

## Interview Testing Answer

```text
I test at multiple layers: unit/API tests for services, Docker build tests for image packaging, local Compose for integration, Kubernetes rollout checks for deployment, health/readiness endpoints for runtime, and Prometheus/Grafana for operational validation.
```

