variable "oidc_provider_url" {
  description = "OIDC provider URL (e.g., https://token.actions.githubusercontent.com)"
  type        = string
}

variable "oidc_thumbprint" {
  description = "OIDC provider SSL thumbprint"
  type        = string
}

variable "iam_role_name" {
  description = "Name for the IAM role to be assumed by CI/CD"
  type        = string
}

variable "repo_owner" {
  description = "Repository owner (CI/CD org/user)"
  type        = string
}

variable "repo_name" {
  description = "Repository name"
  type        = string
}


variable "policy_arn" {
  description = "ARN of the policy to attach to the role"
  type        = string
}
