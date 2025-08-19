# IAM Role for Amplify (created inside same AWS account)
resource "aws_iam_role" "amplify" {
  name = "${var.config.app_name}-amplify-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "amplify.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.config.tags
}

resource "aws_iam_role_policy" "amplify" {
  name = "amplify-deploy-policy"
  role = aws_iam_role.amplify.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "amplify:*",
          "codebuild:*",
          "s3:*",
          "logs:*",
          "cloudwatch:*",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_amplify_app" "this" {
  name                 = var.config.app_name
  repository           = var.config.repo_url
  platform             = "WEB"
  access_token         = var.config.oauth_token
  iam_service_role_arn = aws_iam_role.amplify.arn

  environment_variables = {
    ENVIRONMENT = "production"
  }

  build_spec = yamlencode({
    version = "1.0"
    applications = [{
      frontend = {
        phases = {
          preBuild = {
            commands = [
              "npm ci"
            ]
          }
          build = {
            commands = [
              "npm run build"
            ]
          }
        }
        artifacts = {
          baseDirectory = "build"
          files = [
            "**/*"
          ]
        }
        cache = {
          paths = [
            "node_modules/**/*"
          ]
        }
      }
    }]
  })

  tags = var.config.tags
}

resource "aws_amplify_branch" "main" {
  app_id            = aws_amplify_app.this.id
  branch_name       = var.config.branch_name
  stage             = "PRODUCTION"
  enable_auto_build = true
  framework         = "React"

  environment_variables = {
    FORM_API_URL             = var.config.form_backend_api_url
    REACT_APP_API_URL        = "https://api.infraforge.edusuc.net"
    REACT_APP_API_SECRET_KEY = var.config.app_api_secret_key
  }
}


resource "aws_s3_bucket" "fallback" {
  count         = var.config.enable_cloudfront ? 1 : 0
  bucket        = "${var.config.app_name}-fallback"
  force_destroy = true
  tags          = var.config.tags
}

resource "aws_s3_bucket_ownership_controls" "fallback" {
  count  = var.config.enable_cloudfront ? 1 : 0
  bucket = aws_s3_bucket.fallback[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "fallback" {
  count  = var.config.enable_cloudfront ? 1 : 0
  bucket = aws_s3_bucket.fallback[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "fallback" {
  count                             = var.config.enable_cloudfront ? 1 : 0
  name                              = "${var.config.app_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  description                       = "OAC for secure fallback bucket"
}

resource "aws_cloudfront_distribution" "fallback" {
  count = var.config.enable_cloudfront ? 1 : 0

  origin {
    domain_name              = aws_s3_bucket.fallback[0].bucket_regional_domain_name
    origin_id                = "s3-fallback-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.fallback[0].id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-fallback-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.config.tags
}

resource "aws_s3_bucket_policy" "fallback" {
  count  = var.config.enable_cloudfront ? 1 : 0
  bucket = aws_s3_bucket.fallback[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontReadOnlyAccess",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = ["s3:GetObject"],
        Resource = "${aws_s3_bucket.fallback[0].arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.fallback[0].arn
          }
        }
      }
    ]
  })
}

resource "aws_amplify_domain_association" "this" {
  count       = var.config.custom_domain != "" ? 1 : 0
  app_id      = aws_amplify_app.this.id
  domain_name = var.config.custom_domain

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }
}

resource "aws_route53_record" "alias" {
  count   = var.config.custom_domain != "" && var.config.hosted_zone_id != "" ? 1 : 0
  zone_id = var.config.hosted_zone_id
  name    = var.config.custom_domain
  type    = "A"

  alias {
    name                   = aws_amplify_domain_association.this[0].domain_name
    zone_id                = var.config.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_sns_topic" "notifications" {
  name = "${var.config.app_name}-sns"
  tags = var.config.tags
}
