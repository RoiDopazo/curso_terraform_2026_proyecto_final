output "urls" {
  description = "URL de cada servidor"
  value       = { for k, s in module.web : k => s.url }
}

# Añade un output "bucket_logs" con el output bucket del módulo logs
