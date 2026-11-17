output "urls" {
  description = "URL de cada servidor"
  value       = { for k, s in module.web : k => s.url }
}
