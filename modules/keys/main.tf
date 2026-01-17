locals {
  ssm_path = "/compute/keys"
  keys = {
    get = { for k in var.keys : k.name => k.create if !k.create }
    put = { for k in var.keys : k.name => k.create if k.create }
  }
}

resource "tls_private_key" "this" {
  for_each = local.keys.put

  algorithm = var.algorithm
}

resource "local_sensitive_file" "this" {
  for_each = local.keys.put

  content         = tls_private_key.this[each.key].private_key_openssh
  file_permission = "0400"
  filename        = "${pathexpand("~/.ssh")}/${each.key}.key"
}

resource "aws_ssm_parameter" "this" {
  for_each = local.keys.put

  name        = "${local.ssm_path}/${each.key}"
  description = "Private key ${each.key}"
  type        = "SecureString"
  value       = tls_private_key.this[each.key].private_key_openssh
}

resource "aws_key_pair" "this" {
  for_each = local.keys.put

  key_name   = each.key
  public_key = tls_private_key.this[each.key].public_key_openssh
}

data "aws_key_pair" "this" {
  for_each = local.keys.get

  key_name           = each.key
  include_public_key = true
}
