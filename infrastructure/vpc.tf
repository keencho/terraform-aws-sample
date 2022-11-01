# vpc
resource "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name = "${var.default_name}-vpc"
  }
}

locals {
  az_all_count = length(data.aws_availability_zone.all)
}

# public subnet
resource "aws_subnet" "subnet_public" {
  for_each = data.aws_availability_zone.all

  vpc_id = aws_vpc.vpc.id
  # 16 * suffix_num
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, var.az_suffix_number[each.value.name_suffix])
  availability_zone = each.key

  tags = {
    Name = "${var.default_name}-subnet-public-${each.value.name_suffix}"
  }
}

# private subnet
resource "aws_subnet" "subnet_private" {
  for_each = data.aws_availability_zone.all

  vpc_id = aws_vpc.vpc.id
  # 16 * (suffix_num + (suffix_count * 1))
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, var.az_suffix_number[each.value.name_suffix] + (local.az_all_count * 1))
  availability_zone = each.key

  tags = {
    Name = "${var.default_name}-subnet-private-${each.value.name_suffix}"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.default_name}-igw"
  }
}

# nat gateway
resource "aws_eip" "ngw_eip" {
  for_each = data.aws_availability_zone.all
  vpc      = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.default_name}-ngw-eip-${each.value.name_suffix}"
  }
}

# 주의! 서브넷 id에는 ngw가 위치할 서브넷의 id가 할당되어야 한다. (퍼블릭 서브넷에 위치해야 한다.)
# ngw는 생성하기까지 시간이 조금 오래 걸린다.
#resource "aws_nat_gateway" "ngw" {
#  for_each = data.aws_availability_zone.all
#
#  allocation_id = aws_eip.ngw_eip[each.key].id
#  subnet_id     = aws_subnet.subnet_public[each.key].id
#
#  tags = {
#    Name = "${var.default_name}-ngw-${each.value.name_suffix}"
#  }
#}

# public route table
resource "aws_default_route_table" "rt_public" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.default_name}-rt-public"
  }
}

# public route table association
resource "aws_route_table_association" "rta_public" {
  for_each = data.aws_availability_zone.all

  route_table_id = aws_default_route_table.rt_public.id
  subnet_id      = aws_subnet.subnet_public[each.key].id
}

# private route table
#resource "aws_route_table" "rt_private" {
#  for_each = data.aws_availability_zone.all
#
#  vpc_id = aws_vpc.vpc.id
#
#  route {
#    cidr_block     = "0.0.0.0/0"
#    nat_gateway_id = aws_nat_gateway.ngw[each.key].id
#  }
#
#  tags = {
#    Name = "${var.default_name}-rt-private-${each.value.name_suffix}"
#  }
#}

# private route table association
#resource "aws_route_table_association" "rta_private_2a" {
#  for_each = data.aws_availability_zone.all
#
#  route_table_id = aws_route_table.rt_private[each.key].id
#  subnet_id      = aws_subnet.subnet_private[each.key].id
#}

# network acl
resource "aws_default_network_acl" "vpc_network_acl" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.default_name}-network-acl"
  }
}
