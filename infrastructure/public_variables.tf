variable "default_name" {
  default = "sycho-test"
}

variable "az_suffix_number" {
  default = {
    a = 1
    c = 2
  }
}

# provider.tf 의 region에 ap-northeast-2를 지정했으므로 아래 데이터는 이를 참조한다.
data "aws_region" "current" { }

# ap-northeast-2 를 기준으로 a, b, c, d 4개의 zone이 있지만
# ax_suffix_number 변수에 선언된 키값인 a, c 존만 사용한다.
data "aws_availability_zone" "all" {
  for_each = toset([for zone in keys(var.az_suffix_number) : "${data.aws_region.current.name}${zone}"])

  name = each.key
}