resource "aws_s3_bucket" "terraform_backend" {
  bucket = "terraform-class-2-16-${var.env}-state"

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
    name = "Remote terraform backend"
    env = var.env
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "terraform-class-2-16-${var.env}-state"

  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    name = "DynamoDB that stores the lock for Terraform"
    env = var.env
  }
}
