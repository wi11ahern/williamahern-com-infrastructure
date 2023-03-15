output "target_group_arn" {
  value = aws_lb_target_group.frontend_alb_tg.arn
}

output "alb_security_group_id" {
  value = aws_security_group.alb_traffic_sg.id
}

output "alb_dns_name" {
  value = aws_alb.frontend_alb.dns_name
}

output "alb_zone_id" {
  value = aws_alb.frontend_alb.zone_id
}