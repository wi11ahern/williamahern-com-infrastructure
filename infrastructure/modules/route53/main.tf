resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  subject_alternative_names = [ "www.${var.domain_name}", "*.${var.domain_name}" ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

resource "aws_route53_zone" "primary_public" {
  name = var.domain_name
}

resource "aws_route53_record" "dvo_records" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = aws_route53_zone.primary_public.zone_id
    } 
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = each.value.zone_id
  ttl             = 60

}

resource "aws_route53_record" "alb_record" {
  allow_overwrite = true
  name            = "www.${var.domain_name}"
  type            = "CNAME"
  zone_id         = aws_route53_zone.primary_public.zone_id

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn  = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.dvo_records : record.fqdn]
}