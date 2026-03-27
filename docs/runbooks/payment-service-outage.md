# docs/runbooks/payment-service-outage.md
# Runbook: Payment Service Outage
# Severity: P0 — Critical (revenue impact)
# Owner: On-call DevOps Engineer

---

## Detection
Alert fires when:
- `PaymentSLOFastBurn` — error rate > 1.4% for 2 minutes
- `PodCrashLooping` — payment pod restarting repeatedly
- `ServiceDown` — payment deployment has 0 ready replicas

---

## Impact
- Users cannot complete checkout
- Revenue loss: approximately ₹X per minute (fill in your estimate)
- Flash sale orders queuing up

---

## Step 1 — Assess (2 minutes)

```bash
# Check pod status
kubectl get pods -n ecommerce -l app=payment-service

# Check events (what happened?)
kubectl describe pods -n ecommerce -l app=payment-service | tail -50

# Check logs (last 100 lines)
kubectl logs -n ecommerce -l app=payment-service --tail=100

# Check HPA
kubectl get hpa payment-hpa -n ecommerce
```

In Grafana: check **Payment SLO** panel and **Error Rate %** panel.

---

## Step 2 — Common Causes & Fixes

### A. Pod OOMKilled (Out of Memory)
```bash
# Symptom: kubectl describe pod shows OOMKilled
# Fix: temporary scale up memory limit
kubectl patch deployment payment-service -n ecommerce \
  --patch '{"spec":{"template":{"spec":{"containers":[{"name":"payment","resources":{"limits":{"memory":"2Gi"}}}]}}}}'
```

### B. Database connection pool exhausted
```bash
# Symptom: logs show "too many connections" or "connection refused"
# Check Cloud SQL connections in Grafana "Cloud SQL Connections" panel
# Fix: restart payment pods to reset connection pool
kubectl rollout restart deployment/payment-service -n ecommerce
kubectl rollout status deployment/payment-service -n ecommerce
```

### C. Bad deployment (new code is broken)
```bash
# Symptom: issue started right after a deployment
# Check deployment history
kubectl rollout history deployment/payment-service -n ecommerce

# Rollback immediately
kubectl rollout undo deployment/payment-service -n ecommerce
kubectl rollout status deployment/payment-service -n ecommerce
```

### D. HPA maxed out (traffic spike)
```bash
# Symptom: current replicas == max replicas, CPU > 80%
# Temporary manual scale above HPA max
kubectl scale deployment/payment-service -n ecommerce --replicas=15
# Then investigate root cause (sudden traffic spike?)
```

### E. CrashLoopBackOff
```bash
# Get crash logs from previous container
kubectl logs -n ecommerce -l app=payment-service --previous

# If config issue — check configmap and secret are correct
kubectl get configmap payment-config -n ecommerce -o yaml
kubectl get secret payment-secret -n ecommerce -o yaml | base64 -d
```

---

## Step 3 — Escalation

If not resolved in 15 minutes:
1. Page the Engineering Lead
2. Consider enabling maintenance mode on checkout page
3. Open a war room in Slack: `#incident-<date>`

---

## Step 4 — Resolution

Once service is restored:
```bash
# Verify all pods healthy
kubectl get pods -n ecommerce -l app=payment-service

# Verify error rate back to normal in Grafana
# Verify SLO panel shows > 99.9%

# Add a note to the incident channel
# Schedule a post-mortem within 48 hours
```

---

## Post-Mortem Template

- **Incident Date:**
- **Duration:**
- **Impact:**
- **Root Cause:**
- **Timeline:**
- **What went well:**
- **What went wrong:**
- **Action items (with owner + deadline):**
