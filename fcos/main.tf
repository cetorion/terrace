resource "random_id" "this" {
  byte_length = 8
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

locals {
  userdata = data.ct_config.this.rendered
  ami_name = "fedora-coreos-${var.fcos_vers}*"

  tags = {
    Owner       = "Nero Dicentra"
    Environment = var.environment
    Build       = random_id.this.id
  }
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

resource "aws_instance" "this" {
  ami                         = data.aws_ami.this.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.this.id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true
  key_name                    = var.key_name != "" ? var.key_name : null

  tags      = merge(local.tags, { Name = "${var.project}-ec2" })
  user_data = local.userdata
}

resource "aws_security_group" "this" {
  name        = "${var.project}-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.this.id

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

  tags = merge(local.tags, { Name = "${var.project}-sg" })
}
