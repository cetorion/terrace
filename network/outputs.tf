output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnets" {
  value = { for k, s in aws_subnet.this : k => {
    id     = s.id
    cidr   = s.cidr_block
    az     = s.availability_zone
    Access = s.tags["Access"]
  } }
}
