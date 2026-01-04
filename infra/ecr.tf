resource "aws_ecr_repository" "app" {
  name                 = "hello"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
}
