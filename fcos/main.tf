locals {
  userdata = data.ct_config.this.rendered
  build    = var.project.build == null ? random_id.this[0].hex : var.project.build
  vpc_id   = module.network.vpc_id
  subnets  = module.network.subnets

  flat = flatten(
    [
      for c in var.compute : [
        for i in range(c.count == null || c.count == 0 ? 1 : c.count) : c
      ]
    ]
  )

  instances = [
    for c in local.flat : merge(
      c,
      {
        ami_id      = c.ami_id == null ? data.aws_ami.this[c.ami_name].id : c.ami_id
        subnet_id   = c.subnet_id == null ? local.subnets[c.access_type][0].id : c.subnet_id
        access_type = c.access_type == null ? "public" : c.access_type
        public_ip   = c.access_type != "private"
      }
    )
  ]

  tags = {
    Owner       = var.project.owner
    Environment = var.project.env
    Build       = local.build
    Project     = var.project.name
  }
}

data "aws_ami" "this" {
  for_each = var.ami_cfg

  most_recent = true
  owners      = [each.value.owner]

  filter {
    name   = "name"
    values = [each.value.name]
  }

  filter {
    name   = "architecture"
    values = [each.value.arch]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "ct_config" "this" {
  content = templatefile("${path.module}/fcos.yaml.tpl",
    {
      hostname  = var.project.name,
      ssh_keys  = var.ssh_keys,
      time_zone = var.time_zone
    }
  )
  strict       = true
  pretty_print = false
}

resource "random_id" "this" {
  count       = var.project.build == null ? 1 : 0
  byte_length = 4
}

resource "aws_instance" "this" {
  count = length(local.instances)

  ami                         = local.instances[count.index].ami_id
  instance_type               = local.instances[count.index].instance_type
  subnet_id                   = local.instances[count.index].subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = local.instances[count.index].public_ip
  key_name                    = local.instances[count.index].key_name
  user_data                   = local.userdata

  tags = merge(
    local.tags,
    {
      Name   = "${var.project.name}-compute-${count.index}"
      Access = local.instances[count.index].access_type
    }
  )
}

resource "aws_security_group" "this" {
  name        = "${var.project.name}-sg"
  description = "Allow SSH"
  vpc_id      = local.vpc_id

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
      Name = "${var.project.name}-sg"
    }
  )
}
