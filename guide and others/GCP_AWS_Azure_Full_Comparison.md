# ☁️ GCP vs AWS vs Azure — Interview Cheat Sheet (with Usage)

> **Your GCP home base, mapped to AWS & Azure equivalents — with real-world usage context.**
> Memory trick: **GCP = Google's Brainpower (Data/AI)** | **AWS = Amazon's Scale (Everything)** | **Azure = Microsoft's Enterprise (AD/Office)**

---

## 🧠 Quick Overview

| Cloud | Owner | Core Strength | Best For |
|-------|-------|---------------|----------|
| **GCP** | Google | Data, AI/ML, Kubernetes-native | AI startups, BigData, K8s-heavy infra |
| **AWS** | Amazon | Largest ecosystem, enterprise IaaS | General-purpose, max service breadth |
| **Azure** | Microsoft | Hybrid cloud, enterprise AD/Office 365 | Microsoft shops, enterprise compliance |

---

## 💻 Compute

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| Virtual Machines | **Compute Engine** | EC2 | Virtual Machines | Run any OS-level workload, custom software, legacy lift-and-shift |
| Autoscaling Groups | MIGs (Managed Instance Groups) | EC2 Auto Scaling | VM Scale Sets | Scale up/down VMs based on CPU/load automatically |
| Serverless Functions (FaaS) | **Cloud Run Functions** | Lambda | Azure Functions | Event-driven code with no server management (API callbacks, triggers) |
| PaaS App Hosting | **App Engine** | Elastic Beanstalk | App Service | Deploy web apps/APIs without managing infra (just push code) |
| Containerized Serverless | **Cloud Run** | Fargate / App Runner | Container Apps / ACI | Run Docker containers without managing K8s clusters |
| Batch Jobs | Batch | AWS Batch | Azure Batch | Large-scale parallel/HPC jobs (ETL, rendering, simulations) |
| HPC Cluster | Cluster Toolkit | ParallelCluster | CycleCloud | Scientific computing, genomics, CFD simulations |
| Dedicated/Bare Metal | Sole-tenant nodes | EC2 Dedicated Hosts | Dedicated Host | Compliance workloads that need physical isolation |
| Spot/Preemptible VMs | Spot VMs | EC2 Spot Instances | Azure Spot VMs | Cost-optimized batch/ML training jobs (up to 90% cheaper) |
| On-prem Extension | Google Distributed Cloud | AWS Outposts | Azure Stack | Run cloud services on your own data center hardware |
| VMware Migration | Google Cloud VMware Engine | VMware Cloud on AWS | Azure VMware Solution | Migrate VMware workloads to cloud with zero refactoring |
| Quantum Computing | — | Amazon Braket | Azure Quantum | Research-level quantum algorithm testing |

---

## 🐳 Containers & Kubernetes

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| Managed Kubernetes | **GKE** | EKS | AKS | Orchestrate containerized microservices at scale |
| Container Registry | **Artifact Registry** | ECR | Azure Container Registry | Store and manage Docker images securely |
| Managed Container Service | — | ECS | Azure Container Apps | Simpler container deployments without full K8s overhead |
| Serverless Containers | **Cloud Run** | Fargate | Container Instances (ACI) | Run stateless containers on-demand with zero cluster management |
| CI/CD for Containers | Cloud Build + Cloud Deploy | CodePipeline + CodeDeploy | Azure DevOps / GitHub Actions | Automate container build, test, and deploy pipelines |
| Service Mesh | Cloud Service Mesh | AWS App Mesh | Open Service Mesh on AKS | Manage traffic, retries, mTLS between microservices |
| Container Migration | Migrate to Containers | App2Container | Azure Migrate App Containerization | Containerize existing VMs or on-prem apps automatically |

> 💡 **GKE is widely regarded as the best managed Kubernetes service** (Google invented K8s). EKS is most popular due to AWS ecosystem. AKS is easiest for Azure-native apps.

---

