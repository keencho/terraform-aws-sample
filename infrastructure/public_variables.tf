variable "default_name" {
  default = "keencho"
}

variable "az_number" {
  default = {
    a = 1
    c = 2
  }
}

variable "az_suffix" {
  default = ["a", "c"]
}

data "aws_region" "current" {
  name = "ap-northeast-2"
}

data "aws_availability_zone" "all" {
  for_each = toset([for zone in var.az_suffix : "${data.aws_region.current.name}${zone}"])

  name = each.key
}