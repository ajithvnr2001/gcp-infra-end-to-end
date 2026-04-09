# 🚀 System Engineer Interview Prep: AWS focused (with GCP Bridge)

This guide is tailored specifically for the **System Engineer** role focusing on AWS infrastructure, Linux administration, and CI/CD. Since you have primarily learned **GCP**, this document "bridges" your knowledge to the AWS equivalent using the **VERDICT-7 Framework**.

---

## 🏗️ Part 1: The Technical Bridge (GCP to AWS)
Use this table to translate your GCP expertise into the AWS terms the interviewer expects.

| Category | GCP Skill (What you know) | AWS Target (The JD Requirement) | Technical Delta / Difference |
| :--- | :--- | :--- | :--- |
| **Compute** | Compute Engine (GCE) | **EC2 (Elastic Compute Cloud)** | AWS uses "Instance Types" (e.g., t3.medium) instead of custom machine shapes. |
| **Networking** | Custom VPC / Subnets | **VPC / Subnets** | AWS Subnets are **Zonal**; GCP Subnets are **Regional**. |
| **Firewalls** | VPC Firewall Rules | **Security Groups / NACLs** | Security Groups are stateful (like GCP rules); NACLs are stateless. |
| **Storage** | Cloud Storage (GCS) | **Amazon S3** | S3 names are globally unique. Bucket policies are similar to IAM. |
| **Database** | Cloud SQL | **Amazon RDS** | Both are managed SQL services supporting Postgres/MySQL. |
| **Load Balancing** | Cloud Load Balancing (GCLB) | **ALB / NLB (Application/Network)** | AWS uses Target Groups; GCP uses Backend Services. |
| **Secrets** | Secret Manager | **AWS Secrets Manager** | AWS has native RDS rotation; GCP requires custom functions. |
| **Monitoring** | Cloud Monitoring | **Amazon CloudWatch** | CloudWatch "Events" are now called "EventBridge". |
| **Serverless** | Cloud Functions / Cloud Run | **AWS Lambda / Fargate** | Lambda is the event-driven standard in AWS. |
| **Autoscaling** | Managed Instance Groups (MIG) | **Auto Scaling Groups (ASG)** | ASGs are highly integrated with Target Groups for health-checks. |

---

## 🐧 Part 2: Linux & Web Server Scenarios (VERDICT-7)
*(Reference: JD Skills - Linux Administration, Nginx, PM2)*

### **Scenario 1: High CPU/RAM on a Node.js App (PM2)**
**The Prompt**: *"Our Node.js application is hitting 100% CPU on an EC2 instance. How do you find the root cause and solve it?"*

**VERDICT-7 Scan**:
- **V (Version)**: Is this a new deployment? Did the Node.js version change in the build?
- **E (Environment)**: Is this only happening in Production or also in Staging?
- **R (Resources)**: Use `top`, `htop`, or `pm2 monit` to see which process PID is the bottleneck. Check `free -m` for RAM spikes.
- **D (Dependencies)**: Is the app waiting on a slow RDS query or blocked by an external API?
- **I (Infra)**: Is the EC2 instance "Burstable" (t2/t3) and out of **CPU Credits**?
- **C (Connectivity)**: Is there a massive influx of traffic? Check Nginx access logs (`tail -f /var/log/nginx/access.log`).
- **T (Telemetry)**: Check **PM2 logs** (`pm2 logs`) and CloudWatch Metrics for CPU utilization.

**Technical Answer**:
"I would first check the process health using `pm2 jlist` or `htop`. If the application is truly consuming all CPU, I'd analyze the PM2 logs to look for infinite loops or unhandled rejections. If the instance is a t3.medium, I'd check for **CPU Credit exhaustion**. To solve it temporarily, I would restart the process using `pm2 restart <app_name>` or scale the **Auto Scaling Group** to add more nodes."

---

### **Scenario 2: Nginx Reverse Proxy & SSL Failure**
**The Prompt**: *"A customer reports a '502 Bad Gateway' or an SSL expired error. What are your steps?"*

**VERDICT-7 Scan**:
- **V (Version)**: Was the SSL certificate recently updated/renewed?
- **R (Resources)**: Is the backend service (Node.js/Python) actually running?
- **D (Dependencies)**: Is Nginx pointing to the right local socket or port?
- **I (Infra)**: Is the Load Balancer health-check failing?
- **C (Connectivity)**: Is port 443 open in the Security Group?
- **T (Telemetry)**: Check Nginx error logs (`/var/log/nginx/error.log`).

**Technical Answer**:
"A 502 usually means Nginx cannot talk to the backend. I would check if the app is running (`pm2 status`) and listening on the correct port (`netstat -tulnp`). For SSL, I'd verify the `nginx -t` configuration and check the expiry date using `openssl x509 -in cert.pem -noout -enddate`. If using AWS **ACM**, I'd check the status in the AWS Console."

---

## ☁️ Part 3: AWS Cloud Infrastructure Scenarios (VERDICT-7)
*(Reference: JD Skills - EC2, S3, RDS, IAM, VPC)*