## 🗄️ Storage

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| Object Storage | **Cloud Storage (GCS)** | S3 | Blob Storage | Store files, images, videos, backups, ML datasets — any unstructured data |
| Block Storage | Persistent Disk / Hyperdisk | EBS | Azure Disk Storage | Attach as a hard drive to a VM for databases, OS volumes |
| File Storage (NFS) | **Filestore** | EFS / FSx | Azure Files | Shared file system across multiple VMs (NFS/SMB protocol) |
| Archive / Cold Storage | Archive tier in Cloud Storage | S3 Glacier | Azure Archive Storage | Long-term retention of data rarely accessed (compliance, backups) |
| Parallel/HPC File System | Parallelstore | FSx for Lustre | Azure Managed Lustre | High-throughput parallel I/O for ML training, genomics |
| Backup Service | Backup and DR Service | AWS Backup | Azure Backup | Centralized policy-based backup for VMs, DBs, disks |
| Physical Data Transfer | Transfer Appliance | Snowball / Snowcone | Data Box | Move petabytes of data physically when network transfer is too slow |
| Online Data Transfer | Storage Transfer Service | DataSync | Azure Storage Mover | Scheduled online data migration between clouds or on-prem |

> 💡 **GCS = S3 = Blob Storage** is the most common mapping. All support lifecycle policies, versioning, and multiple tiers.

---

## 🗃️ Databases

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| Managed RDBMS | **Cloud SQL** | RDS | Azure DB for MySQL / PostgreSQL / SQL | Managed MySQL, PostgreSQL, MSSQL — standard web app databases |
| High-performance PostgreSQL | **AlloyDB** | Aurora | Cosmos DB for PostgreSQL | High-throughput PostgreSQL workloads with 4x+ faster queries |
| Globally Distributed RDBMS | **Cloud Spanner** | Aurora Global | Azure SQL Hyperscale | Multi-region ACID SQL with zero downtime — fintech, inventory systems |
| NoSQL Key-Value | **Bigtable** | DynamoDB | Cosmos DB | Single-digit ms reads/writes at massive scale — time-series, IoT, leaderboards |
| NoSQL Document | **Firestore** | DocumentDB | Cosmos DB | JSON document storage for mobile/web apps with real-time sync |
| NoSQL Graph | Neo4j on GCP | Neptune | Cosmos DB (Gremlin API) | Social networks, fraud detection, recommendation graphs |
| In-Memory / Cache | **Memorystore** | ElastiCache | Azure Cache for Redis | Session caching, rate limiting, pub/sub — Redis or Memcached managed |
| Data Warehouse | **BigQuery** | Redshift | Azure Synapse Analytics | Analytical queries over terabytes/petabytes of data (OLAP) |
| Time Series DB | Bigtable | Amazon Timestream | Azure Time Series Insights | IoT sensor data, metrics, financial tick data over time |

> 💡 **Spanner is GCP's crown jewel** — the only globally distributed relational DB with strong consistency. Nothing else does this at scale.

---

## 📊 Data Analytics & Big Data

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| Serverless Data Warehouse | **BigQuery** | Redshift | Azure Synapse Analytics | Run SQL on petabytes in seconds — no cluster to manage |
| Spark / Hadoop Cluster | **Dataproc** | EMR | HDInsight / Databricks | Large-scale Spark/Hadoop batch processing — ETL, ML feature engineering |
| Real-time Stream Processing | **Dataflow** | Kinesis Data Analytics | Azure Stream Analytics | Process streaming events in real-time (Apache Beam under the hood) |
| Pub/Sub / Kafka-style | **Pub/Sub** | Kinesis / MSK | Event Hubs / Service Bus | Decouple producers and consumers — event-driven architectures |
| ETL / Data Integration | **Cloud Data Fusion** | AWS Glue | Azure Data Factory | Visual drag-and-drop ETL pipelines, batch data ingestion |
| Airflow Managed | **Cloud Composer** | Amazon MWAA | Azure Managed Airflow | Schedule and orchestrate complex data workflows (DAGs) |
| BI / Dashboards | **Looker** | QuickSight | Power BI | Business dashboards, reporting, self-serve analytics |
| Data Governance / Catalog | **Dataplex / Catalog** | AWS Glue Catalog / DataZone | Microsoft Purview | Data discovery, lineage tracking, governance policies |
| Change Data Capture | **Datastream** | DMS / Aurora zero-ETL | Azure Data Factory | Replicate DB changes in real-time to analytics systems (CDC) |
| Serverless SQL on Files | **BigQuery** | Amazon Athena | Azure Synapse Serverless | Query data directly in GCS/S3/ADLS without loading into a DB |

> 💡 **BigQuery is GCP's biggest differentiator** — serverless, no infrastructure, pay per query. Ideal when you're already on GCP and need analytics.

---

