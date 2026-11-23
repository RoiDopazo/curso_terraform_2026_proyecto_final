# BOOTSTRAP · Bucket del estado de los entornos (estado LOCAL, como en el módulo 3)

resource "aws_s3_bucket" "estado" {
  bucket        = "${var.prefijo}-tfstate-proyecto"
  force_destroy = true # en el curso, para poder borrarlo; en producción, nunca
}

resource "aws_s3_bucket_versioning" "estado" {
  bucket = aws_s3_bucket.estado.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Excepción justificada (AWS-0132): el bucket del estado se cifra con AES256 (SSE-S3,
# claves gestionadas por AWS). Una clave KMS propia añade coste y gestión
# que no compensan en este proyecto.
#trivy:ignore:AWS-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "estado" {
  bucket = aws_s3_bucket.estado.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "estado" {
  bucket = aws_s3_bucket.estado.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