### **Scenario 3: Secure VPC Design for a Production App**
**The Prompt**: *"How would you set up a VPC for a Node.js/React application ensuring maximum security?"*

**Technical Answer**:
"I architect for a **Multi-Tier Highly Available** setup:
1.  **Public Subnets**: Host the **Application Load Balancer (ALB)** and **NAT Gateway**.
2.  **Private Subnets**: Host the **EC2 instances** (Node.js). These have no direct internet access but use the NAT Gateway for updates.
3.  **Database Subnets**: An isolated tier for **Amazon RDS** with access limited only to the EC2 security group.
4.  **Security Groups**: I implement the **Principle of Least Privilege**. Port 443 is open to the world on the ALB, but Port 3000 (Node.js) is ONLY open to the ALB's security group."

**GCP Equivalent**: "In GCP, this is identical to creating a **Custom VPC** with Private Google Access enabled and using **GCP Cloud NAT** for the private GCE nodes."

---

## 🛠️ Part 4: CI/CD & Automation Scenarios (VERDICT-7)
*(Reference: JD Skills - GitHub Actions, GitLab CI, Node.js/React Deployments)*

### **Scenario 4: Automating a React + Node.js Deployment**
**The Prompt**: *"How would you design a CI/CD pipeline for a full-stack React/Node.js app on AWS?"*

**Technical Answer**:
"I use **GitHub Actions** for an automated **Blue/Green**-style deployment:
1.  **Build Stage**: Run `npm install` and `npm run build` for React. Build the Docker image for the Node.js backend.
2.  **Test Stage**: Execute unit tests and linting. Push images to **Amazon ECR**.
3.  **Deploy Stage**: 
    - For the **Frontend**: Sync the build folder to an **Amazon S3** bucket and invalidate the **CloudFront** cache.
    - For the **Backend**: Update the **ECS Task Definition** or SSH into the EC2 and run `pm2 pull && pm2 reload`.
4.  **Health Check**: Hit the `/health` endpoint and verify a 200 OK status."

**GCP Equivalent**: "In GCP, this is the same as using **Cloud Build** to push to **Artifact Registry** and deploying to **Cloud Run** or **GCE**."

---

## 🔐 Part 5: Security & Credentials Management
*(Reference: JD Skills - IAM, SSL, Environment Variables, Secrets)*

### **Scenario 5: Database Credential Security (Zero-Cleartext)**
**The Prompt**: *"How do you pass database passwords to your Node.js app without hardcoding them in the source code or environment variables?"*

**Technical Answer**:
"We follow a **Zero-Secret principle** using **AWS Secrets Manager**:
1.  **Storage**: Passwords are stored in Secrets Manager.
2.  **Runtime Injection**: The EC2 instance is assigned an **IAM Role** with permission to read that specific secret.
3.  **Application Layer**: The Node.js app uses the **AWS SDK** to fetch the secret at startup, OR we use the **External Secrets Operator** (for K8s) to sync it.
4.  **Local Dev**: We use `.env` files (git-ignored) or **AWS Vault**."

**GCP Equivalent**: "In GCP, we use **GCP Secret Manager** and **Workload Identity** to grant the GCE instance or GKE Pod permission without static JSON keys."

---

## 📈 Part 6: Monitoring, Scalability & Reliability
*(Reference: JD Skills - CloudWatch, Prometheus, Grafana, 99.9% Uptime)*

### **Scenario 6: Maintaining 99.9% Uptime (Fault Tolerance)**
**The Prompt**: *"Our agreement says 99.9% uptime. How do you design the system to achieve this?"*

**Technical Answer**:
"Uptime at this level requires **Redundancy** at every layer:
1.  **Redundant Instances**: Use an **Auto Scaling Group (ASG)** spread across at least two Availability Zones (AZs).
2.  **Self-Healing**: Configure **CloudWatch Alarms** to trigger an EC2 'Recover' or 'Reboot' if the system status check fails.
3.  **Process Monitoring**: Use **PM2** with the `--exp-backoff-restart` flag to ensure the Node.js process stays alive even after a crash.
4.  **Managed DB**: Use **RDS Multi-AZ** for automatic failover during a regional or instance-level outage."

---

## 🎯 Part 7: The "System Engineer" Final Checklist
Before your interview, ensure you can define these AWS services using your GCP knowledge:

1.  **ALB (Application Load Balancer)**: Like GCP's Global HTTP(S) Load Balancer.
2.  **Route 53**: Like GCP **Cloud DNS**.
3.  **IAM Policy**: Like GCP **IAM Bindings**.
4.  **Amazon VPC**: Like GCP **VPC Network**.
5.  **Amazon S3**: Like **GCP Cloud Storage**.
6.  **Amazon RDS**: Like **GCP Cloud SQL**.

**Interview Tip**: When asked about your experience, don't say *"I only know GCP"*. Instead, say: *"In my previous project, I solved [X problem] using GCP Cloud SQL, which is the direct equivalent of Amazon RDS. I manipulated the database via Terraform modules, so the architectural principles remain the same."*

---

**[Interview Prep Guide Complete for System Engineer JD]**
