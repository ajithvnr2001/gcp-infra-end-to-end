# terraform/modules/vpc/main.tf

resource "google_compute_network" "vpc" {
  name                    = "${var.env}-ecommerce-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.env}-ecommerce-subnet"
  ip_cidr_range = "10.0.0.0/20"
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id

  # Secondary ranges for GKE pods and services
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.16.0.0/14"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.20.0.0/18"
  }
}

# Cloud Router (needed for Cloud NAT)
resource "google_compute_router" "router" {
  name    = "${var.env}-ecommerce-router"
  region  = var.region
  network = google_compute_network.vpc.id
  project = var.project_id
}

# Cloud NAT — allows private GKE nodes to reach internet (pull images, etc.)
resource "google_compute_router_nat" "nat" {
  name                               = "${var.env}-ecommerce-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall — allow internal traffic between pods/services
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.env}-allow-internal"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
}

# ── Private Services Access for Cloud SQL ─────────────────────────────────────
# This allocates an IP range for Google services (like Cloud SQL) to use
resource "google_compute_global_address" "private_ip_address" {
  name          = "${google_compute_network.vpc.name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# This creates the actual connection (peering) between your VPC and Google services
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
