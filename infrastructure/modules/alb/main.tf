resource "aws_security_group" "alb_traffic_sg" {
  name        = "${local.project_prefix}-ALB-SG"
  description = "Allow traffic from the outside world."
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
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

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

resource "aws_alb" "frontend_alb" {
  name            = "${local.project_prefix}-ALB"
  internal        = false
  subnets         = var.subnet_ids
  security_groups = [aws_security_group.alb_traffic_sg.id]

  access_logs {
    bucket  = var.log_bucket_name
    enabled = true
  }

  tags = local.common_tags
}

resource "aws_lb_target_group" "frontend_alb_tg" {
  name        = "${local.project_prefix}-ALB-TG-${substr(uuid(), 0, 3)}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold = 3
    interval          = 10
    timeout           = 5
    path              = "/"
    port              = 80
    protocol          = "HTTP"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_alb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_alb_tg.arn
  }
}