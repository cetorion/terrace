locals {
  build  = upper(var.project.build == null ? random_id.this[0].hex : var.project.build)
  vpc_id = data.aws_vpc.this.id
  subnets = {
    public = [data.aws_subnet.public]
  }

  flat = flatten(
    [
      for c in var.compute : [
        for i in range(c.count == null || c.count == 0 ? 1 : c.count) : c
      ]
    ]
  )

  instances = [
    for i, c in local.flat : merge(
      c,
      {
        ami_id    = c.ami_id == null ? data.aws_ami.this[c.ami_label].id : c.ami_id
        subnet_id = c.subnet_id == null ? local.subnets[c.access][0].id : c.subnet_id
        access    = c.access == null ? "public" : c.access
        public_ip = c.access != "private"
        name      = "${c.name == null ? var.project.name : c.name}-${local.build}-${i}"
      }
    )
  ]

  ports = { for i in local.instances : i.ssh_port => i.name }

  tags = {
    Owner       = var.project.owner
    Environment = var.project.env
    Build       = local.build
    Project     = var.project.name
  }
}

data "aws_vpc" "this" {
  tags = {
    Owner   = "nero"
    Project = "galaxy"
  }
}

data "aws_subnets" "public" {
  tags = {
    Owner   = "nero"
    Project = "galaxy"
    Access  = "public"
  }
}

data "aws_subnet" "public" {
  tags = {
    Owner   = "nero"
    Project = "galaxy"
    Access  = "public"
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
  count = length(local.instances)

  content = templatefile("${path.module}/fcos.yaml",
    {
      hostname  = local.instances[count.index].name,
      ssh_key   = lookup(var.ssh_keys, local.instances[count.index].access),
      time_zone = var.time_zone
      ssh_port  = local.instances[count.index].ssh_port
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

  ami           = local.instances[count.index].ami_id
  instance_type = local.instances[count.index].ins_type
  subnet_id     = local.instances[count.index].subnet_id
  vpc_security_group_ids = concat(
    [aws_security_group.this[local.instances[count.index].ssh_port].id],
    local.instances[count.index].sgs == null ? [] : local.instances[count.index].sgs
  )
  associate_public_ip_address = local.instances[count.index].public_ip
  key_name                    = local.instances[count.index].key_name
  user_data                   = data.ct_config.this[count.index].rendered

  tags = merge(
    local.tags,
    {
      Name   = local.instances[count.index].name
      Access = local.instances[count.index].access
    }
  )
}

resource "aws_security_group" "this" {
  for_each = local.ports

  name        = "${var.project.name}-sg"
  description = "Allow SSH"
  vpc_id      = local.vpc_id

  ingress {
    description = "Bastion"
    from_port   = each.key
    to_port     = each.key
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
