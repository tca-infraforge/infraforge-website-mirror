variable "config" {
  description = "OIDC configuration"
  type = object({
    provider_url = string
    thumbprint   = string
    role_name    = string
    repo_owner   = string
    repo_name    = string
    policy_arn   = string
    branch_name  = string
  })
}
