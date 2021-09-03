resource "aws_s3_bucket" "terraform-remote-state-storage" {
  bucket = "terraform-state-${var.env}-8-30" # has to be a unique name

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    name = "Remote Terraform State Store"
    proj = "Production Ready Terraform"
    env  = var.env
  }
}

resource "aws_dynamodb_table" "terraform-state-lock" {
  name           = "terraform-state-lock-${var.env}"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    name = "DynamoDB Terraform State Lock Table"
    proj = "Production Ready Terraform"
    env  = var.env
  }
}

