data "aws_region" "current" {}
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda.py"
  output_path = "${path.module}/../lambda.zip"
}
resource "aws_lambda_function" "test_lambda" {
  function_name    = "test"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 5
  environment {
    variables = {
      my_bucket = aws_s3_bucket.my_bucket.id
      region = data.aws_region.current.name
    }
  }
}