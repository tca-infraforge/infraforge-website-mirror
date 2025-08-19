variable "config" {
  description = "Shared configuration object"
  type = object({
    app_name    = string
    repo_url    = string
    branch_name = string
    oauth_token = string
    # vault_addr                   = string # Deprecated, use OIDC
    iam_role_arn                 = string
    build_spec                   = string
    enable_cloudfront            = bool
    custom_domain                = string
    hosted_zone_id               = string
    tf_state_bucket              = string
    tf_state_key                 = string
    tf_state_dynamodb_lock_table = string
    aws_region                   = string
    budget_limit                 = string
    budget_iam_role_arn          = string
    alert_email                  = string

    iam = object({
      user                  = string
      team                  = string
      lambda_exec_role_name = string
      lambda_policy_arn     = string
    })

    tags = map(string)

    # Add these two missing attributes:
    mattermost_webhook_url = string
    app_api_secret_key     = string
  })
}
