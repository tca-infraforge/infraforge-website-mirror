terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "budget_alerts" {
  name = "${var.config.app_name}-budget-alerts"
  tags = var.config.tags
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = var.config.alert_email
}

resource "aws_sns_topic_subscription" "mattermost" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "https"
  endpoint  = var.config.mattermost_webhook_url
}

resource "aws_sns_topic_subscription" "lambda_remediator" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.budget_remediator.arn
}

resource "aws_budgets_budget" "monthly_budget" {
  name         = "${var.config.app_name}-monthly-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.config.budget_limit
  limit_unit   = "USD"

  cost_filter {
    name   = "LinkedAccount"
    values = [data.aws_caller_identity.current.account_id]
  }

  time_period_start = "2024-01-01_00:00"
  tags              = var.config.tags
}
