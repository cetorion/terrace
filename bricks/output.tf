output "instances" {
  value = module.compute.instances
}

output "private" {
  value = module.compute.private_ips
}

output "public" {
  value = module.compute.public_ips
}

output "build" {
  value = local.build
}
