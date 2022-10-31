# vpc
resource "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Project = var.project_name,
    Name = "${var.default_name}_vpc"
  }
}

##########################################################

# public subnet 2a
resource "aws_subnet" "subnet_public_2a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "172.31.101.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.default_name}_subnet_public_2a"
  }
}

# public subnet 2c
resource "aws_subnet" "subnet_public_2c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "172.31.102.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.default_name}_subnet_public_2c"
  }
}

# private subnet 2a
resource "aws_subnet" "subnet_private_2a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "172.31.201.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.default_name}_subnet_private_2a"
  }
}

# private subnet 2c
resource "aws_subnet" "subnet_private_2c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "172.31.202.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.default_name}_subnet_private_2c"
  }
}

##########################################################

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.default_name}_igw"
  }
}

##########################################################

# nat gateway
resource "aws_eip" "ngw_eip_2a" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.default_name}_ngw_eip_2a"
  }
}

resource "aws_eip" "ngw_eip_2c" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.default_name}_ngw_eip_2c"
  }
}

# 주의! 서브넷 id에는 ngw가 위치할 서브넷의 id가 할당되어야 한다. (퍼블릭 서브넷에 위치해야 한다.)
# ngw는 생성하기까지 시간이 조금 오래 걸린다.
resource "aws_nat_gateway" "ngw_2a" {
  allocation_id = aws_eip.ngw_eip_2a.id
  subnet_id = aws_subnet.subnet_public_2a.id

  tags = {
    Name = "${var.default_name}_ngw_2a"
  }
}

resource "aws_nat_gateway" "ngw_2c" {
  allocation_id = aws_eip.ngw_eip_2c.id
  subnet_id = aws_subnet.subnet_public_2c.id

  tags = {
    Name = "${var.default_name}_ngw_2c"
  }
}

##########################################################

# public route table
resource "aws_default_route_table" "rt_public" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.default_name}_rt_public"
  }
}

resource "aws_route_table_association" "rta_public_2a" {
  route_table_id = aws_default_route_table.rt_public.id
  subnet_id = aws_subnet.subnet_public_2a.id
}

resource "aws_route_table_association" "rta_public_2c" {
  route_table_id = aws_default_route_table.rt_public.id
  subnet_id = aws_subnet.subnet_public_2c.id
}

# private route table
resource "aws_route_table" "rt_private_2a" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_2a.id
  }

  tags = {
    Name = "${var.default_name}_rt_private_2a"
  }
}

resource "aws_route_table" "rt_private_2c" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_2c.id
  }

  tags = {
    Name = "${var.default_name}_rt_private_2c"
  }
}

resource "aws_route_table_association" "rta_private_2a" {
  route_table_id = aws_route_table.rt_private_2a.id
  subnet_id = aws_subnet.subnet_private_2a.id
}

resource "aws_route_table_association" "rta_private_2c" {
  route_table_id = aws_route_table.rt_private_2c.id
  subnet_id = aws_subnet.subnet_private_2c.id
}

##########################################################

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
    Name = "${var.default_name}_network_acl"
  }
}