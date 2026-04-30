# Variables de entrada del módulo (PC-IAC-002)

#############################################################################
# Variables de Gobernanza (Obligatorias - PC-IAC-002, PC-IAC-003)
#############################################################################

variable "client" {
  description = "Nombre del cliente o unidad de negocio para nomenclatura y tags."
  type        = string

  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 10
    error_message = "El cliente debe tener entre 1 y 10 caracteres."
  }
}

variable "project" {
  description = "Nombre del proyecto para nomenclatura y tags."
  type        = string

  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 15
    error_message = "El proyecto debe tener entre 1 y 15 caracteres."
  }
}

variable "environment" {
  description = "Ambiente por defecto (usado para tags). Los recursos usan su propio environment."
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod", "pdn", "stg", "uat"], var.environment)
    error_message = "El ambiente debe ser uno de: dev, qa, prod, pdn, stg, uat."
  }
}

variable "allowed_environments" {
  description = "Lista de ambientes permitidos para PS y grupos."
  type        = list(string)
  default     = ["dev", "qa", "prod", "pdn", "stg", "uat"]

  validation {
    condition     = length(var.allowed_environments) > 0
    error_message = "Debe haber al menos un ambiente permitido."
  }
}

#############################################################################
# Permission Sets Configuration (PC-IAC-002, PC-IAC-009)
#############################################################################

variable "permission_sets" {
  description = <<-EOT
    Mapa de Permission Sets a crear. Cada key es el identificador único del PS.
    Estructura:
    - environment: Ambiente del PS (dev, qa, prod, stg, uat, all) - OBLIGATORIO
    - description: Descripción del permission set
    - session_duration: Duración de la sesión (formato ISO 8601, ej: PT4H)
    - managed_policies: Lista de ARNs de políticas AWS managed
    - customer_managed_policies: Lista de políticas customer managed (name, path)
    - inline_policy: Política inline en formato JSON string (opcional)
    - permissions_boundary: ARN de la política de boundary (opcional)
    - tags: Tags adicionales para el permission set
  EOT
  type = map(object({
    environment      = string
    description      = string
    session_duration = optional(string, "PT1H")
    managed_policies = optional(list(string), [])
    customer_managed_policies = optional(list(object({
      name = string
      path = optional(string, "/")
    })), [])
    inline_policy        = optional(string, null)
    permissions_boundary = optional(string, null)
    relay_state          = optional(string, null)
    tags                 = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.permission_sets : length(k) > 0 && length(k) <= 32
    ])
    error_message = "Las keys de permission_sets deben tener entre 1 y 32 caracteres."
  }
}

#############################################################################
# Groups Configuration (PC-IAC-002, PC-IAC-009)
#############################################################################

variable "groups" {
  description = <<-EOT
    Mapa de grupos a crear en Identity Store. Cada key es el identificador único del grupo.
    Estructura:
    - environment: Ambiente del grupo (dev, qa, prod, stg, uat, all) - OBLIGATORIO
    - description: Descripción del grupo
    - assignments: Lista de asignaciones de permission sets a cuentas
      - permission_set: Key del permission set (debe existir en permission_sets)
      - accounts: Lista de IDs de cuentas AWS (12 dígitos)
  EOT
  type = map(object({
    environment = string
    description = string
    assignments = optional(list(object({
      permission_set = string
      accounts       = list(string)
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.groups : length(k) > 0 && length(k) <= 50
    ])
    error_message = "Las keys de groups deben tener entre 1 y 50 caracteres."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.groups : [
        for a in v.assignments : [
          for acc in a.accounts : can(regex("^[0-9]{12}$", acc))
        ]
      ]
    ]))
    error_message = "Los IDs de cuenta AWS deben tener exactamente 12 dígitos."
  }
}

#############################################################################
# Users Configuration (PC-IAC-002, PC-IAC-009)
#############################################################################

variable "users" {
  description = <<-EOT
    Mapa de usuarios a crear en Identity Store. Cada key es el username.
    Estructura:
    - given_name: Nombre del usuario
    - family_name: Apellido del usuario
    - email: Email del usuario (debe ser único)
    - display_name: Nombre para mostrar (opcional, se genera automáticamente)
    - groups: Lista de keys de grupos a los que pertenece
    - direct_assignments: Asignaciones directas de PS a cuentas (opcional)
  EOT
  type = map(object({
    given_name   = string
    family_name  = string
    email        = string
    display_name = optional(string, null)
    groups       = optional(list(string), [])
    direct_assignments = optional(list(object({
      permission_set = string
      accounts       = list(string)
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.users : length(k) > 0 && length(k) <= 128
    ])
    error_message = "Los usernames deben tener entre 1 y 128 caracteres."
  }

  validation {
    condition = alltrue([
      for k, v in var.users : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", v.email))
    ])
    error_message = "Los emails deben tener un formato válido."
  }
}
