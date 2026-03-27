# aws/terraform/modules/vpc/variables.tf
variable "env"                { type = string }
variable "region"             { type = string }
variable "availability_zones" { type = list(string) }
