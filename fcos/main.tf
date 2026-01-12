resource "random_id" "this" {
  count       = var.project.build == null ? 1 : 0
  byte_length = 4
}

locals {
  build   = upper(var.project.build == null ? random_id.this[0].hex : var.project.build)
  project = merge(var.project, { build = local.build })
  key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4S0CPM+4ChUzLN5XNWQMNf9nhaES9sokfWO/WOK5Dd openpgp:0xD1411499"
  group   = keys(var.compute)[0]
}

data "ct_config" "this" {
  content = templatefile("${path.module}/${local.group}.yaml",
    {
      user     = var.project.owner
      hostname = "${var.project.name}-${local.group}-${local.build}"
      key      = local.key
      zone     = var.zone
      port     = var.compute[local.group].port
    }
  )

  strict       = true
  pretty_print = false
}

locals {
  userdata = {
    (local.group) = { userdata = data.ct_config.this.rendered }
  }

  compute = {
    for k, v in var.compute :
    k => merge(
      v,
      lookup(local.userdata, k, {})
    )
  }
}

module "fcos" {
  source = "../compute"

  compute = local.compute
  amis    = var.amis
  project = local.project
}
