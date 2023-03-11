resource "aws_ecr_repository" "willahern_com_ecr" {
  name                 = "${var.project_name}-ecr-${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.env
  }
}