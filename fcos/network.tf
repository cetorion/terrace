module "network" {
  source = "../network"

  owner       = var.owner
  id          = var.id
  project     = var.project
  environment = var.environment
  build       = local.build
  subnets = [
    {
      access = "public"
    }
  ]
}
