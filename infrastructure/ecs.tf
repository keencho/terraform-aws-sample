# ecr
resource "aws_ecr_repository" "ecr" {
  name = "${var.default_name}-ecr"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "${var.default_name}-ecr"
  }
}
