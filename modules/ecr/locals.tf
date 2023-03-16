locals {
  common_tags = {
    Environment = var.env
    Project     = var.project_name
  }
  project_prefix = "${var.project_name}-${var.env}"
}