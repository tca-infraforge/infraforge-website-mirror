# GitHub Actions Bridge Setup

## Alternative Solution: GitHub Actions Sync

If dual-push doesn't work, create a GitHub repository with this workflow:

### .github/workflows/sync-from-oidc.yml

```yaml
name: Sync from OIDC

on:
  schedule:
    # Sync every 5 minutes
    - cron: '*/5 * * * *'
  workflow_dispatch:  # Manual trigger

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout GitHub repo
      uses: actions/checkout@v3
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        fetch-depth: 0

  - name: Add OIDC remote
      run: |
  git remote add oidc https://github.com/tca-infraforge/infraforge-website-mirror.git
        git config user.name "GitHub Actions"
        git config user.email "actions@github.com"

  - name: Fetch from OIDC
      run: |
  git fetch oidc main

    - name: Sync main branch
      run: |
        git checkout main
  git reset --hard oidc/main
        git push origin main --force
```

### Required GitHub Secrets:
- None (uses default GITHUB_TOKEN)

### Setup:
1. Create empty GitHub repository
2. Add this workflow file
3. Run workflow manually first time
4. It will sync every 5 minutes automatically
