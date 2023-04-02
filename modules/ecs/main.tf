resource "aws_ecs_cluster" "cluster" {
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

  inline_policy {
    name = "CloudWatch"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "logs:CreateLogGroup"
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:${local.account_id}:*"
        }
      ]
    })
  }

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
  family                   = "frontend"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.task_role.arn
  container_definitions = jsonencode([
    {
      "name" : "react",
      "image" : "${var.ecr_repository_url}:latest",
      "essential" : true,
      "cpu" : 50,
      "memory" : 1024,
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "frontend-logs",
          "awslogs-region" : "us-east-1",
          "awslogs-create-group" : "true",
          "awslogs-stream-prefix" : "frontend"
        }
      }
    }
    ]
  )

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = local.common_tags
}

resource "aws_security_group" "allow_alb_traffic_sg" {
  name   = "${local.project_prefix}-ECS-SG"
  vpc_id = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group_rule" "alb_to_ecr_sg_rule" {
  description              = "Allow all traffic from the ALB"
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = -1
  source_security_group_id = var.alb_security_group_id
  security_group_id        = aws_security_group.allow_alb_traffic_sg.id
}

resource "aws_ecs_service" "frontend_service" {
  name             = "frontend"
  cluster          = aws_ecs_cluster.cluster.name
  task_definition  = aws_ecs_task_definition.frontend_task.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = var.task_instance_count

  network_configuration {
    subnets          = var.public_subnet_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.allow_alb_traffic_sg.id]
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "react"
    container_port   = 80
  }

  tags = local.common_tags
}

# Monitoring
resource "aws_cloudwatch_metric_alarm" "running_task_count_alarm" {
  alarm_name                = "${local.project_prefix}-ECS-Running-Task-Count"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 2
  metric_name               = "RunningTaskCount"
  namespace                 = "ECS/ContainerInsights"
  dimensions                = {
    ClusterName = aws_ecs_cluster.cluster.name
    ServiceName = aws_ecs_service.frontend_service.name
  } 
  period                    = 120
  datapoints_to_alarm       = 1 
  threshold                 = 1
  statistic                 = "Average"
  alarm_description         = "This alarm monitors that there is at least 1 running task in the ${local.project_prefix} ECS cluster."
}