# aws/terraform/modules/eks/variables.tf
variable "cluster_name"    { type = string }
variable "env"             { type = string }
variable "private_subnets" { type = list(string) }
variable "instance_type"   { type = string; default = "t3.medium" }
