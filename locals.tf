# Valores locales y transformaciones (PC-IAC-003, PC-IAC-012)

locals {
  #############################################################################
  # Gobernanza - Prefijo base (PC-IAC-003)
  #############################################################################
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # Instancia SSO
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  #############################################################################
  # Validaciones de referencias cruzadas (PC-IAC-002)
  #############################################################################

  # Grupos referenciados en usuarios que no existen
  invalid_user_groups = flatten([
    for user_key, user in var.users : [
      for group_key in user.groups : {
        user  = user_key
        group = group_key
      } if !contains(keys(var.groups), group_key)
    ]
  ])

  # PS referenciados en grupos que no existen
  invalid_group_ps = flatten([
    for group_key, group in var.groups : [
      for assignment in group.assignments : {
        group          = group_key
        permission_set = assignment.permission_set
      } if !contains(keys(var.permission_sets), assignment.permission_set)
    ]
  ])

  # PS referenciados en asignaciones directas de usuarios que no existen
  invalid_user_direct_ps = flatten([
    for user_key, user in var.users : [
      for assignment in user.direct_assignments : {
        user           = user_key
        permission_set = assignment.permission_set
      } if !contains(keys(var.permission_sets), assignment.permission_set)
    ]
  ])

  #############################################################################
  # Permission Sets - Configuración (PC-IAC-003, PC-IAC-012)
  # La key del JSON es el nombre completo del Permission Set
  #############################################################################
  permission_sets_config = {
    for key, config in var.permission_sets : key => merge(config, {
      name = key
    })
  }

  # Flatten para managed policies attachment (PC-IAC-012)
  ps_managed_policies_flat = flatten([
    for ps_key, ps_config in var.permission_sets : [
      for policy_arn in ps_config.managed_policies : {
        ps_key     = ps_key
        policy_arn = policy_arn
        unique_key = "${ps_key}-${md5(policy_arn)}"
      }
    ]
  ])

  ps_managed_policies_map = {
    for item in local.ps_managed_policies_flat : item.unique_key => item
  }

  # Flatten para customer managed policies attachment
  ps_customer_managed_policies_flat = flatten([
    for ps_key, ps_config in var.permission_sets : [
      for policy in ps_config.customer_managed_policies : {
        ps_key      = ps_key
        policy_name = policy.name
        policy_path = policy.path
        unique_key  = "${ps_key}-${policy.name}"
      }
    ]
  ])

  ps_customer_managed_policies_map = {
    for item in local.ps_customer_managed_policies_flat : item.unique_key => item
  }

  #############################################################################
  # Groups - Configuración (PC-IAC-003, PC-IAC-012)
  # La key del JSON es el nombre completo del grupo
  #############################################################################
  groups_config = {
    for key, config in var.groups : key => merge(config, {
      display_name = key
    })
  }

  # Flatten para group account assignments (PC-IAC-012)
  group_assignments_flat = flatten([
    for group_key, group_config in var.groups : [
      for assignment in group_config.assignments : [
        for account_id in assignment.accounts : {
          group_key      = group_key
          permission_set = assignment.permission_set
          account_id     = account_id
          unique_key     = "${group_key}-${assignment.permission_set}-${account_id}"
        }
      ]
    ]
  ])

  group_assignments_map = {
    for item in local.group_assignments_flat : item.unique_key => item
  }

  #############################################################################
  # Users - Construcción de configuración (PC-IAC-012)
  #############################################################################
  users_config = {
    for key, config in var.users : key => merge(config, {
      display_name = config.display_name != null ? config.display_name : "${config.given_name} ${config.family_name}"
    })
  }

  # Flatten para user group memberships (PC-IAC-012)
  user_group_memberships_flat = flatten([
    for user_key, user_config in var.users : [
      for group_key in user_config.groups : {
        user_key   = user_key
        group_key  = group_key
        unique_key = "${user_key}-${group_key}"
      }
    ]
  ])

  user_group_memberships_map = {
    for item in local.user_group_memberships_flat : item.unique_key => item
  }

  # Flatten para user direct assignments (PC-IAC-012)
  user_direct_assignments_flat = flatten([
    for user_key, user_config in var.users : [
      for assignment in user_config.direct_assignments : [
        for account_id in assignment.accounts : {
          user_key       = user_key
          permission_set = assignment.permission_set
          account_id     = account_id
          unique_key     = "${user_key}-${assignment.permission_set}-${account_id}"
        }
      ]
    ]
  ])

  user_direct_assignments_map = {
    for item in local.user_direct_assignments_flat : item.unique_key => item
  }
}
