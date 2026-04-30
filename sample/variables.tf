# Variables del ejemplo (PC-IAC-002)
# La configuración de recursos se carga desde archivos JSON en data/

#############################################################################
# Variables de Gobernanza
#############################################################################

variable "client" {
  description = "Nombre del cliente para nomenclatura."
  type        = string
}

variable "project" {
  description = "Nombre del proyecto."
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue."
  type        = string
}

variable "region" {
  description = "Región AWS."
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos."
  type        = map(string)
  default     = {}
}

variable "profile" {
  description = "Profile AWS"
  default = {}
}