output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnets" {
  value = {
    public = [
      for s in aws_subnet.public : {
        name   = s.tags["Name"]
        id     = s.id
        cidr   = s.cidr_block
        az     = s.availability_zone
        access = s.tags["Access"]
      }
    ]
    private = [
      for s in aws_subnet.private : {
        name   = s.tags["Name"]
        id     = s.id
        cidr   = s.cidr_block
        az     = s.availability_zone
        access = s.tags["Access"]
      }
    ]
  }
}
