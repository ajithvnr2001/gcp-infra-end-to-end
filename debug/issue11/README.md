# 💥 Debug Scenario 11: Readiness Probe Fail / Cascading Failure (Timeout/Typo)

This scenario simulates a production-disruptive probe failure. It occurs when a service's `readinessProbe` is misconfigured to hit a non-existent or latency-blocked endpoint, causing GKE to remove the pods from the Service Load Balancer routing pool, leaving the application completely unreachable.

---

## 🔍 The Symptom (What you observe in GKE)

1. Pods are physically `Running` in GKE.
2. However, the **`READY`** column in your pod listing displays **`0/1`**:
   ```bash
   kubectl get pods -n ecommerce
   ```
   **Output:**
   ```text
   NAME                                READY   STATUS    RESTARTS   AGE
   payment-service-59f9f855d-kg5w8     0/1     Running   0          5m
   ```
3. Checking external traffic, any checkout requests (which hit `payment-service`) fail with HTTP 502/504 errors on the gateway because the GKE Load Balancer has no endpoints to route to.

---

## 🛠️ Step-by-Step Diagnostic Workflow (How to Debug it)

### Step 1: Describe the Pod
Query GKE to inspect why the pod is being flagged as "not ready":
```bash
kubectl describe pod payment-service-59f9f855d-kg5w8 -n ecommerce
```
Look at the **Events** section at the bottom of the output:
```text
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Warning  Unhealthy  10s (x25 over 2m)  kubelet            Readiness probe failed: HTTP probe failed with statuscode: 404
```
This is the smoking gun: **Readiness probe failed: HTTP probe failed with statuscode: 404**, indicating that the container is alive, but the kubelet’s query on `/ready-typo-wrong` is returning a 404 Not Found from FastAPI.

### Step 2: Query the Endpoints List
Verify if any endpoints exist for the payment service:
```bash
kubectl get endpoints payment-service -n ecommerce
```
**Output:**
```text
NAME              ENDPOINTS   AGE
payment-service   <none>      15m
```
Because the readiness probe failed, the GKE controller removed the pod's IP from the service endpoints. Traffic can no longer reach it.

---

## 🏆 Interview Performance Point (What you learn and explain)

### "What happens when a Readiness Probe fails, and how do you fix it?"
> **Your Answer:** "When a **Readiness Probe fails**, the container remains running in GKE, but the Kubernetes controller **removes the pod's IP from the Service Endpoints list**. This completely stops GKE from routing any traffic to the pod.
> 
> If all replicas fail their readiness checks, the Service displays `ENDPOINTS <none>`, causing external traffic to hit the load balancer and fail with HTTP 502/504 Bad Gateway timeouts.
> 
> **To debug:**
> 1. I run `kubectl describe pod` and look at the events to see the HTTP response code (e.g., `statuscode: 404` or `connection refused` or `timeout`).
> 2. I review the deployment manifest's `readinessProbe` block in Git. In this scenario, we'd discover a typo on the path (e.g. `/ready-typo-wrong` instead of `/ready`) or a timeout set too small (e.g., `timeoutSeconds: 1` when the DB takes 2 seconds to respond).
> 3. I correct the path or increase the timeout limits in Git, commit, and let ArgoCD sync. The readiness probe will pass, GKE binds the pod IP back to the endpoints list, and traffic is restored."
