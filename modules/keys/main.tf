locals {
  ssm_path = "/compute/keys/${var.name}"
}

resource "tls_private_key" "this" {
  count = var.create ? 1 : 0

  algorithm = var.algorithm
}

resource "local_sensitive_file" "this" {
  count = var.create ? 1 : 0

  content         = tls_private_key.this[0].private_key_openssh
  file_permission = "0400"
  filename        = "${pathexpand("~/.ssh")}/${var.name}.key"
}

resource "aws_ssm_parameter" "this" {
  count = var.create ? 1 : 0

  name        = local.ssm_path
  description = "Private key ${var.name}"
  type        = "SecureString"
  value       = tls_private_key.this[0].private_key_openssh
}

resource "aws_key_pair" "this" {
  count = var.create ? 1 : 0

  key_name   = var.name
  public_key = tls_private_key.this[0].public_key_openssh
}

data "aws_key_pair" "this" {
  count = var.create ? 0 : 1

  key_name           = var.name
  include_public_key = true
}
