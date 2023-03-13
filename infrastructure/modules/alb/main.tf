resource "aws_alb" "frontend_alb" {
  name               = "${local.project_prefix}-ALB"
  internal = false
  subnets = var.subnet_ids

  access_logs {
    bucket        = var.log_bucket_name
  }

  tags = local.common_tags
}

resource "aws_lb_target_group" "frontend_alb_tg" {
  name        = "${local.project_prefix}-ALB-TG"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_alb.frontend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_alb_tg.arn
  }
}