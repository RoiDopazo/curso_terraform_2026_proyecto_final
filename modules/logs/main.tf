# MÓDULO logs · Bucket S3 para los logs, con caducidad de los objetos

resource "aws_s3_bucket" "logs" {
  bucket        = var.nombre
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "caducar-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = var.dias_retencion
    }

    noncurrent_version_expiration {
      noncurrent_days = var.dias_retencion
    }
  }
}
