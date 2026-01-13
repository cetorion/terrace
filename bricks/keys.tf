locals {
  key_name = "${var.project.name}-${local.build}"
  ssm_path = "/compute/keys/${local.key_name}"
  key_data = tls_private_key.this.public_key_openssh
}

resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "this" {
  key_name   = local.key_name
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_sensitive_file" "this" {
  content         = tls_private_key.this.private_key_openssh
  file_permission = "0400"
  filename        = "${pathexpand("~/.ssh")}/${local.key_name}.key"
}

resource "aws_ssm_parameter" "this" {
  name        = local.ssm_path
  description = "Private key ${local.key_name}"
  type        = "SecureString"
  value       = tls_private_key.this.private_key_openssh
}
