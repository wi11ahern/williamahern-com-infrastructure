resource "aws_ecs_cluster" "willahern_com_cluster" {
  name = "${var.project_name}-cluster-${var.env}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

resource "aws_ecs_task_definition" "frontend_task" {
  family = "frontend"
  container_definitions = file("task-definitions/frontend-task.json") 

  tags = local.common_tags
}

resource "aws_ecs_service" "frontend_service" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.willahern_com_cluster.name
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1

  tags = local.common_tags
}

resource "aws_iam_role" "ecs_for_ec2_role" {
  name = "${var.project_name}-ECS-for-EC2-Role"
  managed_policy_arns = [data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ecs_for_ec2_instance_profile" {
  name = "test_profile"
  role = aws_iam_role.ecs_for_ec2_role.name
}

resource "aws_security_group" "allow_https_sg" {
  name        = "Allow HTTPS"
  description = "Allow HTTPS traffic"

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "HTTPS"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_network_interface" "web_server_nit" {
  subnet_id = var.private_subnet_id 

  tags = local.common_tags
}

resource "aws_instance" "web_server" {
  ami           = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ecs_for_ec2_instance_profile.name
  security_groups = [aws_security_group.allow_https_sg.name]

  network_interface {
    network_interface_id = aws_network_interface.web_server_nit.id
    device_index         = 0
  }

  user_data            = <<EOF
#!/bin/bash
echo 'ECS_CLUSTER=${aws_ecs_cluster.willahern_com_cluster.name}' >> /etc/ecs/ecs.config
echo 'ECS_DISABLE_PRIVILEGED=true' >> /etc/ecs/ecs.config
EOF

  tags = local.common_tags
}
