terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.config.aws_region
}

# ---------------------------------------
# 1) OIDC (object-in, object-out (ARN))
# ---------------------------------------
module "oidc" {
  source = "../../modules/oidc"
  config = merge(var.config.oidc, {
    # pass the branch as part of the OIDC object to keep a single input
    branch_name = var.config.branch_name,
    branch      = var.config.branch_name
  })
}

# ---------------------------------------
# 2) Form backend (object-in, exposes URL)
# ---------------------------------------
module "form_backend" {
  source = "../../modules/form-backend"
  config = {
    app_name           = var.config.app_name
    iam                = var.config.iam
    tags               = var.config.tags
    app_api_secret_key = var.config.app_api_secret_key
    aws_region         = var.config.aws_region
  }
}

# ---------------------------------------
# 3) Build the single config for all app modules
# ---------------------------------------
locals {
  # Force repository to the mirror (Amplify watches this)
  repo_url_effective = var.config.repo_url

  full_config = merge(var.config, {
    repo_url             = local.repo_url_effective,
    branch_name          = var.config.branch_name,
    iam_role_arn         = module.oidc.oidc_role_arn,
    form_backend_api_url = try(module.form_backend.form_backend_api_url, "")
  })
}

# ---------------------------------------
# 4) Amplify website (single object)
# ---------------------------------------
module "amplify_website" {
  source = "../../modules/amplify-website"
  config = local.full_config
}

# ---------------------------------------
# 5) Budgeting (single object)
# ---------------------------------------
module "budgeting" {
  source = "../../modules/budgeting"
  config = local.full_config
}
