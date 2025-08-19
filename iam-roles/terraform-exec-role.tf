data "aws_caller_identity" "current" {}

resource "aws_iam_role" "terraform_exec" {
  name = var.config.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowSSOUserAccess",
        Effect = "Allow",
        Principal = {
          AWS = var.config.iam_trust_user_arn
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.config.tags
}

resource "aws_iam_policy" "terraform_s3_dynamodb_access" {
  name        = "TerraformStateAccessPolicy"
  description = "Least-privilege access to Terraform S3 backend and DynamoDB lock table"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowStateBucketAccess",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          var.config.infraforge_s3_bucket_arn,
          var.config.infraforge_s3_bucket_objects_arn
        ]
      },
      {
        Sid    = "AllowDynamoLockTableAccess",
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:DescribeTable"
        ],
        Resource = var.config.infraforge_dynamodb_table_arn
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_backend_locking_policy" {
  name        = "TerraformBackendFallbackS3Lock"
  description = "Optional: Enables object-level locking for S3 fallback in addition to DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowObjectLock",
        Effect = "Allow",
        Action = [
          "s3:GetObjectRetention",
          "s3:PutObjectRetention"
        ],
        Resource = "arn:aws:s3:::infraforge-tf-state/infraforge/website/envs/production/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_exec_attach" {
  role       = aws_iam_role.terraform_exec.name
  policy_arn = aws_iam_policy.terraform_s3_dynamodb_access.arn
}

resource "aws_iam_role_policy_attachment" "terraform_backend_full_attach" {
  role       = aws_iam_role.terraform_exec.name
  policy_arn = aws_iam_policy.terraform_backend_locking_policy.arn
}
