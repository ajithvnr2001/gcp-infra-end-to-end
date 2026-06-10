# 💥 Debug Scenario 12: PVC Stuck in `Pending` (StorageClass Provisioning Failure)

This scenario simulates a storage provisioning failure. It occurs when a deployment requests persistent disk storage using a `PersistentVolumeClaim` (PVC) but specifies a `storageClassName` that does not exist in GKE, leaving the volume claims unbindable.

---

## 🔍 The Symptom (What you observe in GKE)

1. You apply a persistent storage claim (like the `pvc-debug.yaml` in this folder).
2. The `PersistentVolumeClaim` remains permanently stuck in **`Pending`** state:
   ```bash
   kubectl get pvc -n ecommerce
   ```
   **Output:**
   ```text
   NAME             STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS               AGE
   dynamic-db-pvc   Pending                                      ssd-storage-typo-wrong     5m
   ```

---

## 🛠️ Step-by-Step Diagnostic Workflow (How to Debug it)

### Step 1: Describe the PVC
Query GKE's storage controller to see why the dynamic volume cannot be provisioned:
```bash
kubectl describe pvc dynamic-db-pvc -n ecommerce
```
Look at the **Events** section at the bottom of the output:
```text
Events:
  Type     Reason              Age                From                         Message
  ----     ------              ----               ----                         -------
  Warning  ProvisioningFailed  10s (x10 over 3m)  persistentvolume-controller  storageclass.storage.k8s.io "ssd-storage-typo-wrong" not found
```
This is the scheduler's explicit error: **storageclass... "ssd-storage-typo-wrong" not found**, indicating GKE cannot find a storage provisioner bound to that class name.

### Step 2: Query the Available StorageClasses
Check what StorageClasses actually exist inside your GKE cluster:
```bash
kubectl get storageclass
```
**Output:**
```text
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION
standard (default)   kubernetes.io/gce-pd    Delete          Immediate              true
standard-rwo         pd.csi.storage.gke.io   Delete          WaitForFirstConsumer   true
premium-rwo          pd.csi.storage.gke.io   Delete          WaitForFirstConsumer   true
```
The GKE cluster supports default storage classes like `standard-rwo` and `premium-rwo` (using GCE CSI persistent disk provisioners), but has no class named `ssd-storage-typo-wrong`.

---

## 🏆 Interview Performance Point (What you learn and explain)

### "How do you troubleshoot a PersistentVolumeClaim stuck in Pending state?"
> **Your Answer:** "A `PersistentVolumeClaim` stuck in **Pending** means GKE’s persistent-volume controller cannot dynamically provision a matching physical persistent disk.
> 
> To troubleshoot:
> 1. I run `kubectl describe pvc` to check the event logs. If the message says `storageclass... not found`, it is a configuration mismatch.
> 2. I check the available cluster StorageClasses using `kubectl get storageclass`.
> 3. In this scenario, we discover that the deployment manifest requested a non-existent storage class (e.g. `ssd-storage-typo-wrong`).
> 4. To resolve this, I update the PVC manifest in Git to use a valid GKE StorageClass like `standard-rwo` (for standard HDDs) or `premium-rwo` (for fast SSDs), and commit. GKE's CSI controller will dynamically spin up a GCP Persistent Disk, format it, bind it to a `PersistentVolume`, and mount it to our pod securely."
