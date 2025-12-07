resource "aws_s3_bucket" "tfstate" {
  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = false
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "locks" {
  name         = var.dynamo_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

output "bucket" { value = aws_s3_bucket.tfstate.bucket }
output "dynamodb_table" { value = aws_dynamodb_table.locks.name }
