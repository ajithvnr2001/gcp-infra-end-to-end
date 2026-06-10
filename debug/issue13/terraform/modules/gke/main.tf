# terraform/modules/gke/main.tf

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone
  project  = var.project_id

  # Remove default node pool to replace with custom one
  remove_default_node_pool = true
  initial_node_count       = 1

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

# Custom Node Pool for Standard GKE (Zonal)
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  project    = var.project_id
  node_count = 2

  autoscaling {
    min_node_count = 2
    max_node_count = 5
  }

  node_config {
    preemptible  = false
    machine_type = "e2-standard-2"

    # Google recommend custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = "default"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = "prod"
    }

    # Enable Workload Identity on nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  lifecycle {
    ignore_changes = [node_count]
  }
}
