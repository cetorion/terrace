output "instance_id" {
  value = module.fcos.instances
}

output "private_ip" {
  value = module.fcos.private_ips
}

output "public_ip" {
  value = module.fcos.public_ips
}

output "build_id" {
  value = local.build
}
