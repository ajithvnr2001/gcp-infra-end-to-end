# terraform/envs/prod/variables.tf

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-south1"  # Mumbai
}

variable "db_password" {
  description = "Cloud SQL postgres password"
  type        = string
  sensitive   = true
}
