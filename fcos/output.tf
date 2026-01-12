output "instances" {
  value = module.fcos.instances
}

output "private" {
  value = module.fcos.private_ips
}

output "public" {
  value = module.fcos.public_ips
}

output "build" {
  value = local.build
}
