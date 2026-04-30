# Data sources del módulo (PC-IAC-011)
# Los Data Sources deben estar en el Root, no en el módulo de referencia
# Este módulo recibe los IDs necesarios como variables de entrada

# Excepción: Data source para obtener la instancia de SSO (intrínseco al servicio)
data "aws_ssoadmin_instances" "this" {
  provider = aws.project
}
