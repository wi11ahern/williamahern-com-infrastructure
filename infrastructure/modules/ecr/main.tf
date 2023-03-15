resource "aws_ecr_repository" "ecr_repository" {
  name                 = "${local.project_prefix}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}