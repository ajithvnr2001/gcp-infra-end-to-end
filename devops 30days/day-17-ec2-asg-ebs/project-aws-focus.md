# Day 17 Project + AWS Focus

## Project Connection

If this project runs on EKS with managed node groups, EC2 instances still exist under the worker nodes.

## GCP To AWS Mapping

GKE node pool maps to EKS managed node group or EC2 Auto Scaling Group.

## Project Question

EKS node is NotReady. What do you check?

Answer:

```text
Check EC2 health, kubelet, node disk/memory pressure, IAM permissions, CNI/IP exhaustion, security groups, and cluster autoscaler events.
```

