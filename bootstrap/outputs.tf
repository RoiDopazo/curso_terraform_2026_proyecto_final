output "bucket_estado" {
  description = "Bucket del estado: ponlo en backend-aws.hcl o pásalo con -backend-config"
  value       = aws_s3_bucket.estado.bucket
}
