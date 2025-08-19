module "oidc" {
  source = "../../modules/oidc"
  config = {
    oidc_provider_url = var.oidc_provider_url
    oidc_thumbprint   = var.oidc_thumbprint
    iam_role_name     = var.iam_role_name
    repo_owner        = var.repo_owner
    repo_name         = var.repo_name
    branch            = var.config.branch_name
    policy_arn        = var.policy_arn
  }
}

output "oidc_role_arn" {
  value = module.oidc.oidc_role_arn
}
