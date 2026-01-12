locals {
  ssh_key_name = "${var.project.name}-${local.build}"
  ssm_key      = "/compute/keys/${local.ssh_key_name}"
}

resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "this" {
  content         = tls_private_key.this.private_key_openssh
  file_permission = "0400"
  filename        = "${pathexpand("~/.ssh")}/${local.ssh_key_name}.key"
}

resource "aws_key_pair" "this" {
  key_name   = local.ssh_key_name
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_ssm_parameter" "this" {
  name        = local.ssm_key
  description = "Private key ${local.ssh_key_name}"
  type        = "SecureString"
  value       = tls_private_key.this.private_key_openssh
}
