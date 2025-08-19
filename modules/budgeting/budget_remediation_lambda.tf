resource "aws_iam_role" "budget_lambda_role" {
  name = "${var.config.app_name}-budget-remediation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.config.tags
}

resource "aws_iam_role_policy" "budget_lambda_policy" {
  name = "${var.config.app_name}-budget-remediation-policy"
  role = aws_iam_role.budget_lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:ec2:*:*:instance/*"
      },
      {
        Action = [
          "s3:PutBucketPolicy",
          "s3:PutLifecycleConfiguration"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::*"
      },
      {
        Action = [
          "iam:GetUser",
          "iam:GetRole"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:iam::*:user/*"
      },
      {
        Action = [
          "cloudwatch:PutMetricData"
        ],
        Effect   = "Allow",
        Resource = coalesce(try(var.config.cloudwatch_metric_arn, null), "arn:aws:cloudwatch:::*")
      }
    ]
  })
}

resource "aws_lambda_function" "budget_remediator" {
  function_name = "${var.config.app_name}-budget-remediator"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.budget_lambda_role.arn
  timeout       = 10

  filename         = "${path.module}/files/budget_remediator.zip"
  source_code_hash = filebase64sha256("${path.module}/files/budget_remediator.zip")

  tags = var.config.tags
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.budget_remediator.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.budget_alerts.arn
}
