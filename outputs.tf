# Outputs del módulo (PC-IAC-007, PC-IAC-014)

#############################################################################
# SSO Instance Outputs
#############################################################################

output "sso_instance_arn" {
  description = "ARN de la instancia de IAM Identity Center."
  value       = local.sso_instance_arn
}

output "identity_store_id" {
  description = "ID del Identity Store asociado a la instancia SSO."
  value       = local.identity_store_id
}

#############################################################################
# Permission Sets Outputs (PC-IAC-007: granulares, PC-IAC-014: splat)
#############################################################################

output "permission_set_arns" {
  description = "Mapa de ARNs de los Permission Sets creados (key => ARN)."
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.arn }
}

output "permission_set_ids" {
  description = "Mapa de IDs de los Permission Sets creados (key => ID)."
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.id }
}

output "permission_set_names" {
  description = "Mapa de nombres de los Permission Sets creados (key => name)."
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.name }
}

#############################################################################
# Groups Outputs (PC-IAC-007: granulares)
#############################################################################

output "group_ids" {
  description = "Mapa de IDs de los grupos creados (key => group_id)."
  value       = { for k, v in aws_identitystore_group.this : k => v.group_id }
}

output "group_arns" {
  description = "Mapa de ARNs de los grupos creados (key => ARN)."
  value       = { for k, v in aws_identitystore_group.this : k => v.arn }
}

output "group_display_names" {
  description = "Mapa de nombres de display de los grupos (key => display_name)."
  value       = { for k, v in aws_identitystore_group.this : k => v.display_name }
}

#############################################################################
# Users Outputs (PC-IAC-007: granulares)
#############################################################################

output "user_ids" {
  description = "Mapa de IDs de los usuarios creados (username => user_id)."
  value       = { for k, v in aws_identitystore_user.this : k => v.user_id }
}

output "user_external_ids" {
  description = "Mapa de external IDs de los usuarios (username => external_ids)."
  value       = { for k, v in aws_identitystore_user.this : k => v.external_ids }
}

#############################################################################
# Assignments Outputs (PC-IAC-007: granulares)
#############################################################################

output "group_assignment_ids" {
  description = "Mapa de IDs de las asignaciones de grupos a cuentas."
  value       = { for k, v in aws_ssoadmin_account_assignment.group : k => v.id }
}

output "user_assignment_ids" {
  description = "Mapa de IDs de las asignaciones directas de usuarios a cuentas."
  value       = { for k, v in aws_ssoadmin_account_assignment.user : k => v.id }
}

output "group_membership_ids" {
  description = "Mapa de IDs de las membresías de usuarios en grupos."
  value       = { for k, v in aws_identitystore_group_membership.this : k => v.membership_id }
}
