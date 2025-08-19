resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0c1d1e3e1"]
}

resource "aws_iam_role" "github_actions" {
  name = "infraforge-ci-cd-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            # >>> LOCK TO THE MIRROR REPO <<<
            "token.actions.githubusercontent.com:sub" = "repo:tca-infraforge/infraforge-website-mirror:ref:refs/heads/${var.config.branch_name}"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy" "oidc_policy" {
  name = "OIDCPolicy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "amplify:ListApps",
          "amplify:GetApp",
          "amplify:GetBranch",
          "amplify:StartDeployment",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "cloudfront:GetDistribution",
          "cloudfront:CreateInvalidation",
          "lambda:InvokeFunction",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "iam:PassRole"
        ],
        Resource = compact([
          local.amplify_app_arn,
          local.s3_bucket_arn,
          local.cloudfront_dist_arn,
          local.lambda_arn,
          local.logs_arn,
          var.config.iam_role_arn
        ])
      }
    ]
  })
}
