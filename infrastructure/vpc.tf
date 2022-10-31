resource "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Project = var.project_name,
    Name = "${var.default_name}_vpc"
  }
}