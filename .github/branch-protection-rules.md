# GitHub Branch Protection Rules Configuration

This guide explains how to configure GitHub branch protection rules to enforce the Git flow and prevent bypassing the hotfix QA process.

## Branch Protection Settings

### 1. Main Branch Protection

Navigate to: Settings → Branches → Add Rule → Branch name pattern: `main`

**Required Settings:**

- ✅ Require a pull request before merging
  - ✅ Require approvals: 2
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require review from CODEOWNERS
- ✅ Require status checks to pass before merging
  - ✅ Require branches to be up to date before merging
  - Required status checks:
    - `hotfix-verification` (custom check we'll create)
    - `build`
    - `test`
- ✅ Require conversation resolution before merging
- ✅ Require linear history
- ✅ Include administrators
- ✅ Restrict who can push to matching branches
  - Add only release managers or CI/CD service accounts

### 2. Staging Branch Protection

Branch name pattern: `staging`

**Required Settings:**

- ✅ Require a pull request before merging
  - ✅ Require approvals: 1
- ✅ Require status checks to pass before merging
  - Required status checks:
    - `build`
    - `test`
- ✅ Require linear history
- ✅ Restrict who can push to matching branches
  - Add team leads and CI/CD service accounts

### 3. Canary Branch Protection

Branch name pattern: `canary`

**Required Settings:**

- ✅ Require a pull request before merging
  - ✅ Require approvals: 1
- ✅ Require status checks to pass before merging
  - Required status checks:
    - `build`
    - `test`
- ✅ Require linear history

### 4. Develop Branch Protection

Branch name pattern: `develop`

**Required Settings:**

- ✅ Require a pull request before merging
  - ✅ Require approvals: 1
- ✅ Require status checks to pass before merging
  - Required status checks:
    - `build`
    - `test`
    - `lint`
- ✅ Require conversation resolution before merging

## Hotfix Enforcement Rules

### Preventing Direct Hotfix to Main

1. **No direct push to main**: Only PRs allowed
2. **Custom GitHub Action**: Create a status check that verifies:
   - PR source branch follows naming convention `hotfix/*`
   - Hotfix has been merged to develop first
   - QA approval label exists

### GitHub Action for Hotfix Verification

Create `.github/workflows/hotfix-verification.yml`:

```yaml
name: Hotfix Verification

on:
  pull_request:
    branches: [main, staging, canary]

jobs:
  verify-hotfix:
    if: startsWith(github.head_ref, 'hotfix/')
    runs-on: ubuntu-latest
    steps:
      - name: Check hotfix process
        uses: actions/github-script@v7
        with:
          script: |
            const prBranch = context.payload.pull_request.head.ref;
            const targetBranch = context.payload.pull_request.base.ref;

            // For PRs to main, staging, or canary from hotfix branches
            if (prBranch.startsWith('hotfix/')) {
              // Check if PR has QA approval label
              const labels = context.payload.pull_request.labels.map(l => l.name);
              const hasQAApproval = labels.includes('qa-approved');

              if (targetBranch === 'main' && !hasQAApproval) {
                core.setFailed('Hotfix to main requires qa-approved label');
                return;
              }

              // Verify hotfix was merged to develop first
              const { data: commits } = await github.rest.repos.listCommits({
                owner: context.repo.owner,
                repo: context.repo.repo,
                sha: 'develop',
                per_page: 100
              });

              const hotfixInDevelop = commits.some(commit =>
                commit.commit.message.includes(prBranch)
              );

              if (targetBranch === 'main' && !hotfixInDevelop) {
                core.setFailed('Hotfix must be merged to develop first');
              }
            }
```

## PR Templates

Create `.github/pull_request_template.md`:

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Hotfix (urgent fix for production)

## Jira Ticket

TICKET-NUMBER:

## Checklist

- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have added tests
- [ ] All tests pass locally

## For Hotfixes Only

- [ ] Created from main branch
- [ ] Tested in develop branch
- [ ] QA has approved (add `qa-approved` label)
- [ ] Ready to merge to all release branches

## Deployment Notes

Any special deployment considerations
```

## Additional Restrictions

### 1. CODEOWNERS File

Create `.github/CODEOWNERS`:

```
# Global owners
* @teamlead @senior-dev

# Hotfix approval required from QA
hotfix/* @qa-team @teamlead

# CI/CD files
.github/ @devops-team
```

### 2. GitHub Rulesets (Beta Feature)

For even stricter control, use GitHub Rulesets:

1. Go to Settings → Rules → Rulesets
2. Create "Hotfix Flow" ruleset:
   - Target: branches matching `main`, `staging`, `canary`
   - Restrict creations: Block branch creation
   - Restrict updates: Require pull request
   - Restrict deletions: Block branch deletion
   - Require status checks: `hotfix-verification`

### 3. Webhook Enforcement

Create a webhook that:

- Monitors PR creation
- Validates hotfix flow
- Posts status checks
- Sends notifications if process is violated

## Setup Instructions

1. Apply branch protection rules via GitHub UI
2. Add the GitHub Actions workflow
3. Create CODEOWNERS file
4. Set up required labels: `qa-approved`, `hotfix`
5. Configure status checks as required
6. Test with a sample hotfix to ensure flow works

## Monitoring Compliance

- Set up alerts for protection rule overrides
- Regular audit of merged PRs
- Track metrics on hotfix deployment time
- Monitor for emergency bypass usage
