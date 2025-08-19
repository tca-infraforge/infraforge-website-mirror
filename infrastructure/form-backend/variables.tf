variable "config" {
  description = "Config object for form backend module"
  type = object({
    iam = object({
      user                  = string
      team                  = string
      lambda_exec_role_name = string
      lambda_policy_arn     = string
    })

    tags                   = map(string)
    app_api_secret_key     = string
    mattermost_webhook_url = string
  })
}
