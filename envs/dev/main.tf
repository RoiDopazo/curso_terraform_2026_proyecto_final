# ENTORNO DEV · Su configuración vive en este directorio (no en un .tfvars)

locals {
  entorno     = "dev"
  nombre_base = "${var.prefijo}-${local.entorno}"
  zonas       = ["eu-west-1a"]

  servidores = {
    a = { mensaje = "Desarrollo · servidor A" }
  }

  # Reparte los servidores entre las subredes
  subred_de = { for i, k in keys(local.servidores) : k => i % length(local.zonas) }
}

module "red" {
  source = "../../modules/red"

  nombre   = local.nombre_base
  vpc_cidr = "10.0.0.0/16"
  zonas    = local.zonas
}

module "web" {
  source   = "../../modules/servidor_web"
  for_each = local.servidores

  nombre    = "${local.nombre_base}-${each.key}"
  vpc_id    = module.red.vpc_id
  subred_id = module.red.subred_publica_ids[local.subred_de[each.key]]
  mensaje   = each.value.mensaje
  ami_id    = var.ami_id

  depends_on = [module.red]
}
