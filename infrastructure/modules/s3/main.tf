resource "aws_s3_bucket" "assets" {
  bucket = "${local.project_prefix}-assets"

  tags = local.common_tags
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.project_prefix}-logs"

  tags = local.common_tags
}

resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS": "arn:aws:iam::${var.elb_account_id}:root"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.logs.arn}/AWSLogs/*"
      }
    ]
  })
}