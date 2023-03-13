resource "aws_ecs_cluster" "willahern_com_cluster" {
  name = "${local.project_prefix}-ECS-Cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

resource "aws_iam_role" "task_role" {
  name                = "${local.project_prefix}-ECS-Task-Role"
  managed_policy_arns = [data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_ecs_task_definition" "frontend_task" {
  family                = "frontend"
  requires_compatibilities = ["FARGATE"]
  cpu = 1024
  memory = 2048
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.task_role.arn
  container_definitions = file("container-definitions/frontend.json")

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = local.common_tags
}

resource "aws_ecs_service" "frontend_service" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.willahern_com_cluster.name
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type = "FARGATE"
  platform_version = "LATEST"
  desired_count   = 2

  network_configuration {
    subnets = var.public_subnet_ids
    assign_public_ip = true
    security_groups = [aws_security_group.allow_https_sg.id]
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "react"
    container_port   = 3000
  }

  tags = local.common_tags
}

resource "aws_security_group" "allow_https_sg" {
  name        = "${local.project_prefix}-ECS-SG"
  description = "Allow HTTPS traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
  }

  ingress {
    description = "All ICMP - IPv4"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}