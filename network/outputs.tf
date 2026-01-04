output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnets" {
  value = { for k, s in aws_subnet.this : k => {
    id                = s.id
    cidr_block        = s.cidr_block
    availability_zone = s.availability_zone
    Access            = s.tags["Access"]
  } }
}
