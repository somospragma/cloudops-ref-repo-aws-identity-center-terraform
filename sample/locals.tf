# Transformaciones del ejemplo (PC-IAC-009, PC-IAC-026)

locals {
  #############################################################################
  # Prefijo de Gobernanza (PC-IAC-025)
  #############################################################################
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  #############################################################################
  # Lectura de archivos JSON
  #############################################################################
  permission_sets_raw = jsondecode(file("${path.module}/data/permission_sets.json"))
  groups_raw          = jsondecode(file("${path.module}/data/groups.json"))
  users_raw           = jsondecode(file("${path.module}/data/users.json"))

  #############################################################################
  # Permission Sets - Transformación (PC-IAC-009, PC-IAC-026)
  # La key del JSON es el nombre completo del Permission Set
  #############################################################################
  permission_sets_transformed = {
    for key, config in local.permission_sets_raw : key => {
      description               = config.description
      session_duration          = try(config.session_duration, "PT1H")
      managed_policies          = try(config.managed_policies, [])
      customer_managed_policies = try(config.customer_managed_policies, [])
      relay_state               = try(config.relay_state, null)
      tags                      = try(config.tags, {})
      permissions_boundary      = try(config.permissions_boundary, null)

      # Cargar inline policy desde archivo si se especifica
      inline_policy = try(config.inline_policy_file, null) != null ? file("${path.module}/${config.inline_policy_file}") : null
    }
  }

  #############################################################################
  # Groups - Transformación (PC-IAC-026)
  # La key del JSON es el nombre completo del grupo
  #############################################################################
  groups_transformed = {
    for key, config in local.groups_raw : key => {
      description = config.description
      assignments = try(config.assignments, [])
    }
  }

  #############################################################################
  # Users - Transformación (PC-IAC-026)
  #############################################################################
  users_transformed = {
    for key, config in local.users_raw : key => {
      given_name         = config.given_name
      family_name        = config.family_name
      email              = config.email
      display_name       = try(config.display_name, null)
      groups             = try(config.groups, [])
      direct_assignments = try(config.direct_assignments, [])
    }
  }
}
