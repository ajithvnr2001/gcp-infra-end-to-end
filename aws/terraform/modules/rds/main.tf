# aws/terraform/modules/rds/main.tf

resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-ecommerce-db-subnet"
  subnet_ids = var.private_subnets
  tags       = { Environment = var.env }
}

resource "aws_security_group" "rds" {
  name   = "${var.env}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.100.0.0/16"]   # only from within VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.env}-rds-sg" }
}

resource "aws_db_instance" "postgres" {
  identifier        = "${var.env}-ecommerce-postgres"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.medium"
  allocated_storage = 50
  storage_type      = "gp3"
  storage_encrypted = true   # encrypt at rest — security best practice

  db_name  = "ecommerce"
  username = "appuser"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az               = true       # standby replica in another AZ
  publicly_accessible    = false      # never expose DB to internet
  deletion_protection    = true

  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  performance_insights_enabled = true

  tags = {
    Environment = var.env
    ManagedBy   = "terraform"
  }
}
