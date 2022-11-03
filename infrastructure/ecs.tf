# ecr
resource "aws_ecr_repository" "ecr" {
  name                 = "${var.default_name}-ecr"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "${var.default_name}-ecr"
  }
}

# ecs tasks security group
resource "aws_security_group" "ecs_task_sg" {
  name   = "${var.default_name}-ecs-task-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    # alb에서 80포트로 들어오는것을 허용한다.
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.default_name}-ecs-task-sg"
  }
}

# ecs task execution role
data "aws_iam_policy_document" "ecs_task_execution_policy" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ecs task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.default_name}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

# ecs task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ecs task definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "${var.default_name}-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512

  container_definitions = jsonencode([
    {
      name      = "${var.default_name}-task"
      image     = "${var.default_name}-task-image"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# ecs cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.default_name}-ecs-cluster"
}

# ecs service
resource "aws_ecs_service" "ecs_service" {
  name = "${var.default_name}-ecs-service"
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count = 0
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_task_sg.id]
    subnets = [for subnet in aws_subnet.subnet_public : subnet.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.alb-target-group.arn
    container_name = "${var.default_name}-task"
    container_port = 80
  }

  depends_on = [aws_alb_listener.alb-listener, aws_iam_role.ecs_task_execution_role]
}
