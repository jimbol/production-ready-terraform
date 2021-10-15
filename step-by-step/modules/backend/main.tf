resource "aws_s3_bucket" "terraform-remote-state-storage" {
  bucket = "terraform-state-${var.env}-10-6"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    name = "Remote Terraform state Store"
    proj = "Production Ready Terraform"
    env = var.env
  }
}

resource "aws_dynamodb_table" "terraform-state-lock" {
  name = "terraform-state-lock-${var.env}-10-6"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    name = "DynamoDB Terraform State Lock Table"
    proj = "Production ready Terraform"
    env = var.env
  }
}
