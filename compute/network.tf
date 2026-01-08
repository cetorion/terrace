module "network" {
  source = "../network"

  project = merge(
    var.project, { build = local.build }
  )

  subnets = [
    {
      access = "public"
    },
    {
      access = "private"
    }
  ]
}
