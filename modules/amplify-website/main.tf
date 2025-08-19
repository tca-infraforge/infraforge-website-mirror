# IAM Role for Amplify deployments
resource "aws_iam_role" "amplify" {
  name = "${var.config.app_name}-amplify-deploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "amplify.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
  tags = var.config.tags
}

# Amplify App resource
resource "aws_amplify_app" "this" {
  name                     = var.config.app_name
  repository               = var.config.repo_url
  platform                 = "WEB"
  enable_branch_auto_build = true
  environment_variables = {
    OIDC_TOKEN = var.config.oauth_token
    # Add other required variables here
  }
  tags = var.config.tags
}

# CloudFront Distribution for fallback/testing
resource "aws_cloudfront_distribution" "fallback" {
  enabled = var.config.enable_cloudfront
  origin {
    domain_name = aws_amplify_app.this.default_domain
    origin_id   = "amplify-app-origin"
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "amplify-app-origin"
    viewer_protocol_policy = "redirect-to-https"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  tags = var.config.tags
}

# Add required config attributes for policies
locals {
  amplify_app_arn       = aws_amplify_app.this.arn
  s3_bucket_arn         = "arn:aws:s3:::${var.config.tf_state_bucket}"
  cloudfront_dist_arn   = aws_cloudfront_distribution.fallback.arn
  lambda_arn            = "arn:aws:lambda:${var.config.aws_region}:*:function:*"
  logs_arn              = "arn:aws:logs:${var.config.aws_region}:*:log-group:*"
  codebuild_project_arn = "arn:aws:codebuild:${var.config.aws_region}:*:project:*"
}
# IAM Role for Amplify (created inside same AWS account)
resource "aws_iam_role_policy" "amplify" {
  name = "amplify-deploy-policy"
  role = aws_iam_role.amplify.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "amplify:StartDeployment",
          "amplify:GetApp",
          "amplify:ListApps",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData",
          "iam:PassRole"
        ],
        Resource = [
          local.amplify_app_arn,
          local.codebuild_project_arn,
          local.s3_bucket_arn

        ]
      }
    ]
  })
}


resource "aws_sns_topic" "notifications" {
  name = "${var.config.app_name}-sns"
  tags = var.config.tags
}