## 🤖 AI & Machine Learning

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| ML Platform (end-to-end) | **Vertex AI** | SageMaker | Azure Machine Learning | Train, evaluate, deploy, and monitor ML models at scale |
| Generative AI / LLM Hub | **Vertex AI (Gemini / Model Garden)** | Amazon Bedrock | Azure OpenAI Service | Access and customize foundation models (LLMs, image models) via API |
| AI Assistant | **Gemini for GCP** | Amazon Q | Azure Copilot | AI assistant embedded into cloud console for coding, ops help |
| AI Coding Assistant | **Gemini Code Assist** | Amazon Q Developer | GitHub Copilot | In-IDE AI pair programmer for code completion and generation |
| ML Notebooks | **Vertex AI Workbench / Colab Enterprise** | SageMaker Studio Notebooks | Azure ML Notebooks | Interactive Jupyter notebooks for data exploration and model dev |
| AutoML (no-code ML) | Vertex AI AutoML | SageMaker Autopilot | Azure AutoML | Build ML models without writing training code |
| Image Recognition | **Vision AI** | Amazon Rekognition | Azure AI Vision | Detect objects, faces, text in images (pre-trained APIs) |
| NLP / Text Analysis | **Natural Language AI** | Amazon Comprehend | Azure AI Language | Sentiment, entity extraction, classification on text data |
| Document OCR | **Document AI** | Amazon Textract | Azure AI Document Intelligence | Extract text, tables, key-value pairs from PDFs, forms, invoices |
| Speech-to-Text | **Speech-to-Text API** | Amazon Transcribe | Azure AI Speech | Transcribe audio/video content, call center recordings |
| Text-to-Speech | **Text-to-Speech API** | Amazon Polly | Azure AI Speech (TTS) | Convert text to natural-sounding speech for apps, IVR systems |
| Translation | **Translation AI** | Amazon Translate | Azure AI Translator | Real-time or batch translation of text across languages |
| Video Intelligence | **Video Intelligence API** | Rekognition Video | Azure Video Indexer | Label detection, scene segmentation, transcript from video |
| Recommendation Engine | Recommendations AI | Amazon Personalize | Azure AI Personalizer | Personalized product/content recommendations (e-commerce, media) |
| Chatbot / Conversational AI | **Dialogflow** | Amazon Lex | Azure AI Bot Service | Build NLU-powered chatbots and voice assistants |
| AI Accelerator Chips | **Cloud TPU / Trillium TPU** | AWS Inferentia / Trainium | Azure Maia 100 | Large model training and inference at reduced cost vs GPU |

> 💡 **GCP TPUs are fastest for TensorFlow/JAX model training.** AWS Bedrock offers the widest model choice (Claude, Llama, Titan). Azure OpenAI has exclusive GPT-4o access.

---

## 🌐 Networking

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| Virtual Private Network | **VPC** | Amazon VPC | Azure VNet | Isolated network environment — the foundation of cloud networking |
| Site-to-Site VPN | Cloud VPN | AWS VPN | Azure VPN Gateway | Encrypt traffic between on-prem and cloud over public internet |
| Dedicated Private Line | **Cloud Interconnect** | AWS Direct Connect | Azure ExpressRoute | Low-latency, high-bandwidth private line bypassing public internet |
| Load Balancing | **Cloud Load Balancing** | Elastic Load Balancing (ELB) | Azure Load Balancer / App Gateway | Distribute traffic across instances (L4 TCP or L7 HTTP) |
| CDN | **Cloud CDN / Media CDN** | CloudFront | Azure Front Door | Cache static content at edge nodes globally for low latency |
| DNS | **Cloud DNS** | Route 53 | Azure DNS | Manage domain name resolution with GeoDNS and failover routing |
| DDoS + WAF | **Cloud Armor** | AWS Shield + WAF | Azure DDoS Protection + WAF | Protect apps from DDoS, SQL injection, XSS attacks |
| NAT Gateway | Cloud NAT | AWS NAT Gateway | Azure NAT Gateway | Allow private VMs to reach the internet without public IPs |
| Private Connectivity | Private Service Connect | AWS PrivateLink | Azure Private Link | Connect to cloud services privately without traversing internet |
| Global Accelerator | Premium Network Tier | AWS Global Accelerator | Microsoft Global Network | Route traffic over cloud provider's private backbone for speed |
| Virtual WAN / Transit | Network Connectivity Center | Cloud WAN / Transit Gateway | Azure Virtual WAN | Hub-and-spoke network connecting multiple VPCs/VNets centrally |
| NGFW / Firewall | **Cloud NGFW** | AWS Network Firewall | Azure Firewall | Deep packet inspection, FQDN filtering for VPC-level security |
| Network Monitoring | Network Intelligence Center | AWS Network Manager | Azure Network Watcher | Debug connectivity issues, visualize topology, monitor flows |

