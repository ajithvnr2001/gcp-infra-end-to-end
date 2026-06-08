# 11 - Command Cheatsheet

## Kubernetes Basics

```bash
kubectl get ns
kubectl get all -n ecommerce
kubectl get pods -n ecommerce
kubectl get deploy -n ecommerce
kubectl get svc -n ecommerce
kubectl get endpoints -n ecommerce
kubectl get hpa -n ecommerce
```

## Logs And Events

```bash
kubectl logs deploy/frontend-service -n ecommerce
kubectl logs deploy/api-gateway -n ecommerce
kubectl logs deploy/catalog-service -n ecommerce
kubectl logs deploy/cart-service -n ecommerce
kubectl logs deploy/payment-service -n ecommerce
kubectl get events -n ecommerce --sort-by=.lastTimestamp
```

## Rollouts

```bash
kubectl rollout status deployment/api-gateway -n ecommerce
kubectl rollout history deployment/api-gateway -n ecommerce
kubectl rollout undo deployment/api-gateway -n ecommerce
```

## Port Forwarding

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 80:80 443:443
kubectl port-forward svc/api-gateway -n ecommerce 8080:8080
kubectl port-forward svc/catalog-service -n ecommerce 8000:8000
```

## Health Checks

```bash
curl http://localhost:8080/health
curl http://localhost:8080/ready
curl http://localhost:8080/products
curl http://localhost:8000/metrics
```

## Cloud Build

```bash
gcloud builds list --project <PROJECT_ID>
gcloud builds log <BUILD_ID> --project <PROJECT_ID>
```

## Artifact Registry

```bash
gcloud artifacts repositories list --location us-central1 --project <PROJECT_ID>
gcloud artifacts docker images list us-central1-docker.pkg.dev/<PROJECT_ID>/ecommerce-docker
```

## Terraform

```bash
cd terraform/envs/prod
terraform init -reconfigure
terraform plan
terraform apply
```

## Local Compose

```bash
cd local-dev
docker compose up --build
docker compose ps
docker compose logs -f api-gateway
docker compose down
```

