# terraform/envs/prod/main.tf

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # GCS remote state backend — run scripts/setup-backend.sh first
  backend "gcs" {
    bucket = "tf-state-ecommerce-prod-my-project-32062-newsletter"
    prefix = "prod/terraform.tfstate"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ── VPC & Networking ──────────────────────────────────────────────────────────
module "vpc" {
  source     = "../../modules/vpc"
  project_id = var.project_id
  region     = var.region
  env        = "prod"
}

# ── GKE Autopilot Cluster ─────────────────────────────────────────────────────
module "gke" {
  source          = "../../modules/gke"
  project_id      = var.project_id
  region          = var.region
  cluster_name    = "ecommerce-cluster"
  network         = module.vpc.network_name
  subnetwork      = module.vpc.subnet_id
  pods_range      = module.vpc.pods_range_name
  services_range  = module.vpc.services_range_name
  zone            = var.zone
}

# ── Cloud SQL (PostgreSQL) ────────────────────────────────────────────────────
module "cloudsql" {
  source      = "../../modules/cloudsql"
  project_id  = var.project_id
  region      = var.region
  network_id  = module.vpc.network_id
  db_password = var.db_password

  # Cloud SQL needs Private Services Access to be ready first
  depends_on = [module.vpc]
}

