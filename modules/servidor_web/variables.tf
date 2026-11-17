variable "nombre" {
  description = "Nombre del servidor; también prefijo del grupo de seguridad"
  type        = string
}

variable "vpc_id" {
  description = "VPC donde se crea el grupo de seguridad"
  type        = string
}

variable "subred_id" {
  description = "Subred pública donde arranca la instancia"
  type        = string
}

variable "tipo_instancia" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "mensaje" {
  description = "Texto de la página web"
  type        = string
  default     = "Servidor creado con Terraform"
}

variable "puertos" {
  description = "Puertos TCP abiertos en la entrada"
  type        = list(number)
  default     = [80]
}

variable "origen_permitido" {
  description = "Rango CIDR desde el que se permite la entrada (0.0.0.0/0 = cualquiera)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ami_id" {
  description = "Déjalo vacío en AWS (se busca Ubuntu 24.04). Con Floci, indica una AMI de Floci."
  type        = string
  default     = null
}