---

## 🔒 Security & Identity

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| IAM (Access Control) | **Cloud IAM** | AWS IAM | Microsoft Entra ID | Control who can do what on which resource — core of cloud security |
| Employee SSO / Identity | **Cloud Identity** | AWS IAM Identity Center | Microsoft Entra ID (Azure AD) | Manage employee logins, SSO to cloud apps, MFA |
| End-User Auth / CIAM | **Identity Platform / Firebase Auth** | Amazon Cognito | Azure AD B2C | Add sign-up, login, social auth to your own apps |
| Secret Management | **Secret Manager** | AWS Secrets Manager | Azure Key Vault | Store and rotate API keys, DB passwords, certificates securely |
| Key Management (KMS) | **Cloud KMS / Cloud HSM** | AWS KMS / CloudHSM | Azure Key Vault / Dedicated HSM | Encrypt data at rest, manage encryption keys with HSM backing |
| Security Posture | **Security Command Center** | AWS Security Hub | Microsoft Defender for Cloud | Single pane for misconfigurations, vulnerabilities across your cloud |
| Threat Detection | SCC / Event Threat Detection | Amazon GuardDuty | Microsoft Defender for Cloud | Detect suspicious activity, crypto mining, account compromises |
| Data Loss Prevention | **Sensitive Data Protection** | Amazon Macie | Microsoft Purview DLP | Scan and de-identify PII, credit card numbers in storage |
| Certificate Management | Certificate Authority Service | AWS Certificate Manager | Azure App Service Certificates | Provision and auto-renew TLS certificates for your domains |
| Zero Trust / App Proxy | **IAP (Identity-Aware Proxy)** | AWS Verified Access | Azure AD App Proxy | Grant access to internal apps based on identity, not VPN |
| Compliance / Gov Cloud | Assured Workloads | AWS GovCloud | Azure Government | Regulated workloads (FedRAMP, HIPAA, PCI-DSS, IL4) |
| Confidential Computing | **Confidential VMs / Confidential Space** | AWS Nitro Enclaves | Azure Confidential Computing | Process sensitive data in encrypted memory (TEE) — fintech, healthcare |
| Container Security | Binary Authorization + Artifact Analysis | ECR Image Scanning | Defender for Containers | Allow only signed, scanned images to deploy to production |

---

## ⚙️ DevOps & Developer Tools

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| CI/CD Pipeline | **Cloud Build + Cloud Deploy** | CodePipeline + CodeBuild + CodeDeploy | Azure DevOps / Azure Pipelines | Automate build, test, deploy pipelines for any language or container |
| CLI | **gcloud CLI** | AWS CLI | Azure CLI | Manage all cloud resources from terminal / scripts |
| Cloud Shell | **Cloud Shell** | AWS CloudShell | Azure Cloud Shell | Browser-based terminal pre-authenticated to your cloud account |
| IDE Plugin | Cloud Code (VS Code / JetBrains) | AWS Toolkit | Azure Tools | Cloud-aware autocomplete, deploy, debug directly from your IDE |
| Git Repos | **Cloud Source Repositories** | AWS CodeCommit | Azure Repos | Host private Git repos within your cloud environment |
| Artifact Registry | **Artifact Registry** | AWS CodeArtifact | Azure Artifacts | Store Docker images, npm, Maven, PyPI packages privately |
| Job Scheduler | **Cloud Scheduler** | Amazon EventBridge Scheduler | Azure Logic Apps / Timer Triggers | Run cron jobs to trigger Pub/Sub, HTTP, Cloud Functions on a schedule |
| Task Queue | **Cloud Tasks** | Amazon SQS + SNS | Azure Service Bus + Queue Storage | Async task dispatch with rate limiting and retry logic |
| Workflow Orchestration | **Workflows** | AWS Step Functions | Azure Logic Apps | Chain multiple cloud services into reliable serverless workflows |
| Event Bus | **Eventarc** | Amazon EventBridge | Azure Event Grid | Route events from GCP services to your Cloud Run or Functions |
| IaC Automation | Cloud Deployment Manager | AWS CloudFormation / CDK | Azure Resource Manager / Bicep | Define and provision infrastructure as declarative code |
| No-code / Low-code | **AppSheet** | AWS Amplify Studio | Microsoft Power Apps | Build apps without code from spreadsheets or data sources |

