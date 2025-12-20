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
