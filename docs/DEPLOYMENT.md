# Main repository: https://github.com/temitayocharles/infraforge-website.git
# Mirror repository: https://github.com/tca-infraforge/infraforge-website-mirror.git
# infraforge Website Deployment Guide

## Overview
This document describes how to deploy the infraforge website using AWS Amplify, Terraform, and OIDC-enabled CI/CD, with secure integration to GitHub for Amplify hosting.

## Prerequisites
  - AWS account 940482412089 with permissions for Amplify, S3, CloudFront, Route 53, Lambda, and Budgets
- Git access to OIDC-enabled CI/CD and GitHub repositories
- Node.js and npm installed
- OIDC IAM role configured for CI/CD

## Deployment Steps

### 1. Dual-Push Git Setup
- Primary development occurs in GitHub.
- Code is automatically mirrored to GitHub using dual-push or GitHub Actions bridge.
- Amplify is connected to the GitHub mirror for CI/CD deployment.

### 2. Infrastructure Provisioning
- Use Terraform modules to provision all AWS resources:
  - Amplify app and branch
  - S3 bucket and DynamoDB for state
  - Route 53 DNS records for custom domain
  - IAM roles and policies (OIDC-based)
  - Budgeting, monitoring, and backend services

### 3. CI/CD Pipeline
- OIDC workflow lints, tests, builds, and deploys the app.
- OIDC is used for secure AWS authentication.
- No secrets or credentials are logged.
- On push/merge, Terraform applies infrastructure changes and triggers app build/deploy.

### 4. Amplify Deployment
- Amplify automatically deploys the app when code is pushed to GitHub.
- Custom domain is configured via Route 53 and associated with Amplify.
- Outputs include deployed URL, app ID, and domain info.

### 5. Verification
- Check pipeline logs for successful deployment.
- Visit the deployed URL to verify the app is live.
- Monitor CloudWatch and budget alerts for ongoing health.

## Security & Best Practices
- OIDC is the default authentication; Vault is deprecated.
- All secrets are managed securely and never logged.
- Example files use placeholders only.
- Team follows documented dual-push workflow for compliance.

## Troubleshooting
- If Amplify does not deploy, verify GitHub mirror is up to date.
- Confirm OIDC IAM role trust and permissions.
- Check Terraform outputs and logs for errors.

## References
- [README.md](../README.md)
- [SECURITY.md](../SECURITY.md)
- [docs/git-dual-push-setup.md](./git-dual-push-setup.md)
- [docs/github-actions-bridge.md](./github-actions-bridge.md)

### AWS Amplify Documentation & Guides
- [AWS Amplify Hosting User Guide](https://docs.aws.amazon.com/amplify/latest/userguide/getting-started.html)
- [Amplify Supported Source Repositories](https://docs.aws.amazon.com/amplify/latest/userguide/getting-started.html#connect-repository)
- [Amplify Console Features](https://docs.aws.amazon.com/amplify/latest/userguide/welcome.html)

**Note:** AWS Amplify Hosting supports direct integration only with GitHub, GitLab, Bitbucket, and AWS CodeCommit. For OIDC-enabled CI/CD, use mirroring or integration to a supported VCS as described above.

For onboarding, team training, and company records, this guide ensures all deployment steps and rationale are clear and up to date.
