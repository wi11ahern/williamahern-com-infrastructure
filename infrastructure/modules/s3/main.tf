resource "aws_s3_bucket" "assets" {
  bucket = "${local.project_prefix}-assets"
  
  tags = local.common_tags
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.project_prefix}-logs"

  tags = local.common_tags
}