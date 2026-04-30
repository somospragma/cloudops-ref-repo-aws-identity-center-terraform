# Configuración de providers para el ejemplo (PC-IAC-005)

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  alias  = "principal"
  region = var.region
  profile = var.profile

  default_tags {
    tags = var.common_tags
  }
}
