output "asset_bucket_arn" {
  value = aws_s3_bucket.assets.arn
}

output "asset_bucket_name" {
  value = aws_s3_bucket.assets.bucket
}

output "log_bucket_arn" {
  value = aws_s3_bucket.logs.arn
}

output "log_bucket_name" {
  value = aws_s3_bucket.logs.bucket
}