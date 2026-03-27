# aws/terraform/envs/prod/variables.tf
variable "region"      { type = string; default = "ap-south-1" }  # Mumbai
variable "db_password" { type = string; sensitive = true }
variable "account_id"  { type = string }   # your AWS account ID
