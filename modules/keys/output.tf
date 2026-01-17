output "material" {
  value = (
    trimspace(
      var.create ?
      aws_key_pair.this[0].public_key :
      data.aws_key_pair.this[0].public_key
    )
  )
}

output "name" {
  value = (
    trimspace(
      var.create ?
      aws_key_pair.this[0].key_name :
      data.aws_key_pair.this[0].key_name
    )
  )
}

output "file" {
  value = (
    var.create ?
    local_sensitive_file.this[0].filename :
    null
  )
}
