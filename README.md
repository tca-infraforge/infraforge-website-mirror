# Main repository: https://github.com/temitayocharles/infraforge-website.git
# Mirror repository: https://github.com/tca-infraforge/infraforge-website-mirror.git
# 📚 Documentation Index

- [Deployment Guide](docs/DEPLOYMENT.md)
- [Security Checklist](SECURITY.md)
- [Dual-Push Git Setup](docs/git-dual-push-setup.md)
- [GitHub Actions Bridge](docs/github-actions-bridge.md)

For onboarding, team training, and company records, see the guides above for:
- Step-by-step deployment instructions
- Security best practices and compliance
- Team Git workflow for OIDC/GitHub/Amplify integration
- Alternative GitHub sync solutions

# infraforge Infrastructure Project

This project deploys a secure, enterprise-grade web application using AWS Amplify, CloudFront, and Terraform, integrated with OIDC-enabled CI/CD, enhanced with budgeting, form backend, monitoring, and OIDC.

## Overview
- **React App**: A booking form hosted on Amplify.
- **Infrastructure**: Managed with Terraform modules.
- **CI/CD**: Automated with OIDC-enabled Actions, hardened with `set -euo pipefail`, and includes Trivy scans.
- **Security**: Uses OIDC (Vault deprecated), SOPS, IAM roles, and secret rotation.
- **Enhancements**: Budget alerts, Lambda backend, CloudWatch monitoring.

## Prerequisites
- AWS CLI configured with access to Amplify, S3, CloudFront, Lambda, API Gateway, and Budgets.
- Vault access at `https://vault.edusuc.net` with the following keys in `Dev-secret/infraforge-website` (deprecated, now using OIDC):
  - `OIDC_TOKEN`
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `CLOUDFRONT_DISTRIBUTION_ID`
  - `APP_API_SECRET_KEY`
- Primary repository: `https://github.com/tca-infraforge/infraforge-website-mirror.git.git`
- Node.js and npm installed.
- AWS Account ID and KMS Key ID for SOPS encryption.

## Setup Instructions
See [Deployment Guide](docs/DEPLOYMENT.md) for full setup and deployment steps.

### 1. Run the Bootstrap Scripts
```bash
cd /Users/charlie/Documents/infraforge/infraforge-infra
chmod +x setup_ci_security_monitoring.sh && ./setup_ci_security_monitoring.sh
chmod +x setup_enhancements.sh && ./setup_enhancements.sh
```

### 2. Edit Configuration Placeholders
- **`examples/simple/variables.tfvars`**:
  - Replace `https://mattermost.example.com/hooks/xyz123` with your Mattermost Webhook.
  - Update `repository_url` as needed.

- **`.github/workflows/ci.yml`**:
  - Ensure `940482412089` is used as your AWS Account ID.
  - Make sure Trivy scan blocks contain `set -euo pipefail`.
  - Confirm `trivy fs` includes `--exit-code 1`.

- **`modules/amplify-website/oidc.tf`**:
  - Replace `940482412089` and set the correct OIDC SSL thumbprint.

- **`.sops.yaml`**:
  - Update `940482412089` and `YOUR_KMS_KEY_ID`.

- **`secrets/secrets.enc.yaml`**:
  - Encrypt with:
    ```bash
    sops -e secrets/secrets.yaml > secrets.enc.yaml
    ```

### 3. Initialize and Push to GitHub
```bash
git add .
git commit -m "Initial secure infrastructure with CI/CD"
git push --set-upstream origin feature/s9charles.wft-404-amplify-deploy
```
> Create the remote repo first at: `https://git.edusuc.net/infraforge/infraforge-website.git` if it doesn't exist.

### 4. Add Secrets to Vault (deprecated, now using OIDC)
Login to: `https://vault.edusuc.net/ui`  
Update the path: `Dev-secret/infraforge-website` with:
  - `OIDC_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `CLOUDFRONT_DISTRIBUTION_ID`
- `APP_API_SECRET_KEY`

### 5. Configure AWS IAM Role for OIDC
Use:
- `.github/oidc/trust-policy.json`
- `.github/oidc/role-policy.json`

Create the role in IAM named: `OIDCDeployRole`.

### 6. Manual Deployment (Optional)
```bash
cd examples/simple
terraform init
terraform apply -var-file=variables.tfvars
terraform output deployed_url
```

### 7. Trigger CI/CD
Push a commit or change to run the OIDC CI workflow.

Monitor pipeline at:  
[https://git.edusuc.net/infraforge/infraforge-website.git/actions](https://git.edusuc.net/infraforge/infraforge-website.git/actions)

### 8. Verify Application
- Check the output of:
  ```bash
  terraform output deployed_url
  ```
- Visit the URL to ensure Amplify + API Gateway integration works.
- The `.env` is auto-generated with:
  - `REACT_APP_API_URL`
  - `REACT_APP_API_SECRET_KEY`

## Best Practices
See [Security Checklist](SECURITY.md) for detailed security measures and team guidelines.
- Enforce `set -euo pipefail` in all scripts and CI YAML blocks.
- Fail early on critical Trivy vulnerabilities (`--exit-code 1`).
- Use OIDC and least-privilege IAM roles.
- Rotate secrets and encrypt with SOPS.
- Monitor deployments with CloudWatch and set budget guardrails.

## Troubleshooting
For troubleshooting, see [Deployment Guide](docs/DEPLOYMENT.md) and [Security Checklist](SECURITY.md).
- **403 Vault**: Re-auth via Vault UI or check token scope (Vault deprecated, now using OIDC).
- **Terraform plan/apply errors**: Confirm secret resolution from Vault (Vault deprecated, now using OIDC).
- **OIDC pipeline failures**:
  - Confirm OIDC role trust config.
  - Check Trivy scan outputs.
  - Validate `.env` injection before React build.
