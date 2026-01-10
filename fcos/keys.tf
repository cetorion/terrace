locals {
  super_key = "super-key"
}

resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.this.private_key_pem
  file_permission = "0400"
  filename        = "${path.module}/${local.super_key}.pem"
}

resource "aws_key_pair" "example" {
  key_name   = local.super_key
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_ssm_parameter" "private_key" {
  name        = "/compute/keys/${local.super_key}"
  description = "Private key ${local.super_key}"
  type        = "SecureString"
  value       = tls_private_key.this.private_key_pem
}

###


# data "aws_ssm_parameter" "outbound_private_key" {
#   name            = "/ec2/keypair/internal-comms/private" # Key for outbound connections
#   with_decryption = true
# }

# resource "aws_instance" "ssh_client" {
#   # ... other config (VPC, subnet, IAM role with SSM:GetParameters access)
#   key_name = "access-key" # Separate inbound key for your admin access

#   provisioner "remote-exec" {
#     connection {
#       type = "ssh"
#       user = "ec2-user"
#       host = self.public_ip # Dynamic reference
#       private_key = (
#         aws_instance.ssh_client.key_name == "access-key" ?
#         data.aws_ssm_parameter.outbound_private_key.value :
#         null
#       ) # Use retrieved key
#     }

#     inline = [
#       "mkdir -p ~/.ssh",
#       "echo '${data.aws_ssm_parameter.outbound_private_key.value}' > ~/.ssh/id_rsa",
#       "chmod 600 ~/.ssh/id_rsa",
#       "ssh-keyscan -H <target-instance-ip-or-dns> >> ~/.ssh/known_hosts 2>/dev/null || true" # Pre-populate known_hosts
#     ]
#   }
# }
