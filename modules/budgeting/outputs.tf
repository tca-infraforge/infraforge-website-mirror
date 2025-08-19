output "budget_sns_topic_arn" {
  description = "SNS topic ARN used for budget alerts"
  value       = aws_sns_topic.budget_alerts.arn
}

output "email_subscription_arn" {
  description = "Email subscription ARN if created"
  value       = length(aws_sns_topic_subscription.email) > 0 ? aws_sns_topic_subscription.email[0].arn : null
}

output "mattermost_subscription_arn" {
  description = "Mattermost subscription ARN if created"
  value       = length(aws_sns_topic_subscription.mattermost) > 0 ? aws_sns_topic_subscription.mattermost[0].arn : null
}

output "lambda_subscription_arn" {
  description = "Lambda subscription ARN if created"
  value       = length(aws_sns_topic_subscription.lambda) > 0 ? aws_sns_topic_subscription.lambda[0].arn : null
}