> 💡 **Terraform works across all three** — preferred for multi-cloud IaC. CloudFormation/CDK is AWS-only, Bicep/ARM is Azure-only, Deployment Manager is GCP-only.

---

## 📡 Messaging & Integration

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| Pub/Sub Messaging | **Pub/Sub** | Amazon SNS + SQS | Azure Service Bus + Event Hubs | Decouple microservices with fan-out messaging and guaranteed delivery |
| Queue Service | **Cloud Tasks** | Amazon SQS | Azure Queue Storage | Simple reliable FIFO queues for async job processing |
| Event Streaming (Kafka-like) | **Pub/Sub + Dataflow** | Amazon Kinesis Data Streams | Azure Event Hubs | Real-time ordered event streaming (clickstreams, logs, telemetry) |
| Managed Kafka | Confluent Cloud on GCP | Amazon MSK | Azure Event Hubs for Kafka | Native Kafka API compatibility for teams already using Kafka |
| API Gateway | **Apigee / Cloud API Gateway** | Amazon API Gateway | Azure API Management | Publish, secure, throttle, and monitor REST/GraphQL APIs |
| Integration Platform (iPaaS) | Application Integration | Amazon AppFlow | Azure Logic Apps | Connect SaaS apps (Salesforce, Workday) to cloud without code |
| Service Mesh | Cloud Service Mesh | AWS App Mesh | Azure Service Fabric Mesh | mTLS, traffic splitting, retries between microservices |

---

## 📈 Operations & Monitoring

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| Metrics Monitoring | **Cloud Monitoring** | Amazon CloudWatch | Azure Monitor | Dashboards, alerts, uptime checks on CPU, memory, latency |
| Log Management | **Cloud Logging** | CloudWatch Logs | Azure Monitor Logs | Aggregate, search, and alert on logs from all services |
| Distributed Tracing | **Cloud Trace** | AWS X-Ray | Application Insights | Trace latency across microservices to find bottlenecks |
| Code Profiling | **Cloud Profiler** | CodeGuru Profiler | App Insights Profiler | Low-overhead CPU/heap profiling in production applications |
| Audit Logs | **Cloud Audit Logs** | AWS CloudTrail | Azure Activity Logs | Track who did what, when — essential for compliance/forensics |
| Error Tracking | Error Reporting | CloudWatch Alarms | Application Insights | Surface and group application exceptions with stack traces |
| Cost Management | **Cost Management + Recommenders** | AWS Cost Explorer + Trusted Advisor | Azure Advisor + Cost Management | Visualize spend, get rightsizing recommendations, set budgets |
| Patch / Systems Management | VM Manager | AWS Systems Manager | Azure Update Manager | Automated OS patching, inventory, remote commands on VMs |
| Multi-Account / Org Mgmt | Resource Manager + Org Policy Service | AWS Organizations + Control Tower | Azure Management Groups + Policy | Enforce governance policies across all projects/accounts at org level |

---

## 🔄 Migration

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| Server Migration | Migrate to Virtual Machines | AWS Application Migration Service | Azure Migrate | Lift-and-shift physical/VMware/cloud VMs to the new cloud |
| Container Migration | Migrate to Containers | App2Container | Azure Migrate App Containerization | Auto-detect and containerize Java/.NET apps from VMs |
| Database Migration | Database Migration Service | AWS DMS | Azure Database Migration Service | Migrate Oracle, MySQL, SQL Server DBs with minimal downtime |
| Online Data Transfer | Storage Transfer Service | AWS DataSync | Azure Storage Mover | Scheduled transfer of large data sets from on-prem or other clouds |
| Offline Data Transfer | Transfer Appliance | Snowball / Snowmobile | Azure Data Box | Ship PBs of data physically when network transfer takes months |

---

## 🔥 Firebase → AWS / Azure Equivalents

