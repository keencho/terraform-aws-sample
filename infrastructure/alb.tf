# application load balancer
resource "aws_alb" "alb" {
  name                       = "${var.default_name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [for subnet in aws_subnet.subnet_public : subnet.id]
  #  enable_deletion_protection = true

  tags = {
    Name = "${var.default_name}-alb"
  }
}

# application load balancer security group
resource "aws_security_group" "alb_sg" {
  name   = "${var.default_name}-alb-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.default_name}-alb-sg"
  }
}

# application load balancer listener 80
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.arn
  }
}

# application load balancer 80 to 443
resource "aws_lb_listener" "http_forward" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# application load balancer target group
resource "aws_alb_target_group" "alb_target_group" {
  name = "${var.default_name}-alb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    enabled = true
    interval = 30
    path = "/"
    matcher = "200"
    healthy_threshold = 3
    unhealthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }
}