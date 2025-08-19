terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = var.config.app_name

  has_email      = try(length(var.config.alert_email) > 0, false)
  has_mattermost = try(length(var.config.mattermost_webhook_url) > 0, false)
  has_lambda     = try(length(var.config.budget_remediator_lambda_arn) > 0, false)

  mattermost_is_https = local.has_mattermost && can(regex("^https://", var.config.mattermost_webhook_url))
}

resource "aws_sns_topic" "budget_alerts" {
  name = "${local.name_prefix}-budget-alerts"
  tags = var.config.tags
}

resource "aws_sns_topic_subscription" "email" {
  count     = local.has_email ? 1 : 0
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = var.config.alert_email
}

resource "aws_sns_topic_subscription" "mattermost" {
  count     = local.mattermost_is_https ? 1 : 0
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "https"
  endpoint  = var.config.mattermost_webhook_url
}

resource "aws_sns_topic_subscription" "lambda" {
  count     = local.has_lambda ? 1 : 0
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "lambda"
  endpoint  = var.config.budget_remediator_lambda_arn
}


resource "aws_budgets_budget" "monthly_budget" {
  name         = "${local.name_prefix}-monthly-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = tostring(var.config.budget_limit)
  limit_unit   = "USD"

  cost_filter {
    name   = "LinkedAccount"
    values = [data.aws_caller_identity.current.account_id]
  }

  time_period_start = "2025-01-01_00:00"

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.budget_alerts.arn]
  }

  tags = var.config.tags
}
