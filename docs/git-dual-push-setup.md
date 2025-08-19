# Dual Repository Push Setup

## Problem
OIDC mirroring is disabled by admin, but we need GitHub integration for AWS Amplify.

## Solution: Configure Git to Push to Both Repositories

### Step 1: Add GitHub as Additional Remote

```bash
# In your infraforge-website repository
cd infraforge-website

# Add GitHub as a second remote
git remote add github https://github.com/tca-infraforge/infraforge-website-mirror.git.git

# Verify remotes
git remote -v
# Should show:
# origin    https://git.edusuc.net/infraforge/infraforge-website (fetch)
# origin    https://git.edusuc.net/infraforge/infraforge-website (push)
# github    https://github.com/tca-infraforge/infraforge-website-mirror.git.git (fetch)
# github    https://github.com/tca-infraforge/infraforge-website-mirror.git.git (push)
```

### Step 2: Configure Dual Push

```bash
# Configure origin to push to both repositories
git remote set-url --add --push origin https://git.edusuc.net/infraforge/infraforge-website
git remote set-url --add --push origin https://github.com/tca-infraforge/infraforge-website-mirror.git.git

# Verify push URLs
git remote -v
# Should show:
# origin    https://git.edusuc.net/infraforge/infraforge-website (fetch)
# origin    https://git.edusuc.net/infraforge/infraforge-website (push)
# origin    https://github.com/tca-infraforge/infraforge-website-mirror.git.git (push)
# github    https://github.com/tca-infraforge/infraforge-website-mirror.git.git (fetch)
# github    https://github.com/tca-infraforge/infraforge-website-mirror.git.git (push)
```

### Step 3: Create GitHub Repository

1. Go to https://github.com/DEL-ORG
2. Create new repository: `infraforge-website`
3. Make it public (for Amplify access)
4. Don't initialize with README (we'll push existing code)

### Step 4: Test Dual Push

```bash
# Make a test commit
echo "# Test dual push" >> README.md
git add README.md
git commit -m "test: dual repository push"

# Push to both repositories at once
git push origin main

# This will push to both:
# - https://git.edusuc.net/infraforge/infraforge-website
# - https://github.com/tca-infraforge/infraforge-website-mirror.git
```

### Step 5: Team Workflow

Everyone on the team just uses normal Git commands:
```bash
git push origin main    # Pushes to both repositories automatically
git pull origin main    # Pulls from OIDC (primary)
```

## Benefits
- ✅ No admin permissions needed
- ✅ Single push command updates both repos
- ✅ OIDC remains primary repository
- ✅ GitHub stays in sync automatically
- ✅ Amplify can monitor GitHub
- ✅ No workflow changes for team
