#creating OAI :
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.domain_name}"
}

#Cloudfront Function to rewrite index.html 
resource "aws_cloudfront_function" "rewrite_index" {
  name = "rewriteIndex"
  runtime = "cloudfront-js-1.0"
  comment = "Rewite index.html"
  code = file("${path.module}/js/rewriteindex.js") 
  publish = true
}

# cloudfront terraform - creating AWS Cloudfront distribution :
resource "aws_cloudfront_distribution" "cf_dist" {
  enabled             = true
  aliases             = [var.domain_name]
  default_root_object = "index.html"
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_s3_bucket.bucket.id
    viewer_protocol_policy = "redirect-to-https" # other options - https only, http
    forwarded_values {
      headers      = []
      query_string = true
      cookies {
        forward = "all"
      }
    }
    function_association {
       event_type   = "viewer-request"
       function_arn = aws_cloudfront_function.rewrite_index.arn
      }
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN", "US", "CA"]
    }
  }
  tags = {
    "Project"   = "My CRC"
    "ManagedBy" = "Terraform"
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}