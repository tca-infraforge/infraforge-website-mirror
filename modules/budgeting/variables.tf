variable "config" {
  description = "Budgeting configuration (object-only interface)"
  type = object({
    app_name     = string
    aws_region   = string
    budget_limit = number
    tags         = map(string)

    # Optional notification endpoints
    alert_email            = optional(string) # e.g., "alerts@example.com"
    mattermost_webhook_url = optional(string) # e.g., "https://hooks.mattermost.com/..."
    # Optional Lambda subscriber (ARN of an existing function you own)
    budget_remediator_lambda_arn = optional(string)
  })
}
