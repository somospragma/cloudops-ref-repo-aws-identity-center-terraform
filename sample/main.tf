# Invocación del módulo padre (PC-IAC-026)
# Este archivo SOLO contiene la invocación del módulo
# Las transformaciones están en locals.tf

############################################################################
# Invocación del Módulo Padre (IAM Identity Center)
############################################################################

module "iam_identity_center" {
  source = "../" # Apunta al directorio padre (el módulo de referencia)

  providers = {
    aws.project = aws.principal
  }

  # Variables obligatorias de gobernanza (PC-IAC-002)
  client      = var.client
  project     = var.project
  environment = var.environment

  # Permission Sets - Configuración transformada desde locals (PC-IAC-026)
  permission_sets = local.permission_sets_transformed

  # Groups - Configuración transformada desde locals (PC-IAC-026)
  groups = local.groups_transformed

  # Users - Configuración transformada desde locals (PC-IAC-026)
  users = local.users_transformed
}
