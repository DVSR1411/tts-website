resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
})
}
resource "aws_iam_policy" "s3_put_object_lambda_role" {
  name = "s3_put_object_lambda_role"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject"
        ],
        "Resource": [
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      }
    ]
})
}
resource "aws_iam_role_policy_attachment" "s3_put_object_lambda_role" {
  role   = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_put_object_lambda_role.arn
}
resource "aws_iam_role_policy_attachment" "basic_execution_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "polly_full_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPollyFullAccess"
}
