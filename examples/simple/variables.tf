variable "config" {
  description = "Global configuration block"
  type = object({
    app_name                     = string
    repo_url                     = string
    branch_name                  = string
    oauth_token                  = string
    iam_role_arn                 = string
    build_spec                   = string
    enable_cloudfront            = bool
    custom_domain                = string
    hosted_zone_id               = string
    tf_state_bucket              = string
    tf_state_key                 = string
    tf_state_dynamodb_lock_table = string
    aws_region                   = string
    budget_limit                 = number
    form_backend_api_url         = string
    app_api_secret_key           = string

    oidc = object({
      provider_url = string
      thumbprint   = string
      role_name    = string
      repo_owner   = string
      repo_name    = string
      policy_arn   = string
    })

    iam = object({
      user = string
      team = string
    })

    tags = map(string)
  })
}
