data "aws_caller_identity" "current" {}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "src/handler.py"
  output_path = "ecr_cleaner_lambda.zip"
}