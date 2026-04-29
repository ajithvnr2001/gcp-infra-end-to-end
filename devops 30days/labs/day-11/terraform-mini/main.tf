terraform {
  required_version = ">= 1.5.0"
}

variable "environment" {
  type    = string
  default = "dev"
}

locals {
  common_tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

output "common_tags" {
  value = local.common_tags
}

