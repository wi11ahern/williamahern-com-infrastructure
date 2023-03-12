resource "aws_iam_role" "ecr_cleaner_role" {
  name = "${local.lambda_name}-Role"

  inline_policy {
    name = "ECR-Image-Processing"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ecr:BatchDeleteImage", "ecr:ListImages"]
          Effect   = "Allow"
          Resource = var.ecr_arn
        },
      ]
    })
  }

  inline_policy {
    name = "CloudWatch"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "logs:CreateLogGroup"
          Effect   = "Allow"
          Resource = "arn:aws:logs::${local.account_id}:*"
        },
        {
          Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
          Effect   = "Allow"
          Resource = "arn:aws:logs::${local.account_id}:log-group/aws/lambda/${local.lambda_name}:*"
        },
      ]
    })
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS     = "arn:aws:iam::927822646792:root"
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lambda_function" "ecr_cleaner_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda.output_path
  function_name = local.lambda_name
  role          = aws_iam_role.ecr_cleaner_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.9"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  tags = local.common_tags
}