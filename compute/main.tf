locals {
  build = upper(var.project.build == null ? random_id.this[0].hex : var.project.build)

  subnets = {
    for k, v in var.compute : k => v.access if v.subnet == null
  }

  ins = flatten([
    for n, c in var.compute : [
      for i in range(c.count == null ? 1 : c.count) : merge(c,
        {
          ami    = c.ami == null ? data.aws_ami.this[n].id : c.ami
          subnet = c.subnet == null ? data.aws_subnet.this[n].id : c.subnet
          ip     = c.access != "private"
          name   = "${var.project.name}-${n}-${local.build}"
          port   = c.port == null ? 22 : c.port
          group  = n
        }
      )
    ]
  ])


  ports = { for i in local.ins : i.group => i.port }

  tags = {
    Owner       = var.project.owner
    Environment = var.project.env
    Build       = local.build
    Project     = var.project.name
  }
}

data "aws_subnet" "this" {
  for_each = local.subnets

  tags = {
    Owner   = var.project.owner
    Project = "galaxy"
    Access  = each.value
  }
}

data "aws_ami" "this" {
  for_each = var.amis

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

resource "random_id" "this" {
  count       = var.project.build == null ? 1 : 0
  byte_length = 4
}

resource "aws_instance" "this" {
  count = length(local.ins)

  ami           = local.ins[count.index].ami
  instance_type = local.ins[count.index].type
  subnet_id     = local.ins[count.index].subnet
  vpc_security_group_ids = concat(
    [aws_security_group.this[local.ins[count.index].group].id],
    local.ins[count.index].sgs == null ? [] : local.ins[count.index].sgs
  )
  associate_public_ip_address = local.ins[count.index].ip
  key_name                    = local.ins[count.index].key
  user_data                   = local.ins[count.index].userdata

  tags = merge(
    local.tags,
    {
      Name   = "${local.ins[count.index].name}-${count.index}"
      Access = local.ins[count.index].access
    }
  )
}

resource "aws_security_group" "this" {
  for_each = local.ports

  name        = "${var.project.name}-${each.key}-${local.build}"
  description = "Allow SSH"
  vpc_id      = data.aws_subnet.this[each.key].vpc_id

  ingress {
    description = "Bastion"
    from_port   = each.value
    to_port     = each.value
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
      Name = "${var.project.name}-${each.key}-${local.build}"
    }
  )
}
