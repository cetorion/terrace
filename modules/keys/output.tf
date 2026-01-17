output "material" {
  value = {
    for k in var.keys : k.name =>
    trimspace(
      k.create ?
      aws_key_pair.this[k.name].public_key :
      data.aws_key_pair.this[k.name].public_key
    )
  }
}

output "name" {
  value = {
    for k in var.keys : k.name =>
    trimspace(
      k.create ?
      aws_key_pair.this[k.name].key_name :
      data.aws_key_pair.this[k.name].key_name
    )
  }
}

output "file" {
  value = {
    for k in var.keys : k.name =>
    base64encode(tls_private_key.this[k.name].private_key_openssh) if k.create
  }
}