| Firebase Service | What It Does | AWS Equivalent | Azure Equivalent |
|------------------|-------------|----------------|-----------------|
| **Firebase Auth** | User signup, login, social auth | Amazon Cognito | Azure AD B2C |
| **Firestore** | NoSQL real-time document DB | DynamoDB / DocumentDB | Cosmos DB |
| **Realtime Database** | Sync JSON DB in real-time | DynamoDB Streams | Cosmos DB Change Feed |
| **Firebase Hosting** | Static site / SPA hosting | AWS Amplify Hosting | Azure Static Web Apps |
| **Cloud Functions for Firebase** | Server-side event triggers | AWS Lambda | Azure Functions |
| **Firebase Cloud Messaging** | Push notifications (mobile/web) | Amazon SNS / ADM | Azure Notification Hubs |
| **Firebase Analytics** | App event tracking | Amazon Pinpoint / Kinesis | App Center Analytics |
| **Remote Config** | Feature flags without redeploy | AWS AppConfig | Azure App Configuration |
| **Firebase Test Lab** | Device farm for app testing | AWS Device Farm | — |
| **Firebase Crashlytics** | Crash reporting for mobile | — | App Center Crashes |
| **Firebase Storage** | User-uploaded file storage | Amazon S3 | Azure Blob Storage |

---

## 🏢 Enterprise & Business Apps

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| Collaboration Suite | **Google Workspace** | — | Microsoft 365 | Team email, docs, video calls — full SaaS productivity suite |
| Virtual Desktop | — | Amazon WorkSpaces | Azure Virtual Desktop | Cloud-based Windows desktops for remote workers |
| Maps & Geolocation | **Google Maps Platform** | Amazon Location Service | Azure Maps | Embed maps, geocoding, routing, Places API in your apps |
| Media Encoding | Live Stream API / Transcoder API | AWS Elemental / MediaLive | Azure Media Services | Transcode, stream, and distribute video content at scale |
| Marketplace | Google Cloud Marketplace | AWS Marketplace | Azure Marketplace | Deploy 3rd-party software (DBs, security tools) with 1-click |
| Voice Assistant | Google Assistant SDK | Amazon Alexa Skills | Azure AI Speech | Build voice-driven apps and smart device integrations |

---

## 🌐 IoT

| Category | GCP | AWS | Azure | 📌 When to Use |
|----------|-----|-----|-------|---------------|
| IoT Gateway / Broker | — | **AWS IoT Core** | Azure IoT Hub | MQTT/HTTPS broker for millions of IoT device connections |
| IoT Edge Computing | Edge TPU | AWS IoT Greengrass | Azure IoT Edge | Run ML inference and logic on the device locally (edge AI) |
| IoT Device Management | — | AWS IoT Device Management | Azure IoT Central | OTA updates, fleet monitoring, device configuration at scale |
| Digital Twins | — | AWS IoT TwinMaker | **Azure Digital Twins** | Virtual models of physical assets (buildings, factories, supply chains) |

---

## 🎯 Master Memory Table — "Same Thing, Different Names"

> **Most asked in cloud interviews — memorize this!**

