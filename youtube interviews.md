# 🚀 Master DevOps Interview Q&A Catalog (GCP & AWS)

This catalog consolidates all 80+ questions from the reference interview videos into a professional, "Senior-level" knowledge base. Every answer includes **Technical Best Practices**, **Platform Parity (GCP vs. AWS)**, and the **VERDICT-7 Framework** for troubleshooting.

---

## 🏗️ Section 1: Professional Introduction & Deployment Experience
*(Reference: Video 1, Video 2)*

### **Q: Why don't you start by telling me about what you have done so far?**
**The Answer**:
"I am a Senior DevOps/Platform Engineer with over 3 years of experience specializing in production-grade infrastructure on **Google Cloud Platform (GCP)** and **AWS**. My core expertise lies in architecting high-availability **Kubernetes (GKE/EKS)** environments for banking and fintech applications, maintaining a **99.95% SLA**. 

I am a strong advocate for **GitOps**, having implemented end-to-end CI/CD pipelines using **GitHub Actions**, **Cloud Build**, and **ArgoCD** to achieve zero-downtime deployments. Success is measured by **MTTR (Mean Time To Recovery)** and **Deployment Frequency**. I achieved a **35% increase in code delivery** by parallelizing CI/CD build stages and implementing container layer caching, reducing build times by 50%."

**Platform Parity**:
- **GCP Focus**: GKE Standard, Cloud SQL (Private Service Access), and Artifact Registry.
- **AWS Focus**: EKS (IRSA), Amazon RDS, and Amazon ECR.

---

## 🐧 Section 2: Linux & System-Level Troubleshooting
*(Reference: Video 3)*

### **Q: I have disk space related issues on a Linux server. Server is getting slow. How will you troubleshoot?**
**The Answer**:
Disk exhaustion leads to kernel performance degradation and application write failures.
**VERDICT-7 Scan**:
- **V (Version)**: Is the OS using LVM or a standard partition?
- **E (Environment)**: Is this a shared root partition or a dedicated data disk?
- **R (Resources)**: Is it a space issue (`df -h`) or an inode issue (`df -i`)?
- **D (Dependencies)**: Are large logs or Docker overlay tiers consuming space?
- **I (Infra)**: Is the underlying disk (EBS/PD) degraded or full?
- **T (Telemetry)**: Check `dmesg` for I/O errors and read the `df -h` output.
**Technical Fixes**:
1.  **Find the culprit**: `du -sh /* | sort -hr` to identify the largest directory.
2.  **Check Inodes**: If `df -h` shows space but you can't create files, check `df -i`. You likely have too many small files (e.g., millions of session/temp files).
3.  **Log Management**: Check `/var/log` and if `logrotate` is active. Truncate logs if necessary: `> /var/log/huge_file.log`.
4.  **Zombie processes**: If a file is deleted but not freed, use `lsof | grep deleted` and restart the process holding the handle.

### **Q: How will you handle permission errors while running some script in Linux?**
**The Answer**:
Permission errors are typically due to missing **Execution bits** or **Owner/Group** mismatches.
**Technical Steps**:
1.  **Check bits**: `ls -l script.sh`. If it doesn't show `-rwxr-xr-x`, run `chmod +x script.sh`.
2.  **Check ownership**: `ls -n` to verify the UID/GID matches the active user. If not, use `sudo chown <user>:<group> script.sh`.
3.  **ACL Check**: Check for extended permissions using `getfacl`. In highly secure environments, standard POSIX permissions are sometimes overridden by ACLs or **SELinux/AppArmor** profiles.

---

## 🐳 Section 3: Dockerized workloads & Image Management
*(Reference: Video 1, Video 2)*

### **Q: From a definition point of view, can you define a Dockerfile and its role?**
**The Answer**:
A **Dockerfile** is a declarative build manifest that defines the OS environment, application dependencies, and the execution entrypoint for a container.
**Internal Mechanics**:
- **Union File System (UnionFS)**: Each command (`FROM`, `COPY`, `RUN`) creates an immutable read-only **layer**.
- **Copy-on-Write (CoW)**: When a container runs, Docker adds a thin **writable layer** on top of the image layers.
**Platform Parity**:
- **GCP**: Store images in **Artifact Registry**.
- **AWS**: Store images in **Amazon Elastic Container Registry (ECR)**.

