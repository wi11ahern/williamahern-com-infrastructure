resource "aws_s3_bucket" "willahern_com_assets" {
  bucket = "willahern-com-assets-${var.env}"

  tags = {
    Environment = var.env
  }
}