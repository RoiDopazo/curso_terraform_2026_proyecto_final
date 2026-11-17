# MEJORA OPCIONAL · Rol de AWS que GitHub Actions puede asumir con OIDC.
# Así el pipeline obtiene credenciales temporales y no hay claves guardadas en GitHub.
# Se aplica una vez, con tus credenciales, y con estado local.

terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

variable "repositorio" {
  description = "Repositorio de GitHub con el formato usuario/nombre"
  type        = string
}

# Proveedor de identidad: AWS confía en los tokens que emite GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# Solo los workflows de TU repositorio pueden asumir el rol
data "aws_iam_policy_document" "confianza" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.repositorio}:*"]
    }
  }
}

resource "aws_iam_role" "github" {
  name               = "github-actions-proyecto-final"
  assume_role_policy = data.aws_iam_policy_document.confianza.json
}

# Permisos para lo que despliega el proyecto. En un proyecto real, una política
# a medida con solo las acciones necesarias (mínimo privilegio).
resource "aws_iam_role_policy_attachment" "permisos" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ])

  role       = aws_iam_role.github.name
  policy_arn = each.value
}

output "rol_arn" {
  description = "Ponlo en la variable AWS_ROLE_ARN del repositorio de GitHub"
  value       = aws_iam_role.github.arn
}
