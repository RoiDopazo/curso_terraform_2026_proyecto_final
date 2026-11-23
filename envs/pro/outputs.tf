output "urls" {
  description = "URL de cada servidor"
  value       = { for k, s in module.web : k => s.url }
}

# Añade un output "bucket_logs" con el output bucket del módulo logs
output "bucket_logs" {
  description = "Bucket de logs de producción"
  value       = module.logs.bucket
}