# Git Flow Strategy

This document outlines the Git branching strategy for the Travel Assistant AI project.

## Branch Structure

### Main Branches

- **`main`**: Production-ready code for public release
- **`staging`**: Beta testing environment
- **`canary`**: Alpha testing environment
- **`develop`**: Integration branch for development and testing

### Supporting Branches

- **`features/<ticket-name>`**: Feature branches created from `develop`
- **`hotfix/<ticket-name>`**: Hotfix branches created from `main`

## Workflow

### Feature Development

1. Create feature branch from `develop`:

   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b features/<ticket-name>
   ```

2. Work on feature and commit changes:

   ```bash
   git add .
   git commit -m "<ticket-number>: Description of changes"
   ```

3. Push feature branch:

   ```bash
   git push origin features/<ticket-name>
   ```

4. Create pull request to merge into `develop`

### Release Process

1. **Development to Canary (Alpha)**:

   - Merge `develop` → `canary`
   - Test alpha features

2. **Canary to Staging (Beta)**:

   - Merge `canary` → `staging`
   - Perform beta testing

3. **Staging to Main (Production)**:
   - Merge `staging` → `main`
   - Tag release version
   - Deploy to production

### Hotfix Process

1. Create hotfix branch from `main`:

   ```bash
   git checkout main
   git pull origin main
   git checkout -b hotfix/<ticket-name>
   ```

2. Fix issue and commit:

   ```bash
   git add .
   git commit -m "<ticket-number>: Fix description"
   ```

3. Merge hotfix into `develop` for QA testing:

   ```bash
   git checkout develop
   git merge hotfix/<ticket-name>
   git push origin develop
   ```

4. After QA approval, apply hotfix to all release branches:

   ```bash
   # Merge to canary (alpha)
   git checkout canary
   git merge hotfix/<ticket-name>
   git push origin canary

   # Merge to staging (beta)
   git checkout staging
   git merge hotfix/<ticket-name>
   git push origin staging

   # Finally merge to main (production)
   git checkout main
   git merge hotfix/<ticket-name>
   git push origin main
   ```

5. Delete hotfix branch:
   ```bash
   git branch -d hotfix/<ticket-name>
   git push origin --delete hotfix/<ticket-name>
   ```

## Commit Message Convention

All commit messages must start with the Jira ticket number:

```
<TICKET-NUMBER>: Brief description of changes

Detailed description if needed
```

Example:

```
TRAV-123: Add user authentication module

- Implemented OAuth 2.0 login
- Added session management
- Created user profile endpoints
```

## Branch Protection Rules

### Main Branch

- Require pull request reviews
- Require status checks to pass
- Require branches to be up to date
- Include administrators in restrictions

### Staging Branch

- Require pull request reviews
- Require status checks to pass

### Canary Branch

- Require status checks to pass

### Develop Branch

- Require status checks to pass
