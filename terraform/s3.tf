resource "random_string" "bucket_suffix" {
  length  = 5
  upper   = false
  lower   = true
  numeric = true
  special = false
}
resource "aws_s3_bucket" "my_bucket" {
  bucket        = "sath-${random_string.bucket_suffix.id}"
  force_destroy = true
}
resource "aws_s3_bucket_public_access_block" "myaccess" {
  bucket = aws_s3_bucket.my_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_policy" "mypolicy" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.myaccess]
}