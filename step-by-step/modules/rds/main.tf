# This integration is untested and will need a bit of work to get it up and running
# - Pull into the application main.tf
# - Pass in appropriate variables
module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "test-rds"

  engine            = "postgres"
  engine_version    = "11.10"
  instance_class    = "db.m4.large"
  allocated_storage = 5
  storage_encrypted = true

  name = "test-rds"
  username = "postgresuser"

  password = "super&secret%password"
  port     = "5432"

  iam_database_authentication_enabled = false

  vpc_security_group_ids = var.security_groups

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # make db creation faster
  backup_retention_period = 0
  tags = {
    name        = "test_database"
    proj        = "terraform class"
  }

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  subnet_ids = var.subnet_ids
  family = "postgres11"
  major_engine_version = "11"
  deletion_protection = false
}

