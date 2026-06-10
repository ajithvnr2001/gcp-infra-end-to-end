# 💥 Debug Scenario 13: DNS Name Resolution Failure (CoreDNS / NetworkPolicy Block)

This scenario simulates a cluster DNS resolution outage. It occurs when a network policy denies outbound traffic on port 53 (DNS) to the CoreDNS service in GKE, causing pods to fail when trying to connect to each other via internal Kubernetes DNS names.

---

## 🔍 The Symptom (What you observe in GKE)

1. All pods are in `Running` and healthy status.
2. However, checking logs of the services shows they are crashing with **`Name or service not known`** or socket host resolution errors:
   ```bash
   kubectl logs -l app=cart-service -n ecommerce
   ```
   **Output:**
   ```text
   2026-06-10 12:45:00 ERROR cart-service urllib3.exceptions.MaxRetryError: HTTPConnectionPool(host='catalog-service', port=8000): Max retries exceeded with url: /products (Caused by NameResolutionError("<urllib3.connection.HTTPConnection object at 0x7f8bc0>: Failed to resolve 'catalog-service' ([Errno -2] Name or service not known)"))
   ```

---

## 🛠️ Step-by-Step Diagnostic Workflow (How to Debug it)

### Step 1: Run a Namespace Connection Test
Test if the pod can resolve names using a lightweight debug container:
```bash
kubectl run dns-test --rm -it --image=busybox -n ecommerce -- nslookup catalog-service
```
**Output:**
```text
;; connection timed out; no servers could be reached
```
This confirms that DNS resolution is completely down within the `ecommerce` namespace.

### Step 2: Test DNS Resolution in another namespace
Run the same test inside GKE's default or kube-system namespace:
```bash
kubectl run dns-test --rm -it --image=busybox -n default -- nslookup kubernetes.default
```
If this succeeds, CoreDNS is healthy and running. The blocker is a **Namespace-level egress restriction** inside the `ecommerce` namespace.

### Step 3: Check NetworkPolicies
Describe the NetworkPolicies applied in your namespace:
```bash
kubectl get netpol -n ecommerce
```
Since we have `default-deny-all` egress active, unless there is an explicit egress NetworkPolicy permitting outbound traffic on Port 53 (UDP and TCP) to GKE's CoreDNS IPs, any DNS requests will be dropped by the network plugin. 

Adding an explicit `allow-dns` NetworkPolicy for Port 53 egress immediately resolves the socket name resolution failures.

---

## 🏆 Interview Performance Point (What you learn and explain)

### "How do you debug DNS resolution errors inside a Kubernetes cluster?"
> **Your Answer:** "When pods crash with `Name or service not known` or `NameResolutionError`, it means DNS requests on Port 53 are failing.
> 
> To debug:
> 1. I run a temporary `nslookup` pod in the application namespace to see if the DNS server can be reached.
> 2. If it fails, I run the same `nslookup` test in the `default` namespace. If it succeeds there, it tells me the CoreDNS service in `kube-system` is healthy, and the problem is a namespace-level blocker.
> 3. I inspect our applied `NetworkPolicies`. If we enforce a `default-deny-all` egress policy, GKE blocks all outgoing traffic by default.
> 4. We must deploy an explicit **DNS Egress Policy** permitting UDP/TCP traffic on **Port 53** to allow workloads to communicate with GKE's CoreDNS. Applying the policy restores internal DNS name resolution immediately."
