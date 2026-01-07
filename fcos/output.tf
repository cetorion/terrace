output "instance_id" {
  value = [for i in aws_instance.this : i.id]
}

output "public_ip" {
  value = [for i in aws_instance.this : i.public_ip if lookup(i.tags, "Access") == "public"]
}

output "public_dns" {
  value = [for i in aws_instance.this : i.public_dns if lookup(i.tags, "Access") == "public"]
}

output "build_id" {
  value = local.build
}
