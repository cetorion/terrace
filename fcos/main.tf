locals {
  build   = upper(var.project.build == null ? random_id.this[0].hex : var.project.build)
  ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4S0CPM+4ChUzLN5XNWQMNf9nhaES9sokfWO/WOK5Dd openpgp:0xD1411499"
}

data "ct_config" "this" {
  content = templatefile("${path.module}/fcos.yaml",
    {
      user      = "super"
      hostname  = "fcos-${local.build}"
      ssh_key   = local.ssh_key
      time_zone = var.time_zone
      ssh_port  = var.compute.fcos.ssh_port
    }
  )

  strict       = true
  pretty_print = false
}

resource "random_id" "this" {
  count       = var.project.build == null ? 1 : 0
  byte_length = 4
}

module "fcos" {
  source = "../compute"

  compute = var.compute
  ami_cfg = var.ami_cfg
}
