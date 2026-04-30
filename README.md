# IAM Identity Center Governance Module

Módulo de Terraform para la gobernanza de AWS IAM Identity Center (SSO). Permite crear y gestionar usuarios, grupos, permission sets y sus asignaciones a cuentas AWS mediante configuración declarativa en JSON/HCL.

## Características

- ✅ Creación de usuarios en Identity Store
- ✅ Creación de grupos con asignaciones a cuentas
- ✅ Permission Sets con políticas managed, customer managed e inline
- ✅ Soporte para permissions boundary
- ✅ Membresías de usuarios a grupos
- ✅ Asignaciones directas de usuarios a cuentas (opcional)
- ✅ Tags personalizados en todos los recursos
- ✅ Nomenclatura estándar automática

## Uso

```hcl
module "iam_identity_center" {
  source = "git::https://github.com/org/iam-identity-center-module.git?ref=v1.0.0"

  providers = {
    aws.project = aws.principal
  }

  # Variables de gobernanza
  client      = "pragma"
  project     = "ecommerce"
  environment = "dev"

  # Permission Sets
  permission_sets = local.permission_sets_transformed

  # Groups
  groups = local.groups_transformed

  # Users
  users = local.users_transformed
}
```

## Inputs

| Nombre | Descripción | Tipo | Default | Requerido |
|--------|-------------|------|---------|-----------|
| client | Nombre del cliente para nomenclatura | `string` | - | ✅ |
| project | Nombre del proyecto | `string` | - | ✅ |
| environment | Ambiente (dev, qa, pdn) | `string` | - | ✅ |
| permission_sets | Mapa de Permission Sets a crear | `map(object)` | `{}` | No |
| groups | Mapa de grupos a crear | `map(object)` | `{}` | No |
| users | Mapa de usuarios a crear | `map(object)` | `{}` | No |

### Estructura de `permission_sets`

```hcl
permission_sets = {
  "admin" = {
    description      = "Acceso de administrador"
    session_duration = "PT4H"
    managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    customer_managed_policies = [
      { name = "CustomPolicy", path = "/" }
    ]
    inline_policy        = jsonencode({...})  # Opcional
    permissions_boundary = "arn:aws:iam::aws:policy/..."  # Opcional
    tags                 = { Team = "platform" }
  }
}
```

### Estructura de `groups`

```hcl
groups = {
  "admins" = {
    description = "Grupo de administradores"
    assignments = [
      {
        permission_set = "admin"  # Key del PS
        accounts       = ["111111111111", "222222222222"]
      }
    ]
  }
}
```

### Estructura de `users`

```hcl
users = {
  "juan.perez" = {
    given_name   = "Juan"
    family_name  = "Perez"
    email        = "juan.perez@empresa.com"
    groups       = ["admins", "developers"]
    direct_assignments = [  # Opcional
      {
        permission_set = "readonly"
        accounts       = ["333333333333"]
      }
    ]
  }
}
```

## Outputs

| Nombre | Descripción |
|--------|-------------|
| sso_instance_arn | ARN de la instancia SSO |
| identity_store_id | ID del Identity Store |
| permission_set_arns | Mapa de ARNs de Permission Sets |
| permission_set_ids | Mapa de IDs de Permission Sets |
| group_ids | Mapa de IDs de grupos |
| group_arns | Mapa de ARNs de grupos |
| user_ids | Mapa de IDs de usuarios |
| group_assignment_ids | IDs de asignaciones grupo-cuenta |
| user_assignment_ids | IDs de asignaciones usuario-cuenta |
| group_membership_ids | IDs de membresías usuario-grupo |

## Requisitos

| Nombre | Versión |
|--------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Cumplimiento PC-IAC

| Regla | Descripción | Implementación |
|-------|-------------|----------------|
| PC-IAC-001 | Estructura de módulo | ✅ 10 archivos raíz + 8 sample/ |
| PC-IAC-002 | Variables con validación | ✅ map(object) con validaciones |
| PC-IAC-003 | Nomenclatura estándar | ✅ `{client}-{project}-{env}-{type}-{key}` |
| PC-IAC-005 | Provider alias | ✅ `aws.project` obligatorio |
| PC-IAC-007 | Outputs granulares | ✅ Solo IDs y ARNs |
| PC-IAC-010 | for_each obligatorio | ✅ En todos los recursos |
| PC-IAC-012 | Estructuras en locals | ✅ Transformaciones centralizadas |
| PC-IAC-014 | Bloques dinámicos | ✅ Para políticas y asignaciones |
| PC-IAC-023 | Responsabilidad única | ✅ Solo recursos de Identity Center |
| PC-IAC-026 | Patrón sample/ | ✅ tfvars → locals → main |

## Decisiones de Diseño

### Separación de JSONs
Se recomienda usar archivos JSON separados para permission_sets, groups y users para:
- Gestión granular de permisos Git
- Menos conflictos en PRs
- Mayor claridad y mantenibilidad

### Nomenclatura Automática
El módulo construye automáticamente los nombres siguiendo el patrón:
- Permission Sets: `{client}-{project}-{env}-ps-{key}`
- Groups: `{client}-{project}-{env}-group-{key}`

### Asignaciones Directas de Usuarios
Aunque se soportan asignaciones directas de usuarios a cuentas, se recomienda usar grupos para:
- Mejor gestión y auditoría
- Facilidad de rotación de personal
- Principio de menor privilegio

## Ejemplo Completo

Ver el directorio `sample/` para un ejemplo funcional completo.

```bash
cd sample/
terraform init
terraform plan -var-file="terraform.tfvars"
```

## Licencia

MIT
