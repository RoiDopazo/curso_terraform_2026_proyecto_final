variable "nombre" {
  description = "Prefijo de los nombres de los recursos"
  type        = string
}

variable "vpc_cidr" {
  description = "Rango de direcciones de la VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr debe ser un rango CIDR válido."
  }
}

variable "zonas" {
  description = "Zonas de disponibilidad: una subred pública por zona"
  type        = list(string)
}
