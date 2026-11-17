output "bucket" {
  description = "Nombre del bucket de logs"
  value       = aws_s3_bucket.logs.bucket
}
