# terraform/modules/cloudsql/main.tf

resource "google_sql_database_instance" "postgres" {
  name             = "ecommerce-postgres"
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project_id

  # Prevent accidental deletion in production
  deletion_protection = false

  settings {
    tier              = "db-g1-small"   # upgrade to db-custom-4-16384 for prod load
    availability_type = "REGIONAL"      # High availability — standby in another zone
    disk_type         = "PD_SSD"
    disk_size         = 50
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"   # IST 7:30am
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
      }
    }

    # Private IP — database NOT exposed to internet
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
    }

    maintenance_window {
      day          = 7   # Sunday
      hour         = 2   # 2am UTC
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }
  }
}

# Create databases for each service
resource "google_sql_database" "catalog_db" {
  name     = "catalog"
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}

resource "google_sql_database" "orders_db" {
  name     = "orders"
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}

# App user (not root)
resource "google_sql_user" "app_user" {
  name     = "appuser"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
  project  = var.project_id
}
