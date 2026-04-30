# Outputs del ejemplo (PC-IAC-007)

output "sso_instance_arn" {
  description = "ARN de la instancia SSO."
  value       = module.iam_identity_center.sso_instance_arn
}

output "identity_store_id" {
  description = "ID del Identity Store."
  value       = module.iam_identity_center.identity_store_id
}

output "permission_set_arns" {
  description = "ARNs de los Permission Sets creados."
  value       = module.iam_identity_center.permission_set_arns
}

output "permission_set_names" {
  description = "Nombres de los Permission Sets creados."
  value       = module.iam_identity_center.permission_set_names
}

output "group_ids" {
  description = "IDs de los grupos creados."
  value       = module.iam_identity_center.group_ids
}

output "group_display_names" {
  description = "Nombres de display de los grupos."
  value       = module.iam_identity_center.group_display_names
}

output "user_ids" {
  description = "IDs de los usuarios creados."
  value       = module.iam_identity_center.user_ids
}

output "group_assignment_ids" {
  description = "IDs de las asignaciones grupo-cuenta."
  value       = module.iam_identity_center.group_assignment_ids
}

output "group_membership_ids" {
  description = "IDs de las membresías usuario-grupo."
  value       = module.iam_identity_center.group_membership_ids
}