| Concept | GCP | AWS | Azure | Quick Tip |
|---------|-----|-----|-------|-----------|
| Virtual Machine | Compute Engine | **EC2** | Virtual Machines | EC2 = most widely known |
| Object Storage | **Cloud Storage (GCS)** | S3 | Blob Storage | GCS/S3/Blob = same concept |
| Serverless Function | Cloud Run Functions | **Lambda** | Azure Functions | Lambda = pioneer of FaaS |
| Managed Kubernetes | **GKE** | EKS | AKS | GKE = best managed K8s |
| Serverless Container | **Cloud Run** | Fargate | Container Instances | Cloud Run = Docker without K8s |
| Data Warehouse | **BigQuery** | Redshift | Synapse Analytics | BigQuery = serverless, no cluster |
| ML Platform | **Vertex AI** | SageMaker | Azure ML | All are end-to-end MLOps platforms |
| Generative AI | Vertex AI + Gemini | **Bedrock** | Azure OpenAI | Bedrock = widest model choice |
| IAM | Cloud IAM | **AWS IAM** | Microsoft Entra ID | Entra ID = former Azure AD |
| Key Management | Cloud KMS | AWS KMS | **Azure Key Vault** | Key Vault also stores secrets |
| Secret Store | Secret Manager | Secrets Manager | **Azure Key Vault** | GCP/AWS have separate services |
| Monitoring | Cloud Monitoring | **CloudWatch** | Azure Monitor | CloudWatch = logs + metrics unified |
| Audit Trails | Cloud Audit Logs | **CloudTrail** | Activity Logs | CloudTrail = who did what |
| DNS | Cloud DNS | **Route 53** | Azure DNS | Route 53 = also health checks/failover |
| CDN | Cloud CDN | **CloudFront** | Azure Front Door | CloudFront = most used CDN |
| Dedicated Line | Cloud Interconnect | **Direct Connect** | ExpressRoute | Bypass public internet for reliability |
| Message Queue | Pub/Sub / Cloud Tasks | **SQS / SNS** | Service Bus | SQS = queue, SNS = fan-out |
| Event Streaming | Pub/Sub | **Kinesis** | Event Hubs | All are Kafka-compatible alternatives |
| CI/CD Pipeline | Cloud Build + Deploy | CodePipeline | **Azure DevOps** | Azure DevOps = most feature-rich |
| IaC Tool | Deployment Manager | **CloudFormation** | ARM / Bicep | Terraform works across all 3 |
| DDoS + WAF | **Cloud Armor** | AWS Shield + WAF | Azure DDoS Protection | Cloud Armor = Anycast-based, very fast |
| API Gateway | **Apigee** | API Gateway | Azure API Management | Apigee = most advanced (rate limit, portal, monetize) |
| VPN Gateway | Cloud VPN | AWS VPN | Azure VPN Gateway | All support IKEv2, BGP, HA |
| Load Balancer | Cloud Load Balancing | ELB (ALB/NLB/CLB) | Azure LB / App Gateway | ELB has 3 variants; GCP is global by default |
| Private Link | Private Service Connect | **PrivateLink** | Private Link | Access cloud services privately without internet |

---

## 💡 Key Differentiators — Say This in Interviews

### Choose GCP when:
- Your workload is **data-heavy** (BigQuery is unmatched for serverless analytics)
- You run **Kubernetes** heavily — GKE is the gold standard
- You need **globally distributed SQL** — Spanner is unique
- You're doing **AI/ML** with TensorFlow/JAX on TPUs
- You want the best **price-performance** on networking (Google's private global fiber)

### Choose AWS when:
- You need the **broadest service catalog** (200+ services, no equivalent)
- Your team needs **maximum hiring pool** (most AWS-certified engineers)
- You want the most **enterprise integrations** and ISV partnerships
- You need **Lambda's maturity** — 200+ triggers, lowest cold starts, fastest scaling
- Your app has **unpredictable, spiky traffic** — AWS scales most elastically

### Choose Azure when:
- Your org is a **Microsoft shop** (Active Directory, Office 365, .NET, SQL Server)
- You need **hybrid cloud** — Azure Arc and Azure Stack are best-in-class
- You're building with **OpenAI/GPT-4** models — Azure has exclusive enterprise access
- Your industry requires strict **compliance** (FedRAMP, HIPAA, government sectors)
- You run **Windows Server** workloads — Azure gives massive hybrid licensing discounts

---

## 🏆 Head-to-Head Verdict (2026)

| Category | Winner | Reason |
|----------|--------|--------|
| AI / ML Innovation | **GCP** | Gemini, TPUs, Vertex AI, BigQuery ML |
| Serverless Functions | **AWS** | Lambda: lowest cold starts, 200+ triggers |
| Managed Kubernetes | **GCP** | GKE: K8s was built by Google |
| Data Warehouse | **GCP** | BigQuery: serverless, no cluster management |
| Enterprise Identity | **Azure** | Microsoft Entra ID (AD) dominates enterprises |
| Hybrid Cloud | **Azure** | Azure Arc + Stack = best on-prem extension |
| Service Breadth | **AWS** | 200+ services vs ~170 for Azure, ~100+ for GCP |
| Compliance / Gov | **Azure** | Most certifications, government cloud |
| CDN Performance | **AWS** | CloudFront: largest PoP network globally |
| Global Network | **GCP** | Premium Tier uses Google's private fiber backbone |
| Cost Simplicity | **GCP** | No egress on GKE, committed use discounts simpler |
| OpenAI / GPT Access | **Azure** | Exclusive enterprise deployment of GPT-4o |

---

*Sources: Google Cloud Docs, TechTarget, cloudjobs.io, avidclan.com | Last updated: June 2026*
