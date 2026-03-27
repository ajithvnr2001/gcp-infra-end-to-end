# terraform/modules/gke/variables.tf
variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "pods_range" {
  type = string
}

variable "services_range" {
  type = string
}