### **Q: Can you tell me how you would secure a Docker image? (Highly Sensitive)**
**The Answer**:
I follow the principle of **Defense-in-Depth** and **Least Privilege**:
1.  **Minimal Base Images**: Use **Alpine** (musl libc) or **Distroless** (no shell/tools) to reduce post-exploit tool availability.
2.  **Unprivileged User**: Never run as `root`. Use `USER 1001` in the Dockerfile.
3.  **Multi-stage builds**: Compile the code in a 'builder' stage and copy only the binary to the final runtime stage—this leaves the compiler and source code out of production.
4.  **Binary Authorization**: (GCP) Use Binary Authorization to ensure only signed and scanned images are deployable.
5.  **Scan for CVEs**: Use **Trivy** or **Amazon Inspector** in the CI pipeline to block builds with CRITICAL vulnerabilities.

### **Q: Can we delete the image out of which my container is running? What happen if forced?**
**The Answer**:
Docker normally blocks the deletion of a used image. If you run `docker rmi -f`, the image layers stay in the kernel's memory space and the container **continues to run**. However, the image record is gone, making it impossible to spawn *new* containers from it without re-pulling.

---

## 🛠️ Section 4: Container Troubleshooting (Runtime)

### **Q: How would you troubleshoot a containerized application using Docker? (Scenario)**
**The Answer**:
Troubleshooting follow the **Exit Code** and **Log Analysis** methodology.
**VERDICT-7 Scan**:
- **V (Version)**: Is the image tag correct?
- **R (Resources)**: Is it `OOMKilled` (Exit Code 137)?
- **D (Dependencies)**: Does the app need Secret Manager access?
- **C (Connectivity)**: Does the service listen on `0.0.0.0` or `127.0.0.1`?
- **T (Telemetry)**: Use `docker logs` and `docker inspect`.
**Common Error Messages**:
- **Exit Code 1**: Application-level crash (checked via app logs).
- **Exit Code 137**: Out-of-Memory (Memory limits too low).
- **Exit Code 139**: Segmentation fault (typically a kernel/driver issue).
- **Exec format error**: Platform mismatch (building on Mac/ARM but running on AMD64 Linux).

---

## ☸️ Section 5: Kubernetes (GKE/EKS) Architecture & Components
*(Reference: Video 1, Video 3)*

### **Q: Can you tell me the components of Kubernetes and a high-level architecture?**
**The Answer**:
Kubernetes follows a **Master-Worker** architecture separated into the **Control Plane** (Brain) and **Node Pool** (Muscle).
- **Control Plane**: 
    - **API Server**: Central gateway (REST).
    - **etcd**: Key-value store (state).
    - **Scheduler**: Pod-to-node placement.
    - **Controller Manager**: Desired state enforcement (ReplicaSet/Deployment).
- **Worker Nodes**: 
    - **Kubelet**: Ensures containers are running in pods.
    - **Kube-proxy**: Manages network routing (IPtables/IPVS).
    - **Container Runtime**: (containerd/Docker).
**Platform Parity**:
- **GCP**: **GKE** (Google Kubernetes Engine) manages the Control Plane for you.
- **AWS**: **EKS** (Elastic Kubernetes Service) handles the Control Plane across 3 AZs.

### **Q: What do you understand by Stateless and Stateful applications?**
**The Answer**:
- **Stateless**: Applications that don't store data locally (e.g., NGINX, Python APIs). Any pod can be killed and replaced without data loss. **Scaling**: Horizontal scaling is trivial.
- **Stateful**: Applications that require persistent data (e.g., PostgreSQL, Redis, MongoDB). Each pod has a unique identity and persistent disk. **Scaling**: Requires `StatefulSet` and **Persistent Volume Claims (PVC)**.

