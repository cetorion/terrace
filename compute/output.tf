output "instance_id" {
  value = [for i in aws_instance.this : i.id]
}

output "private_ip" {
  value = {
    for i in aws_instance.this : i.tags["Name"] => i.private_ip
  }
}

output "public_ip" {
  value = {
    for i in aws_instance.this : i.tags["Name"] => i.public_ip if lookup(i.tags, "Access") == "public"
  }
}

output "public_dns" {
  value = {
    for i in aws_instance.this : i.tags["Name"] => i.public_dns if lookup(i.tags, "Access") == "public"
  }
}

output "build_id" {
  value = local.build
}
