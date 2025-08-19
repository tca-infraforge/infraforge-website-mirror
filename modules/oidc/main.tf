resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url             = var.config.provider_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.config.thumbprint]
}

resource "aws_iam_role" "ci_cd" {
  name = var.config.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Federated = aws_iam_openid_connect_provider.oidc_provider.arn },
        Action    = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.config.repo_owner}/${var.config.repo_name}:ref:refs/heads/${var.config.branch_name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ci_cd_policy" {
  role       = aws_iam_role.ci_cd.name
  policy_arn = var.config.policy_arn
}

output "oidc_role_arn" {
  description = "IAM Role ARN to be assumed by CI"
  value       = aws_iam_role.ci_cd.arn
}
