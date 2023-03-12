locals {
  account_id     = data.aws_caller_identity.current.account_id
  project_prefix = "${var.project_name}-${var.env}"
  lambda_name    = "${local.project_prefix}-ECR-Cleaner-Lambda"
  common_tags = {
    Environment = var.env
    Project     = var.project_name
  }
}