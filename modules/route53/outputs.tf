output "certificate_arn" {
  value = aws_acm_certificate_validation.cert_validation.certificate_arn
}

output "public_zone_id" {
  value = aws_route53_zone.primary_public.zone_id
}