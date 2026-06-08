# Free-Trial GKE Capacity Fix

This note explains the catalog-service scheduling issue seen in GCP:

```text
Cannot schedule pods: Insufficient cpu.
Cannot schedule pods: node(s) didn't match pod topology spread constraints.
Cannot schedule pods: No preemption victims found for incoming pod.
```

## Root Cause

The problem is not catalog application code. It is Kubernetes scheduling capacity.

The previous catalog configuration was closer to a production simulation:

- Deployment requested `2` baseline replicas.
- HPA had `minReplicas: 2` and `maxReplicas: 20`.
- Each Pod requested CPU and memory.
- Topology spread used `whenUnsatisfiable: DoNotSchedule`.

On a small GKE free-trial cluster, this can create pending Pods because the scheduler cannot find enough CPU and cannot satisfy strict spread rules across nodes.

## What Was Changed

Updated:

```text
k8s/deployments/catalog-deployment.yaml
k8s/deployments/other-deployments.yaml
k8s/deployments/frontend-deployment.yaml
k8s/hpa/hpa.yaml
```

Free-trial-friendly changes:

- Catalog baseline replicas reduced from `2` to `1`.
- Catalog CPU request reduced from `100m` to `50m`.
- Catalog memory request reduced from `128Mi` to `96Mi`.
- Catalog CPU limit reduced from `500m` to `250m`.
- Catalog memory limit reduced from `512Mi` to `256Mi`.
- Topology spread changed from `DoNotSchedule` to `ScheduleAnyway`.
- Catalog HPA changed from `minReplicas: 2 maxReplicas: 20` to `minReplicas: 1 maxReplicas: 3`.
- HPA scale-up policy changed from `4` Pods per minute to `1` Pod per minute.
- Cart, payment, API gateway, and frontend baseline replicas were also reduced to `1`.
- Cart, payment, API gateway, and frontend HPA minimums were reduced to `1`.
- Cart, payment, API gateway, and frontend HPA maximums were reduced to free-trial-safe values.
- Cart, payment, and API gateway resource requests/limits were reduced so they can fit alongside ArgoCD, monitoring, ingress, and system Pods.

## Why This Fix Works

`Insufficient cpu` means Kubernetes cannot reserve the requested CPU on available nodes.

Reducing CPU requests makes each Pod easier to place.

`DoNotSchedule` in topology spread is strict. If Kubernetes cannot spread Pods according to the rule, it refuses to schedule them.

Changing it to `ScheduleAnyway` keeps the preference for spreading but allows Pods to run even when the free-trial cluster has limited nodes.

## Production Versus Free Trial

For production, the previous idea was valid:

- More replicas
- Higher HPA max
- Stricter topology spread
- More CPU/memory headroom

For free trial, the priority is different:

- Keep the app schedulable
- Avoid unnecessary Pods
- Avoid high resource requests
- Keep enough capacity for monitoring, ingress, ArgoCD, and system Pods

## Why Other Services Were Tuned Too

Even though the visible GCP alert mentioned `catalog-service`, the cluster has shared capacity. If cart, payment, API gateway, or frontend keep `minReplicas: 2` with higher limits, the same scheduling issue can move to another service after catalog is fixed.

For a free-trial cluster, the safer baseline is:

```text
1 replica per service
small CPU/memory requests
small HPA max replicas
soft topology spreading
```

For a production cluster, increase replicas and HPA limits only after node capacity and cluster autoscaling are ready.

## Apply The Fix

If using ArgoCD:

```text
Commit and push the manifest changes, then let ArgoCD sync.
```

Or manually apply:

```powershell
kubectl apply -f k8s/deployments/catalog-deployment.yaml
kubectl apply -f k8s/hpa/hpa.yaml
```

Then check:

```powershell
kubectl get pods -n ecommerce
kubectl describe pod <catalog-pod-name> -n ecommerce
kubectl get hpa -n ecommerce
kubectl get events -n ecommerce --sort-by=.lastTimestamp
```

Expected result:

```text
catalog-service should move from Pending/Unschedulable to Running.
```

## Interview Explanation

Use this answer:

```text
The catalog-service issue was not an application bug. Kubernetes could not schedule Pods because the free-trial GKE cluster had limited CPU and the manifest had production-style settings: multiple replicas, high HPA max, and strict topology spreading. I fixed it by reducing requests, lowering baseline and HPA replicas, and changing topology spread from hard DoNotSchedule to soft ScheduleAnyway. In production I would scale nodes or use cluster autoscaler, but for a free-trial cluster the correct fix is to right-size workloads.
```

## AWS Mapping

In AWS EKS, the same issue would appear as:

```text
0/n nodes are available: insufficient cpu
node(s) didn't match pod topology spread constraints
No preemption victims found
```

AWS-side fixes:

- Reduce Pod requests.
- Lower HPA min/max replicas for test environments.
- Relax topology spread constraints.
- Add more EKS worker nodes.
- Use Cluster Autoscaler or Karpenter.
- Right-size node instance types.

Interview AWS answer:

```text
In EKS, I would first check Pod requests, HPA settings, node allocatable CPU, and topology constraints. For a test cluster I would reduce requests and replicas. For production I would scale the node group or use Karpenter/Cluster Autoscaler so the cluster can add capacity automatically.
```
