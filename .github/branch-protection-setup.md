# Branch Protection Setup Guide

This document explains how to configure branch protection rules to ensure CI checks must pass before merging PRs.

## Required Branch Protection Rules

### For `main` branch:

1. **Navigate to**: Repository Settings > Branches
2. **Add rule** for branch name pattern: `main`
3. **Enable these settings**:
   - [x] Require a pull request before merging
   - [x] Require approvals (minimum 1)
   - [x] Dismiss stale PR approvals when new commits are pushed
   - [x] Require status checks to pass before merging
   - [x] Require branches to be up to date before merging
   - [x] Require conversation resolution before merging
   - [x] Include administrators

### Required Status Checks:

Add these status checks (they must pass before merge):

- `Test & Lint`
- `Build (android)`
- `Build (ios)`
- `Build (web)`
- `Security Scan`
- `Melos Workspace`

### For `develop` branch:

Apply the same rules as `main` but optionally:

- Reduce required approvals to 0 for faster development
- Keep all other protections enabled

## CLI Setup (Alternative)

If you have GitHub CLI installed, you can set up branch protection with:

```bash
# Enable branch protection for main
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["Test & Lint","Build (android)","Build (ios)","Build (web)","Security Scan","Melos Workspace"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null

# Enable branch protection for develop
gh api repos/:owner/:repo/branches/develop/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["Test & Lint","Build (android)","Build (ios)","Build (web)","Security Scan","Melos Workspace"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":0,"dismiss_stale_reviews":true}' \
  --field restrictions=null
```

## Verification

After setup, verify:

1. Create a test PR with failing tests
2. Confirm merge button is disabled
3. Fix tests and confirm merge becomes available

## Notes

- Status check names must match exactly what's defined in the CI workflow
- Branch protection rules apply to all users including admins (recommended)
- Failed CI checks will block merges automatically
- Emergency override is possible through repository settings if needed
