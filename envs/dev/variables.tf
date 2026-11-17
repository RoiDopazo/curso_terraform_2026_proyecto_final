variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "eu-west-1"
}

variable "usar_floci" {
  description = "true para trabajar con Floci; false para usar AWS"
  type        = bool
  default     = false
}

variable "prefijo" {
  description = "Tu nombre y apellido en minúsculas y con guiones (ej.: ana-lopez)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.prefijo))
    error_message = "El prefijo solo admite minúsculas, números y guiones (entre 2 y 20 caracteres)."
  }
}

variable "ami_id" {
  description = "Déjalo vacío en AWS (se busca Ubuntu 24.04). Con Floci, indica una AMI de Floci."
  type        = string
  default     = null
}
