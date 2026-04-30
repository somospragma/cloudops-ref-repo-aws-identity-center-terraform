# Recursos principales del módulo (PC-IAC-010, PC-IAC-014, PC-IAC-020)

#############################################################################
# Permission Sets (PC-IAC-010: for_each obligatorio)
#############################################################################

resource "aws_ssoadmin_permission_set" "this" {
  provider = aws.project

  for_each = local.permission_sets_config

  name             = each.value.name
  description      = each.value.description
  instance_arn     = local.sso_instance_arn
  session_duration = each.value.session_duration
  relay_state      = each.value.relay_state

  tags = merge(
    { Name = each.value.name },
    each.value.tags
  )

  # Validación: PS referenciados en grupos y usuarios deben existir (PC-IAC-002)
  lifecycle {
    precondition {
      condition     = length(local.invalid_group_ps) == 0
      error_message = <<-EOT
        Error de validación: Los siguientes Permission Sets referenciados en grupos no existen:
        ${join("\n", [for item in local.invalid_group_ps : "  - Grupo '${item.group}' referencia PS '${item.permission_set}' que no existe"])}
        
        Verifica que los permission_sets estén definidos en el JSON antes de referenciarlos en grupos.
      EOT
    }

    precondition {
      condition     = length(local.invalid_user_direct_ps) == 0
      error_message = <<-EOT
        Error de validación: Los siguientes Permission Sets en asignaciones directas de usuarios no existen:
        ${join("\n", [for item in local.invalid_user_direct_ps : "  - Usuario '${item.user}' referencia PS '${item.permission_set}' que no existe"])}
        
        Verifica que los permission_sets estén definidos en el JSON antes de usarlos en direct_assignments.
      EOT
    }
  }
}

# Managed Policy Attachments (PC-IAC-010)
resource "aws_ssoadmin_managed_policy_attachment" "this" {
  provider = aws.project

  for_each = local.ps_managed_policies_map

  instance_arn       = local.sso_instance_arn
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps_key].arn
}

# Customer Managed Policy Attachments (PC-IAC-010)
resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  provider = aws.project

  for_each = local.ps_customer_managed_policies_map

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps_key].arn

  customer_managed_policy_reference {
    name = each.value.policy_name
    path = each.value.policy_path
  }
}

# Inline Policy Attachments (PC-IAC-010)
resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  provider = aws.project

  for_each = {
    for k, v in local.permission_sets_config : k => v
    if v.inline_policy != null
  }

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  inline_policy      = each.value.inline_policy
}

# Permissions Boundary Attachments (PC-IAC-010)
resource "aws_ssoadmin_permissions_boundary_attachment" "this" {
  provider = aws.project

  for_each = {
    for k, v in local.permission_sets_config : k => v
    if v.permissions_boundary != null
  }

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn

  permissions_boundary {
    managed_policy_arn = each.value.permissions_boundary
  }
}

#############################################################################
# Groups (PC-IAC-010: for_each obligatorio)
#############################################################################

resource "aws_identitystore_group" "this" {
  provider = aws.project

  for_each = local.groups_config

  identity_store_id = local.identity_store_id
  display_name      = each.value.display_name
  description       = each.value.description

  # Validación: Grupos referenciados en usuarios deben existir (PC-IAC-002)
  lifecycle {
    precondition {
      condition     = length(local.invalid_user_groups) == 0
      error_message = <<-EOT
        Error de validación: Los siguientes grupos referenciados en usuarios no existen:
        ${join("\n", [for item in local.invalid_user_groups : "  - Usuario '${item.user}' referencia grupo '${item.group}' que no existe"])}
        
        Verifica que los grupos estén definidos en el JSON antes de asignarlos a usuarios.
      EOT
    }
  }
}

# Group Account Assignments (PC-IAC-010)
resource "aws_ssoadmin_account_assignment" "group" {
  provider = aws.project

  for_each = local.group_assignments_map

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn

  principal_id   = aws_identitystore_group.this[each.value.group_key].group_id
  principal_type = "GROUP"

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}

#############################################################################
# Users (PC-IAC-010: for_each obligatorio)
#############################################################################

resource "aws_identitystore_user" "this" {
  provider = aws.project

  for_each = local.users_config

  identity_store_id = local.identity_store_id
  user_name         = each.key
  display_name      = each.value.display_name

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    value   = each.value.email
    primary = true
  }
}

# User Group Memberships (PC-IAC-010)
resource "aws_identitystore_group_membership" "this" {
  provider = aws.project

  for_each = local.user_group_memberships_map

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.this[each.value.group_key].group_id
  member_id         = aws_identitystore_user.this[each.value.user_key].user_id
}

# User Direct Account Assignments (PC-IAC-010)
resource "aws_ssoadmin_account_assignment" "user" {
  provider = aws.project

  for_each = local.user_direct_assignments_map

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn

  principal_id   = aws_identitystore_user.this[each.value.user_key].user_id
  principal_type = "USER"

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}
