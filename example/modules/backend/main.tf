resource "aws_s3_bucket" "terraform_backend" {
  bucket = "terraform-class-test-4-12-${var.env}-state"

  tags = {
    name = "Remote terraform backend"
    env = var.env
  }
}

resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.terraform_backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.terraform_backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "terraform-class-test-4-12-${var.env}-lock"

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
