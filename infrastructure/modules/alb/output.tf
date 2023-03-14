output "target_group_arn" {
  value = aws_lb_target_group.frontend_alb_tg.arn
}

output "alb_security_group_id" {
  value = aws_security_group.alb_traffic_sg.id
}