output "sns_topic_arn" {
  description = "SNS topic ARN for budget alerts"
  value       = aws_sns_topic.budget_alerts.arn
}

output "budget_id" {
  description = "The name of the budget"
  value       = aws_budgets_budget.monthly_budget.name
}

output "budget_limit" {
  description = "Budget monthly threshold in USD"
  value       = aws_budgets_budget.monthly_budget.limit_amount
}

output "mattermost_subscription_arn" {
  description = "ARN of Mattermost SNS subscription"
  value       = aws_sns_topic_subscription.mattermost.arn
}

# output "budget_action_id" {
#   description = "ID of the budget action that triggers SNS notifications"
#   value       = aws_budgets_budget_action.sns_alert_action.id
# }
