locals {
  userdata = data.ct_config.this.rendered
  ami_name = "fedora-coreos-${var.fcos_vers}*"
  build    = var.build == null ? random_id.this[0].hex : var.build
  subnet   = [for s in module.network.subnets : s.id if s.access == "public"][0]
  vpc      = module.network.vpc_id

  tags = {
    Owner       = var.owner
    ID          = var.id
    Environment = var.environment
    Build       = local.build
    Project     = var.project
  }
}

data "ct_config" "this" {
  content = templatefile("${path.module}/fcos.yaml",
    {
      hostname  = var.project,
      ssh_key   = var.ssh_key,
      time_zone = var.time_zone
    }
  )
  strict       = true
  pretty_print = false
}

data "aws_ami" "this" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [local.ami_name]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "random_id" "this" {
  count       = var.build == null ? 1 : 0
  byte_length = 4
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.this.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true
  key_name                    = var.key_name != "" ? var.key_name : null
  user_data                   = local.userdata

  tags = merge(
    local.tags,
    {
      Name = "${var.project}-ec2"
    }
  )
}

resource "aws_security_group" "this" {
  name        = "${var.project}-sg"
  description = "Allow SSH"
  vpc_id      = local.vpc

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "ALL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name = "${var.project}-sg"
    }
  )
}
