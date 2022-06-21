resource "aws_s3_bucket" "terraform_backend" {
  bucket = "terraform-class-4-12-${var.env}-tfstate"

  lifecycle {
    prevent_destroy = false
  }

  # Terraform wont delete an S3 bucket with contents unless you force_destroy
  force_destroy = true

  tags = {
    Name = "Remote terraform backend"
    env = var.env
  }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encyption_config" {
  bucket = aws_s3_bucket.terraform_backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "terraform-class-4-12-${var.env}-lock"

  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "dynamo db that stores lock for terraform"
    env = var.env
  }
}
