# Ejemplo de Uso del Módulo IAM Identity Center

Este directorio contiene un ejemplo funcional de cómo consumir el módulo de IAM Identity Center.

## Prerrequisitos

1. AWS CLI configurado con credenciales válidas
2. IAM Identity Center habilitado en la cuenta de gestión
3. Terraform >= 1.5.0

## Estructura del Ejemplo

```
sample/
├── README.md           # Este archivo
├── terraform.tfvars    # Configuración de ejemplo
├── variables.tf        # Definición de variables
├── data.tf             # Data sources (vacío en este caso)
├── locals.tf           # Transformaciones
├── main.tf             # Invocación del módulo padre
├── outputs.tf          # Outputs del ejemplo
└── providers.tf        # Configuración del provider
```

## Flujo de Datos (PC-IAC-026)

```
terraform.tfvars → variables.tf → locals.tf → main.tf → ../
```

## Ejecución

```bash
# Inicializar
terraform init

# Planificar
terraform plan -var-file="terraform.tfvars"

# Aplicar
terraform apply -var-file="terraform.tfvars"

# Destruir
terraform destroy -var-file="terraform.tfvars"
```

## Personalización

1. Edita `terraform.tfvars` con tus valores
2. Modifica las cuentas AWS en los assignments
3. Ajusta los permission sets según tus necesidades

## Notas

- Este ejemplo usa estado local (no S3) para simplicidad
- En producción, configura un backend S3 con cifrado
- Los IDs de cuenta son ejemplos, reemplázalos con los reales
