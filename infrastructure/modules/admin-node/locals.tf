locals {
  common_tags = {
    Environment = var.env
    Project     = var.project_name
  }
}