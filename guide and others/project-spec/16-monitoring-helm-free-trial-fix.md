# Monitoring Helm Free-Trial Fix

This note explains the stuck state from `log.txt`.

The failing phase was:

```text
Installing Prometheus & Grafana...
UPGRADE FAILED: resource not ready, name: kube-prometheus-stack-grafana, kind: PersistentVolumeClaim, status: InProgress
resource not ready, name: kube-prometheus-stack-grafana, kind: Deployment, status: Failed
context deadline exceeded
```

## Root Cause

The problem is not the ecommerce application.

The script was installing `kube-prometheus-stack` with persistent storage:

- Prometheus PVC: `20Gi`
- Grafana PVC: `5Gi`
- Alertmanager PVC: `5Gi`

On a free-trial or small GKE cluster, persistent disk provisioning and available node resources can be slow or insufficient. Helm used `--wait`, so it waited for Grafana PVC and Deployment readiness until timeout.

## What Was Fixed

Updated:

```text
monitoring/prometheus/values.yaml
scripts/build.sh
scripts/nuke-and-rebuild.sh
scripts/setup-observability.sh
```

Free-trial monitoring changes:

- Disabled Grafana persistence.
- Disabled Prometheus persistent storage.
- Disabled Alertmanager for the free-trial profile.
- Reduced Grafana CPU and memory.
- Reduced Prometheus CPU and memory.
- Reduced Prometheus retention from `15d` to `2d`.
- Reduced retention size from `10GB` to `1GB`.
- Disabled default kube-prometheus rules to reduce load.
- Disabled Prometheus Operator admission webhooks to reduce webhook install friction.
- Reduced Helm monitoring wait timeout from `20m` to `10m`.

## Why This Works

For interview and learning, Prometheus and Grafana need to run. Durable monitoring storage is not required on a free-trial cluster.

Ephemeral monitoring means:

- Dashboards and metrics may reset if Pods restart.
- No persistent disk is required.
- Helm is less likely to get stuck waiting for PVCs.
- The setup fits better beside ArgoCD, ingress-nginx, cert-manager, external-secrets, and ecommerce workloads.

## Clean Up The Currently Stuck Release

Because Helm already created a stuck PVC, run this once before retrying:

```bash
kubectl get pvc -n monitoring
kubectl delete pvc -n monitoring -l app.kubernetes.io/name=grafana --ignore-not-found=true
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --values monitoring/prometheus/values.yaml \
  --wait --timeout 10m
```

If the Helm release is badly stuck, use:

```bash
helm uninstall kube-prometheus-stack -n monitoring
kubectl delete pvc -n monitoring --all
```

Then rerun:

```bash
bash scripts/build.sh
```

or:

```bash
SKIP_NUKE=true bash scripts/nuke-and-rebuild.sh
```

## Production Version

For production, do not use this lightweight profile.

Production should use:

- Persistent Prometheus storage.
- Persistent Grafana storage.
- Alertmanager enabled.
- Real notification receivers.
- Longer retention.
- Proper storage class.
- More node capacity.
- Cluster autoscaler.

## Interview Explanation

Use this answer:

```text
The script was stuck during kube-prometheus-stack installation because Grafana's PersistentVolumeClaim stayed pending and Helm was waiting for readiness. On a free-trial GKE cluster, persistent disks and monitoring components can consume too much capacity. I fixed it by switching monitoring to a free-trial profile: ephemeral Grafana and Prometheus storage, lower resource requests, shorter retention, and Alertmanager disabled. In production I would keep persistence and scale the cluster properly.
```

## AWS Mapping

In AWS EKS, the same problem can happen when:

- Grafana PVC waits for EBS provisioning.
- EBS CSI driver is missing.
- StorageClass is wrong.
- Nodes do not have enough CPU/memory.
- Helm waits until timeout.

AWS fix:

```text
For learning clusters, use ephemeral monitoring storage. For production, install the EBS CSI driver, use a valid StorageClass, size the node group correctly, and keep persistent monitoring storage.
```
