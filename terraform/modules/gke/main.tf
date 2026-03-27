# terraform/modules/gke/main.tf

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # Autopilot — Google manages nodes, scaling, upgrades automatically
  enable_autopilot = true
  
  # Deletion protection MUST be false for easy cleanup in dev
  deletion_protection = false

  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range
    services_secondary_range_name = var.services_range
  }

  # Private cluster — nodes have no public IPs (security best practice)
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.10.0/28"
  }

  # Enable Workload Identity — pods use GCP service accounts without keys
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Release channel
  release_channel {
    channel = "REGULAR"
  }

  # Simplified Monitoring and Logging
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }
}
