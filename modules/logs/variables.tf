variable "nombre" {
  description = "Nombre del bucket de logs (único en todo AWS)"
  type        = string
}

variable "dias_retencion" {
  description = "Días que se conservan los logs antes de borrarse"
  type        = number
  default     = 30
}
