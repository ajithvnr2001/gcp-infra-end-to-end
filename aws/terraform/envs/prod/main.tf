# aws/terraform/envs/prod/main.tf

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "tf-state-ecommerce-aws-prod"   # create manually first
    key    = "prod/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
    dynamodb_table = "tf-state-lock"          # prevents concurrent applies
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = "ecommerce-platform"
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}

module "vpc" {
  source             = "../../modules/vpc"
  env                = "prod"
  region             = var.region
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "eks" {
  source          = "../../modules/eks"
  cluster_name    = "ecommerce-eks-prod"
  env             = "prod"
  private_subnets = module.vpc.private_subnets
  instance_type   = "t3.large"
}

module "rds" {
  source          = "../../modules/rds"
  env             = "prod"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  db_password     = var.db_password
}

# S3 bucket for static assets (product images etc.)
resource "aws_s3_bucket" "assets" {
  bucket = "ecommerce-assets-${var.account_id}"
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 backend state bucket
resource "aws_s3_bucket" "tf_state" {
  bucket = "tf-state-ecommerce-aws-prod"
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration { status = "Enabled" }
}

# DynamoDB for state locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = "tf-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# CloudWatch log group for EKS
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/ecommerce-eks-prod/cluster"
  retention_in_days = 30
}
