variable "default_name" {
  default = "keencho"
}

variable "az_suffix_number" {
  default = {
    a = 1
    c = 2
  }
}

data "aws_region" "current" {
  name = "ap-northeast-2"
}

data "aws_availability_zone" "all" {
  for_each = toset([for zone in keys(var.az_suffix_number) : "${data.aws_region.current.name}${zone}"])

  name = each.key
}