resource "random_id" "this" {
  byte_length = 2
}

locals {
  name = "${var.project}-${var.purpose}"
  tags = {
    Owner       = var.owner
    ID          = var.id
    Environment = var.environment
    Build       = random_id.this.id
    Project     = var.project
    Purpose     = var.purpose
  }

}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = merge(
    local.tags,
    {
      Name = "${local.name}-vpc"
    }
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = data.aws_availability_zones.available.names
  subnets = [
    for i, s in var.subnets : merge({
      name      = "${local.name}-subnet-${i}"
      public_ip = s.access == "public"
      az        = lookup(s, "az", local.azs[0])
      access    = lookup(s, "access", "private")
    }, s)
  ]


  #create_cidr = alltrue([for s in var.subnets : coalesce(s.cidr, "x") == "x"])
  create_cidr = alltrue([for s in var.subnets : s.cidr == null])
  subnets2 = local.create_cidr ? [
    for i, s in var.subnets : merge(s, {
      cidr = cidrsubnet(var.vpc_cidr, 8, i + 1)
    })
  ] : var.subnets

  subnets_by_az = {
    for a in local.azs : a => {
      public  = [for s in local.subnets : s.name if s.access == "public"]
      private = [for s in local.subnets : s.name if s.access == "private"]
    }
  }

  subnet_access = distinct([for s in local.subnets : s.access])
}

resource "aws_subnet" "this" {
  for_each = { for s in local.subnets : s.name => s }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public_ip
  tags = merge(
    local.tags,
    {
      Name   = each.key
      Access = each.value.access
    }
  )
}

resource "aws_internet_gateway" "this" {
  count  = contains(local.subnet_access, "public") ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.tags,
    {
      Name = "${local.name}-igw"
    }
  )
}

resource "aws_route_table" "public" {
  count  = contains(local.subnet_access, "public") ? 1 : 0
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }
  tags = merge(
    local.tags,
    {
      Name = "${local.name}-public-rt"
    }
  )
}

resource "aws_route_table" "private" {
  count  = contains(local.subnet_access, "private") ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.tags,
    {
      Name = "${local.name}-private-rt"
    }
  )
}

resource "aws_route_table_association" "this" {
  for_each = aws_subnet.this

  subnet_id = each.value.id
  route_table_id = (
    lookup(each.value.tags, "Access") == "public"
    ? aws_route_table.public[0].id
    : aws_route_table.private[0].id
  )
}
