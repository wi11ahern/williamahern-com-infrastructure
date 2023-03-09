resource "aws_s3_bucket" "willahern_com_assets" {
  bucket = "willahern-com-assets-${var.environment_name}"

  tags = {
    Environment = var.environment_name
  }
}