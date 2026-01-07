locals {
  build = var.project.build == null ? random_id.this.id : var.project.build
  azs   = data.aws_availability_zones.available.names

  tags = {
    Owner       = var.project.owner
    Environment = var.project.env
    Build       = local.build
    Project     = var.project.name
  }

  flat = flatten(
    [
      for s in var.subnets : [
        for c in range(s.count == null || s.count == 0 ? 1 : s.count) : s
      ]
    ]
  )

  config = [
    for i, s in local.flat : merge(s, {
      name      = "${var.project.name}-subnet-${lookup(s, "access", "public")}-${i}"
      public_ip = s.access == "public"
      az        = lookup(s, "az", local.azs[0])
      access    = lookup(s, "access", "public")
      cidr      = s.cidr == null ? cidrsubnet(var.vpc_cidr, 8, i) : s.cidr
    })
  ]

  subnets = {
    public  = [for s in local.config : s if s.access == "public"]
    private = [for s in local.config : s if s.access == "private"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_id" "this" {
  byte_length = 4
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.dns_hostnames
  enable_dns_support   = var.dns_support
  tags = merge(
    local.tags,
    {
      Name = "${var.project.name}-vpc"
    }
  )
}

resource "aws_subnet" "public" {
  count = length(local.subnets.public)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.subnets.public[count.index].cidr
  availability_zone       = local.subnets.public[count.index].az
  map_public_ip_on_launch = local.subnets.public[count.index].public_ip
  tags = merge(
    local.tags,
    {
      Name   = local.subnets.public[count.index].name
      Access = local.subnets.public[count.index].access
    }
  )
}

resource "aws_subnet" "private" {
  count = length(local.subnets.private)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.subnets.private[count.index].cidr
  availability_zone       = local.subnets.private[count.index].az
  map_public_ip_on_launch = local.subnets.private[count.index].public_ip
  tags = merge(
    local.tags,
    {
      Name   = local.subnets.private[count.index].name
      Access = local.subnets.private[count.index].access
    }
  )
}

resource "aws_internet_gateway" "this" {
  count  = length(local.subnets.public) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.tags,
    {
      Name = "${var.project.name}-igw-${count.index}"
    }
  )
}

resource "aws_route_table" "public" {
  count  = length(local.subnets.public) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.tags,
    {
      Name   = "${var.project.name}-rt-public-${count.index}"
      Access = "public"
    }
  )
}

resource "aws_route" "public" {
  count                  = length(local.subnets.public) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  count          = length(local.subnets.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_eip" "this" {
  count      = length(local.subnets.public) > 0 ? 1 : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
  tags = merge(
    local.tags,
    {
      Name = "${var.project.name}-eip-${count.index}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  count         = length(local.subnets.public) > 0 ? 1 : 0
  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.this]
  tags = merge(
    local.tags,
    {
      Name = "${var.project.name}-ngw-${count.index}"
    }
  )
}

resource "aws_route_table" "private" {
  count  = length(local.subnets.private) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.tags,
    {
      Name   = "${var.project.name}-rt-private-${count.index}"
      Access = "private"
    }
  )
}

resource "aws_route" "private" {
  count                  = length(local.subnets.private) > 0 ? 1 : 0
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  count          = length(local.subnets.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}
