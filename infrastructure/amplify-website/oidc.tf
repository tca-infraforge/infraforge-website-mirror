resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url             = "https://git.edusuc.net"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0ecd4e3e3"]
}

resource "aws_iam_role" "oidc_role" {
  name = "OIDCDeployRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "git.edusuc.net:sub" = "repo:infraforge/infraforge-website:ref:refs/heads/feature/s9charles.wft-404-amplify-deploy"
          }
        }
      }
    ]
  })
}

# Attach Permissions Policy
resource "aws_iam_role_policy" "oidc_policy" {
  name = "OIDCPolicy"
  role = aws_iam_role.oidc_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "amplify:*",
          "s3:*",
          "sns:*",
          "cloudfront:*",
          "budgets:*",
          "lambda:*",
          "apigateway:*",
          "logs:*",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}
