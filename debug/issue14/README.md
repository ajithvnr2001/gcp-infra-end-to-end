# 💥 Debug Scenario 14: Terraform State Lock Acquisition Failure (IaC Lockout)

This scenario simulates an Infrastructure-as-Code (IaC) state lockout. It occurs when a Terraform deployment pipeline crashes midway or is terminated abruptly, leaving a stale metadata lock on your remote GCS state bucket, blocking any future infrastructure plans.

---

## 🔍 The Symptom (What you observe in Terraform)

1. You trigger a Terraform run (`terraform plan` or `terraform apply`).
2. The execution halts immediately with a fatal locking error:
   ```text
   Acquiring state lock. This may take a few moments...
   ╷
   │ Error: Error acquiring the state lock
   │ 
   │ Error message: writing "gs://tf-state-ecommerce-prod-practice-test1-494717/default.tflock" failed: 412 Precondition Failed
   │ Lock Info:
   │   ID:        1683412589024103
   │   Path:      gs://tf-state-ecommerce-prod-practice-test1-494717/default.tflock
   │   Operation: OperationTypeApply
   │   Who:       ajith@LT-LAPTOP
   │   Version:   1.5.0
   │   Created:   2026-06-10 12:45:00 UTC
   │   Info:      
   │ 
   │ Terraform acquires a state lock to protect the state from being written
   │ by multiple users at the same time. Please resolve the issue and try
   │ again.
   ╵
   ```

---

## 🛠️ Step-by-Step Diagnostic Workflow (How to Debug and Fix it)

### Step 1: Identify if another run is active
**Extremely Critical:** Before attempting to clear any state lock, you must verify if a team member is actively running a deployment. If you force-unlock a state file during an active deployment, you will corrupt the state, resulting in lost infrastructure records.

Check your GitHub Actions history or ask the team if there is an active build on the `practice-test1-494717` project.

### Step 2: Extract the Lock ID
From the error output above, extract the unique **Lock ID**:
* **Lock ID:** `1683412589024103`

### Step 3: Execute Force Unlock
Run the safe unlock command from the environment folder:
```bash
terraform force-unlock 1683412589024103
```
**Output:**
```text
Do you really want to force-unlock?
  Terraform will remove the lock on the remote state.
  Only 'yes' will be accepted to confirm.

  Enter a value: yes

State lock successfully released.
```
This deletes the GCS `.tflock` metadata object and unlocks the remote state securely.

---

## 🏆 Interview Performance Point (What you learn and explain)

### "What is a Terraform State Lock, and how do you resolve a stuck lock in production?"
> **Your Answer:** "Terraform acquires a **state lock** before executing any plan or apply to prevent concurrent modifications (which would corrupt the state file).
> 
> In GCP, GCS handles state locking natively by placing a `.tflock` object in our backend bucket. If a deployment pipeline crashes (e.g., a CI/CD runner runs out of memory or a developer terminates a local `apply` process with `Ctrl+C`), this lock object is left behind.
> 
> **To resolve this:**
> 1. I first check our team's slack and CI/CD console to guarantee **no active deploy runs are executing** (force-unlocking an active run will permanently corrupt the state).
> 2. Once verified as stale, I extract the **Lock ID** from the error message.
> 3. I run the **`terraform force-unlock <lock-id>`** command. This tells GCS to delete the stale lock metadata safely, restoring the team's ability to plan and deploy our infrastructure."
