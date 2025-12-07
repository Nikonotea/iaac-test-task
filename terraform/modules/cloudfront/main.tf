resource "aws_s3_bucket" "frontend" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = merge(var.tags, { Name = var.bucket_name })

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "frontend_versioning" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "frontend_acl" {
  bucket = aws_s3_bucket.frontend.id
  acl    = "private"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.bucket_name}"
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.frontend_s3_policy.json
}

data "aws_iam_policy_document" "frontend_s3_policy" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
    actions   = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${aws_s3_bucket.frontend.arn}/*"]
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "s3-${var.bucket_name}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.tags, { Name = "${var.bucket_name}-cdn" })
}

output "s3_bucket" { value = aws_s3_bucket.frontend.bucket }
output "cloudfront_domain" { value = aws_cloudfront_distribution.cdn.domain_name }
