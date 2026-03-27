# aws/terraform/modules/rds/variables.tf
variable "env"             { type = string }
variable "vpc_id"          { type = string }
variable "private_subnets" { type = list(string) }
variable "db_password"     { type = string; sensitive = true }
