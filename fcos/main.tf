resource "random_id" "this" {
  count       = var.project.build == null ? 1 : 0
  byte_length = 4
}

locals {
  build   = upper(var.project.build == null ? random_id.this[0].hex : var.project.build)
  project = merge(var.project, { build = local.build })
  group   = keys(var.compute)[0]
}

data "ct_config" "this" {
  content = templatefile("${path.module}/${local.group}.yaml",
    {
      user     = var.project.owner
      hostname = "${var.project.name}-${local.group}-${local.build}"
      key      = tls_private_key.this.public_key_openssh
      zone     = var.zone
      port     = var.compute[local.group].port
    }
  )

  strict       = true
  pretty_print = false
}

locals {
  userdata = {
    (local.group) = {
      userdata = data.ct_config.this.rendered
      key      = local.key_name
    }
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
  source = "git::ssh://git@github.com/cetorion/terrace.git//compute?ref=main"

  compute = local.compute
  amis    = var.amis
  project = local.project
}
