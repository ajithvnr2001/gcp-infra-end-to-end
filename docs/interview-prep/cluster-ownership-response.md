# Interview Talking Points: K8s Cluster Ownership & Incidents

This version is written to sound like a natural conversation during an interview. Instead of reading it like a document, use these points to tell a story about your experience with this project.

---

### Question: 
"Have you directly owned Kubernetes clusters running production traffic? What kind of scale and incidents have you handled?"

### Talking Points (Mental Script):

"Yeah, I've had direct ownership of GKE clusters in production environments, specifically for an e-commerce platform I built on GCP. My role wasn't just managing the pods—I owned the whole stack, from the Terraform modules for the VPC and Cloud SQL to the GitOps workflows using ArgoCD.

On the architectural side, I set up a private cluster with Autopilot to handle the heavy lifting of node management. I integrated it with a custom VPC where we used Private Service Access for our Postgres databases, ensuring the database traffic never touched the public internet. For scale, we used HPA to handle traffic spikes, and I managed about 10 microservices, all moving through a central API gateway.

Regarding incidents, I've definitely had my share of real-world troubleshooting. 

One case that comes to mind was a communication failure after we moved to a Zero-Trust security model. I'd implemented strict NetworkPolicies that defaulted to 'deny-all,' and it ended up blocking a new version of our orders service from reaching the payment gateway. I had to jump into Cloud Trace and check the network logs to figure out where the packets were dropping. Once I identified the issue, I just updated the policy manifests in Git, let ArgoCD sync them, and service was back up in minutes.

Another interesting one was a 409 conflict during an infrastructure migration. Our Terraform state bucket had a naming collision because bucket namespaces are global. I had to refactor our backend setup to use a more unique project-based naming scheme and then migrate the state without breaking the live resources. It was a good lesson in plan-ahead naming conventions for multi-tenant environments.

I also dealt with more specific GKE issues, like 400 errors during cluster provisioning where the master CIDR or maintenance windows were misconfigured. Resolving those usually came down to deep-diving into the GCP provider docs and ensuring Private Google Access was enabled on our subnets so the control plane could communicate properly.

Overall, owning the cluster for me meant being responsible for the networking, the security layer, and the deployment pipeline, not just the application code itself."
