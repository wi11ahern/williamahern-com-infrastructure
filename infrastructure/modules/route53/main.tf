resource "aws_route53_zone" "primary_public" {
  name = var.domain_name
}

resource "aws_route53_record" "alb_record" {
  zone_id         = aws_route53_zone.primary_public.zone_id
  allow_overwrite = true
  name            = "www.${var.domain_name}"
  type            = "CNAME"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}