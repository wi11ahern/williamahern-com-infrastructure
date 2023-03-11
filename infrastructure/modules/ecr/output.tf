output "ecr_arn" {
  value = aws_ecr_repository.willahern_com_ecr.arn
}

output "ecr_registry_id" {
  value = aws_ecr_repository.willahern_com_ecr.registry_id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.willahern_com_ecr.repository_url
}
