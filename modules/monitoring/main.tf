resource "aws_cloudwatch_dashboard" "website_dashboard" {
  dashboard_name = "infraforgeDashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.config.lambda_name]
          ],
          period = 300,
          stat   = "Sum",
          region = var.config.aws_region,
          title  = "Lambda Invocations"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "LambdaErrorAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if Lambda function fails"
  dimensions = {
    FunctionName = var.config.lambda_name
  }
  alarm_actions = [var.config.sns_topic_arn]
  tags          = var.config.tags
}

resource "aws_sns_topic" "alerts" {
  name = "infraforge-monitoring-alerts"
}
