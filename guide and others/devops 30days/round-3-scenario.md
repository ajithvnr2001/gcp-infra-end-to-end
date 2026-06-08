# Round 3 - Scenario Questions

Use VERDICT for every answer.

## Scenarios

### 1. Deployment failed after merge.

Check CI logs, image build, registry push, manifest update, ArgoCD sync, pod events, logs, rollback.

### 2. Cloud Build cannot push image.

Check registry path, repository exists, IAM writer permission, auth, project/region, quota. Mention your Artifact Registry fix.

### 3. Pod is ImagePullBackOff.

Check image name/tag, registry permission, repo exists, pull secret/IAM, node network.

### 4. ALB returns 502.

Check target group health, app port, health check path, SG, backend logs.

### 5. RDS connection timeout.

Check endpoint, SG, subnet, route, NACL, DB status, port, credentials.

### 6. Terraform plan wants to destroy database.

Stop. Check variable changes, state, module/provider version, lifecycle, resource rename. Do not apply blindly.

### 7. High latency after deployment.

Check release version, error rate, latency metrics, CPU/memory, DB, downstream services, traces, rollback.

### 8. Secret leaked.

Rotate/revoke, audit usage, remove exposure, add secret scanning and managed secrets.

### 9. ArgoCD OutOfSync.

Check diff, manifest error, missing CRD, RBAC, repo access, sync policy, cluster health.

### 10. AWS AccessDenied.

Check identity policy, resource policy, trust policy, SCP, permission boundary, KMS policy, CloudTrail.

