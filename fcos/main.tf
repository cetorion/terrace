resource "random_id" "this" {
  count       = var.project.build == null ? 1 : 0
  byte_length = 4
}

locals {
  build   = upper(var.project.build == null ? random_id.this[0].hex : var.project.build)
  project = merge(var.project, { build = local.build })
  ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4S0CPM+4ChUzLN5XNWQMNf9nhaES9sokfWO/WOK5Dd openpgp:0xD1411499"
  group   = keys(var.compute)[0]
}

data "ct_config" "this" {
  content = templatefile("${path.module}/${local.group}.yaml",
    {
      user      = var.project.owner
      hostname  = "${var.project.name}-${local.group}-${local.build}"
      ssh_key   = local.ssh_key
      time_zone = var.time_zone
      ssh_port  = var.compute[local.group].ssh_port
    }
  )

  strict       = true
  pretty_print = false
}

locals {
  user_data = {
    (local.group) = { user_data = data.ct_config.this.rendered }
  }

  compute = {
    for k, v in var.compute :
    k => merge(
      v,
      lookup(local.user_data, k, {})
    )
  }
}

module "fcos" {
  source = "../compute"

  compute = local.compute
  ami_cfg = var.ami_cfg
  project = local.project
}
