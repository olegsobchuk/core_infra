resource "random_uuid" "uuid" {}

resource "aws_s3_bucket" "deploy_bucket" {
  bucket = "deploy-bucket-${random_uuid.uuid.result}"
  acl    = "public-read" # "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms_secret.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "Deploy bucket"
    Environment = "dev"
  }
}

resource "aws_kms_key" "kms_secret" {
  description             = "KMS key"
  deletion_window_in_days = 7
}