### **Q: I have to deploy a monitoring tool (Dynatrace) application pod on each node. How will you deploy this?**
**The Answer**:
We use a **DaemonSet**.
**Internal Working**: A DaemonSet ensures that exactly one copy of a specific pod is running on every node (or a subset of nodes) in the cluster. As nodes are added via autoscaling, the DaemonSet controller automatically schedules the pod onto the new node.
**Senior Insight**: This is the standard pattern for logging collectors (FluentBit), monitoring agents (Dynatrace/Datadog), and network proxies (Kube-proxy).

---

## 🔍 Section 6: Kubernetes Troubleshooting & Log Analysis
*(Reference: Video 2, Video 3)*

### **Q: Where exactly would you check the Kubernetes logs?**
**The Answer**:
I check logs at three levels depending on the failure:
1.  **Container Logs**: `kubectl logs <pod_name> -c <container_name>`.
2.  **Kubelet Logs**: SSH into the node and run `journalctl -u kubelet` (if a pod isn't even starting).
3.  **Events**: `kubectl get events -n <namespace>` or `kubectl describe pod <name>` (to see errors like `FailedScheduling` or `NodeNotReady`).
**Platform Parity**:
- **GCP**: Logs are automatically streamed to **GCP Cloud Logging**.
- **AWS**: Logs are typically sent to **Amazon CloudWatch Logs** via FluentBit.

### **Q: How will you troubleshoot if your pod is crashing again and again? (CrashLoopBackOff)**
**The Answer**:
**VERDICT-7 Scan**:
- **V (Version)**: Did a recent CI/CD push break the entrypoint?
- **R (Resources)**: Is it hitting memory limits?
- **D (Dependencies)**: Is the DB unreachable?
- **C (Connectivity)**: Is the Liveness Probe failing?
- **T (Telemetry)**: Use `kubectl logs --previous` to see why it crashed last time.
**Senior Insight**: Use `kubectl describe pod` to check the **Exit Code**.
- `137`: OOM (Need more memory).
- `1`: App code error (Check logs).
- `Liveness probe failed`: The app is running but unhealthy.

### **Q: What can be the possible causes of ImagePullBackOff error?**
**The Answer**:
The Kubelet cannot retrieve the image from the registry.
**Common Causes**:
1.  **Authentication**: Missing `imagePullSecrets` or the Node IAM Role (Workload Identity/IRSA) doesn't have permission to the ECR/Artifact Registry.
2.  **Wrong Path**: Typo in the image name or tag (e.g., `latest` instead of a specific SHA).
3.  **Network**: The node has no internet access (NAT Gateway/IGW issue) or cannot reach the private registry endpoint.
4.  **Registry Quota**: Rate limiting (e.g., Docker Hub free tier limits).

---

## 🚀 Section 7: High Availability & Scalability
*(Reference: Video 3)*

### **Q: How will you make your application highly available and scalable?**
**The Answer**:
I architect for **Redundancy** at both the App and Infrastructure levels:
1.  **Horizontal Pod Autoscaler (HPA)**: Scales pods based on CPU/RAM metrics.
2.  **Multi-AZ Deployment**: Ensure pods are spread across multiple **Availability Zones (AZs)** using **PodTopologySpreadConstraints**.
3.  **Load Balancer**: Use a Global Load Balancer to distribute traffic.
4.  **State Management**: Use managed databases (Cloud SQL/RDS) with **Multi-AZ failover**.

### **Q: How are you utilizing Karpenter vs. Cluster Autoscaler?**
**The Answer**:
- **Cluster Autoscaler (Standard)**: Watches for unschedulable pods and adds pre-defined node pools. **Bottleneck**: Slower "spin-up" time.
- **Karpenter (AWS)**: A "just-in-time" node provisioner. It calculates the exact hardware needed for a pod and launches the most cost-effective instance immediately without relying on node groups.
**Platform Parity**:
- **GCP**: GKE uses a highly optimized **Cluster Autoscaler** with **Node Provisining** (Autopilot-style) which behaves similar to Karpenter by providing right-sized nodes.

## 🛠️ Section 8: Infrastructure as Code (Terraform vs. CloudFormation)
*(Reference: Video 1, Video 3)*

### **Q: What do you understand by 'state' in Terraform?**
**The Answer**:
**Terraform State** is a metadata file (`.tfstate`) that serves as the "Source of Truth" for your infrastructure. It maps your configuration code to real-world resource IDs in the cloud.
**Internal working**: When you run `terraform plan`, Terraform compares your current code, the state file, and the live resources to calculate the "delta" (what needs to be created/changed/deleted).
**Senior Insight**: In production, never store state locally. Use a **Remote Backend** (S3/GCS) with **State Locking** (DynamoDB/GCS native) to prevent multiple team members from corrupting the state simultaneously.

### **Q: What are the Pros and Cons of using Terraform and CloudFormation?**
**The Answer**:
- **Terraform (HashiCorp)**:
    - **Pros**: Cloud-agnostic (AWS, GCP, Azure), richer ecosystem (Modules), more flexible state manipulation.
    - **Cons**: You must manage the backend/state manually (S3 buckets/DynamoDB).
- **CloudFormation (AWS Native)**:
    - **Pros**: Fully managed (AWS handles state), deep integration with AWS-only features, faster stack deletion.
    - **Cons**: Locked to AWS only, YAML/JSON is more verbose than Terraform’s HCL.

### **Q: I have created a VPC manually. Now you are writing Terraform to create an EC2 inside it. How will you do this without console access?**
**The Answer**:
I use **Terraform Data Sources**.
**Technical Step**:
Instead of hardcoding a VPC ID, I query the VPC by its name or tags:
```hcl
data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["my-manual-vpc"]
  }
}
# Then use it in the resource:
resource "aws_instance" "my_app" {
  subnet_id = data.aws_vpc.existing_vpc.id
  # ...
}
```
**Senior Insight**: For an even cleaner approach, I would use `terraform import` to bring the manually created VPC under Terraform management to avoid "ClickOps" drift.

---

## ⚠️ Section 9: State Management & Disaster Recovery
*(Reference: Video 3)*

### **Q: Your Terraform State file has been corrupted. How will you recover it and make sure it doesn't occur again?**
**The Answer**:
Corrupted state is a "Severity 1" infra incident.
**Recovery Steps**:
1.  **Versioned Backend**: If using S3/GCS with versioning, I locate the last known-good version of the `.tfstate` and restore it.
2.  **State Pull/Push**: I use `terraform state pull > recovered.tfstate`, fix any syntax corruption manually, and `terraform state push`.
**Prevention**:
- Enable **S3/GCS Object Versioning** on the state bucket.
- Strict **IAM policies** preventing anyone but the CI/CD service from deleting state files.

### **Q: Someone manually changed a rule in a security group/firewall. If you run `terraform apply` now, how will it behave?**
**The Answer**:
This is called **Infrastructure Drift**.
**Outcome**: Terraform will detect that the "Live State" does not match the "Desired State" (the code). During the `plan` phase, it will show a modification to revert the resource back to the code's definition. Running `apply` will overwrite the manual change.
**Senior Insight**: In a mature GitOps environment, we use tools like **Driftctl** or **Terraform Cloud** to alert us as soon as a manual change happens, rather than waiting for the next deployment.

### **Q: How will you handle that an RDS module creates RDS only after a VPC is created?**
**The Answer**:
I use **Implicit and Explicit Dependencies**.
1.  **Implicit (Recommended)**: Pass the VPC ID as an input variable to the RDS module. Terraform automatically recognizes that the RDS resource depends on the VPC output.
2.  **Explicit**: Use the `depends_on = [module.vpc]` block within the RDS module call.
**Senior Insight**: Always prefer implicit dependencies via variable passing; it keeps the graph logic clean and avoids circular dependencies.

## 🌐 Section 10: Cloud Networking & Connectivity
*(Reference: Video 1, Video 3)*

### **Q: From a technical perspective, what is a VPC?**
**The Answer**:
A **Virtual Private Cloud (VPC)** is a logically isolated software-defined network (SDN) within a public cloud provider. It provides a private IP space where you can define subnets, route tables, and network gateways.
**Platform Parity**:
- **GCP**: VPCs are **Global**; subnets are regional.
- **AWS**: VPCs are **Regional**; subnets reside in specific Availability Zones (AZs).

### **Q: How do you ensure that a subnet is Public or Private?**
**The Answer**:
The distinction lies in the **Routing**.
- **Public**: Has a route to an **Internet Gateway (IGW)** (e.g., `0.0.0.0/0 -> igw-id`).
- **Private**: Has no route to an IGW. For outbound internet access, it uses a **NAT Gateway** located in a public subnet.
**Platform Parity**:
- **AWS**: Explicitly check the **Route Table** associated with the subnet.
- **GCP**: Check for a **Cloud NAT** gateway configured for the subnet's CIDR range.

### **Q: If you have 3 AWS accounts and each has a VPC, how do you establish interconnectivity?**
**The Answer**:
1.  **VPC Peering**: Simple 1-to-1 connection. No transitive routing. Low latency/cost. Use for basic setups.
2.  **Transit Gateway (AWS)**: A central hub that acts as a cloud-native router. It supports transitive routing (A can talk to C through B). Use for complex, enterprise-scale organizations.
**Platform Parity**:
- **GCP**: **VPC Network Peering** (No transitive routing) or **Shared VPC** (Recommended—3 project subnets all reside in one host VPC).

### **Q: When you need to establish connectivity between a VPC and your on-premise, what sort of gateways would you use?**
**The Answer**:
1.  **Site-to-Site VPN (IPsec)**: Encrypted tunnel over the public internet. Fast to set up, lower bandwidth (up to 1.25Gbps per tunnel).
2.  **Direct Connect (AWS) / Interconnect (GCP)**: A dedicated physical fiber connection between the cloud provider and your data center. High bandwidth (10/100Gbps), low latency, and bypasses the public internet.

---

## 🛡️ Section 11: Security Hardening & Identity Management
*(Reference: Video 1, Video 2)*

### **Q: Explain the concept of Zero Trust security.**
**The Answer**:
**Zero Trust** is a security model where "no entity is trusted by default," whether inside or outside the network boundary.
**Three Pillars**:
1.  **Explicit Verification**: Authenticate every request (Identity-Aware Proxy).
2.  **Least Privilege**: Give access only to what is needed.
3.  **Assume Breach**: Segment the network (Microsegmentation) so that an exploit in one pod doesn't lead to a lateral breakout.
**Platform Implementation**: We use **Service Mesh (Istio)** for mTLS between pods and **Workload Identity/IRSA** to remove static cloud keys.

### **Q: What is the difference between KMS and CloudHSM?**
**The Answer**:
- **KMS (Key Management Service)**: Multi-tenant, software-based (FIPS 140-2 Level 2). Managed by the provider. Scales automatically. Use for 99% of workloads.
- **CloudHSM / CKMS (Dedicated)**: Single-tenant hardware (FIPS 140-2 Level 3). You manage the HSM hardware directly. Required for high-security compliance (e.g., specific banking regulations).

### **Q: CloudFront vs. Google Cloud CDN?**
**The Answer**:
- **AWS CloudFront**: A global CDN that caches at **Edge Locations**. It integrated with WAF for DDoS and requires a certificate from **ACM**.
- **GCP Cloud CDN**: Built into the **Global HTTP(S) Load Balancer**. It uses **Anycast IP** so a single IP represents your application globally.

### **Q: Identity and Access Management: Difference between a Group and a Role?**
**The Answer**:
- **IAM Group**: A collection of human **Users**. Use groups to manage permissions for teams (e.g., 'Dev-Team' gets access to the 'Dev-Project').
- **IAM Role**: A temporary set of permissions that can be **assumed** by a Service (EC2/Pod) or a manual user. Roles provide **Temporary Credentials** (STS), making them more secure than static API keys.
**Senior Insight**: Never give a manual console user a long-lived API key. Have them assume a role that grants them temporary 1-hour access.

## 📈 Section 12: SRE Monitoring & Observability
*(Reference: Video 1, Video 2)*

### **Q: Purpose of Prometheus and Grafana?**
**The Answer**:
They form the backbone of a Cloud-Native observability stack.
- **Prometheus**: A time-series database that uses a **Pull Model** to scrape metrics from targets. It uses **PromQL** for querying.
- **Grafana**: A visualization dashboard that queries Prometheus (and other sources) to display metrics for the **R.E.D. Method** (Rate, Errors, Duration).
**Platform Parity**:
- **AWS**: **Amazon Managed Service for Prometheus** & **Grafana**.
- **GCP**: **GCP Cloud Monitoring** (has a Prometheus-compatible sidecar for GKE).

### **Q: Difference between Metrics and Traces?**
**The Answer**:
- **Metrics**: Aggregated numbers (Counters, Gauges, Histograms). Use for **Detection** (e.g., "Is the CPU high?").
- **Traces**: Captures the end-to-end journey of a single request across multiple microservices. Use for **Debugging** (e.g., "Which service is slow?").
**Platform Parity**:
- **AWS**: **AWS CloudWatch** (Metrics) & **AWS X-Ray** (Traces).
- **GCP**: **GCP Cloud Monitoring** (Metrics) & **GCP Cloud Trace** (Traces).

### **Q: Can you tell me the definitions for SLI, SLO, and SLA?**
**The Answer**:
- **SLI (Indicator)**: The raw metric (e.g., "Success Rate").
- **SLO (Objective)**: The target goal (e.g., "99.9% success rate over 30 days").
- **SLA (Agreement)**: The legal contract with customers (e.g., "If uptime < 99.5%, we credit your account").

---

## 🏗️ Section 13: CI/CD & Deployment Strategies
*(Reference: Video 2, Video 3)*

### **Q: Jenkins Shared Libraries vs. GitHub Actions?**
**The Answer**:
- **Jenkins Shared Libraries**: Groovy-based code that allows for code reuse across hundreds of Jenkins pipelines. Essential for medium-to-large Jenkins setups.
- **Modern CI (GHA/GitLab/Cloud Build)**: Focused on **Container-Native** builders. Instead of complex DSLs like Groovy, they use YAML and Docker-based "Actions" to run steps.

### **Q: Explain GitOps (Pull-based CD).**
**The Answer**:
**GitOps** is a set of practices where the desired state of infrastructure is stored in Git.
**How it works**: A controller (e.g., **ArgoCD**) runs inside the Kubernetes cluster. It continuously "pulls" the manifest from Git and compares it to the live cluster. If there is **Drift**, ArgoCD automatically reconciles it.
**Benefit**: Security (no push access from CI to cluster) and self-healing.

### **Q: How do you measure a "35% increase in delivery rate" or "50% reduction in deployment time"?**
**The Answer**:
I use **DORA Metrics** (DevOps Research and Assessment):
1.  **Deployment Frequency**: How often we ship to prod.
2.  **Lead Time for Changes**: Time from "Code Commit" to "Pod Running".
3.  **Measurement Logic**: We captured the "Before" (manual builds = 12 mins) and "After" (Parallel CI/CD = 4 mins). The percentage is the mathematical improvement in speed or frequency recorded in **Grafana** via pipeline telemetry.

---

## 📅 Section 14: Disaster Recovery & Business Continuity
*(Reference: Video 2)*

### **Q: Difference between RTO and RPO?**
**The Answer**:
- **RTO (Recovery Time Objective)**: The maximum amount of **Time** the service can be down (e.g., "2 hours to restore").
- **RPO (Recovery Point Objective)**: The maximum amount of **Data Loss** that is acceptable (e.g., "15 minutes of transactional data").
**Implementation**: Low RPO/RTO requires Multi-Region replication and Pilot Light or Warm Standby DR strategies.

### **Q: What is Chaos Engineering?**
**The Answer**:
**Chaos Engineering** is the practice of "injecting failure" into a production system to test its resiliency (e.g., killing a node, increasing network latency).
**Tool**: AWS **Fault Injection Service (FIS)** or **Chaos Mesh** for Kubernetes.
**Goal**: Identify weak points before they cause a real outage.
