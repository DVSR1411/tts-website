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
  bucket                  = aws_s3_bucket.my_bucket.id
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
        Sid = "Stmt1746775574906"
        Effect = "Allow"
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
resource "aws_s3_object" "frontend_files" {
  for_each = fileset("${path.module}/../frontend", "**/*")
  bucket = aws_s3_bucket.my_bucket.id
  key    = each.value
  source = "${path.module}/../frontend/${each.value}"
  etag   = filemd5("${path.module}/../frontend/${each.value}")
  content_type = lookup({
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
  }, lower(trimspace(regex("\\.([^.]*)$", each.value)[0])), "application/octet-stream")
  depends_on = [null_resource.update_api]
}
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.my_bucket.id
  index_document {
    suffix = "index.html"
  }
  depends_on = [aws_s3_object.frontend_files]
}
output "s3_website" {
  value = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}
