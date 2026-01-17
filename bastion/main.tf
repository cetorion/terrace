resource "random_id" "this" {
  count       = var.project.build == null ? 1 : 0
  byte_length = 4
}

locals {
  build    = upper(var.project.build == null ? random_id.this[0].hex : var.project.build)
  project  = merge(var.project, { build = local.build })
  group    = keys(var.compute)[0]
  key_name = values(var.compute)[0].key
}

data "ct_config" "this" {
  content = templatefile("${path.module}/${local.group}.yaml",
    {
      user     = var.project.owner
      hostname = "${local.group}-${local.build}"
      key      = module.keys.material[local.key_name]
      lock     = module.keys.file[local.group] # file("${pathexpand("~/.ssh")}/${local.name}.key")
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

module "keys" {
  source = "../modules/keys"

  keys = [
    {
      name   = local.group
      create = true
    },
    {
      name   = local.key_name
      create = false
    }
  ]
}

module "fcos" {
  #source = "git::ssh://git@github.com/cetorion/terrace.git//compute?ref=main"
  source = "../modules/compute"

  compute = local.compute
  amis    = var.amis
  project = local.project
}
