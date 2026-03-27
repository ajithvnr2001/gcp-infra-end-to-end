#!/bin/bash
# scripts/ops.sh
# Day-to-day production operations helper
# Usage: ./ops.sh <command> [service]

NAMESPACE="ecommerce"
CMD=$1
SERVICE=$2

case $CMD in

  status)
    echo "=== Pods ==="
    kubectl get pods -n $NAMESPACE -o wide
    echo ""
    echo "=== HPA (autoscaling) ==="
    kubectl get hpa -n $NAMESPACE
    echo ""
    echo "=== Services ==="
    kubectl get svc -n $NAMESPACE
    echo ""
    echo "=== Ingress ==="
    kubectl get ingress -n $NAMESPACE
    ;;

  logs)
    if [ -z "$SERVICE" ]; then echo "Usage: ./ops.sh logs <service-name>"; exit 1; fi
    kubectl logs -n $NAMESPACE -l app=$SERVICE --tail=100 -f
    ;;

  rollback)
    if [ -z "$SERVICE" ]; then echo "Usage: ./ops.sh rollback <service-name>"; exit 1; fi
    echo "⏪ Rolling back $SERVICE..."
    kubectl rollout undo deployment/$SERVICE -n $NAMESPACE
    kubectl rollout status deployment/$SERVICE -n $NAMESPACE
    echo "✅ Rollback complete"
    ;;

  restart)
    if [ -z "$SERVICE" ]; then echo "Usage: ./ops.sh restart <service-name>"; exit 1; fi
    echo "♻️  Restarting $SERVICE (zero-downtime)..."
    kubectl rollout restart deployment/$SERVICE -n $NAMESPACE
    kubectl rollout status deployment/$SERVICE -n $NAMESPACE
    ;;

  scale)
    REPLICAS=$3
    if [ -z "$SERVICE" ] || [ -z "$REPLICAS" ]; then
      echo "Usage: ./ops.sh scale <service-name> <replicas>"
      exit 1
    fi
    echo "📈 Scaling $SERVICE to $REPLICAS replicas..."
    kubectl scale deployment/$SERVICE -n $NAMESPACE --replicas=$REPLICAS
    ;;

  health)
    echo "=== Health Check: All Services ==="
    for svc in catalog-service cart-service payment-service api-gateway; do
      POD=$(kubectl get pod -n $NAMESPACE -l app=$svc -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
      if [ -z "$POD" ]; then
        echo "❌ $svc: no pod found"
      else
        STATUS=$(kubectl get pod $POD -n $NAMESPACE -o jsonpath="{.status.phase}")
        READY=$(kubectl get pod $POD -n $NAMESPACE -o jsonpath="{.status.containerStatuses[0].ready}")
        echo "$([ "$READY" = "true" ] && echo ✅ || echo ❌) $svc: $STATUS | ready=$READY | pod=$POD"
      fi
    done
    ;;

  argocd-sync)
    echo "🔁 Forcing ArgoCD sync..."
    argocd app sync ecommerce-catalog --force
    ;;

  *)
    echo "Usage: ./ops.sh <command> [service]"
    echo ""
    echo "Commands:"
    echo "  status              — show all pods, HPA, services"
    echo "  logs <service>      — tail live logs"
    echo "  rollback <service>  — rollback last deployment"
    echo "  restart <service>   — zero-downtime pod restart"
    echo "  scale <svc> <n>     — manually scale to n replicas"
    echo "  health              — health check all services"
    echo "  argocd-sync         — force ArgoCD sync from git"
    ;;
esac
