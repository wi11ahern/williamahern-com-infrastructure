locals {
  account_id     = data.aws_caller_identity.current.account_id
  project_prefix = "${var.project_name}-${var.env}"
  common_tags = {
    Environment = var.env
    Project     = var.project_name
  }
}