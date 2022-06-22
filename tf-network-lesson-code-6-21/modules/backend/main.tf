# Tfstate bucket
resource "aws_s3_bucket" "terraform_backend" {
  bucket = "terraform-class-6-21-tfstate"

  lifecycle {
    prevent_destroy = false
  }

  force_destroy = true

  tags = {
    Name = "Remote terraform backend"
  }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_config" {
  bucket = aws_s3_bucket.terraform_backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Tfstate lock
resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "terraform-class-6-21-lock"

  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "dynamo db that stores lock for terraform"
  }
}
