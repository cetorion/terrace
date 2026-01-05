output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnets" {
  value = { for k, s in aws_subnet.this : k => {
    id     = s.id
    name   = s.name
    cidr   = s.cidr
    az     = s.availability_zone
    Access = s.tags["Access"]
  } }
}
