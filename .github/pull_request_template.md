## Description

<!-- Brief description of changes -->

## Jira Ticket

<!-- TICKET-NUMBER: Brief ticket title -->

## Type of Change

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 🚨 Hotfix (urgent fix for production)
- [ ] 🔧 Configuration change
- [ ] 📝 Documentation update
- [ ] ♻️ Refactoring
- [ ] 🧪 Test addition/modification

## Target Branch Checklist

<!-- Check the appropriate flow for your PR -->

### For Feature/Bug PRs → `develop`

- [ ] Created from `develop` branch
- [ ] Targets `develop` branch
- [ ] All tests pass
- [ ] Code review completed

### For Release PRs (`develop` → `canary` → `staging` → `main`)

- [ ] All features tested in previous environment
- [ ] Release notes prepared
- [ ] No pending hotfixes

### For Hotfix PRs

- [ ] Created from `main` branch
- [ ] Branch named `hotfix/<ticket-number>`
- [ ] **First PR**: Targets `develop` for QA testing
- [ ] **After QA**: Has `qa-approved` label
- [ ] **Deployment order**: `develop` → `canary` → `staging` → `main`

## Testing

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] No console errors

## Code Quality

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] No commented-out code
- [ ] No `console.log` statements (unless required)
- [ ] All Jira ticket requirements met

## Documentation

- [ ] Code comments added where necessary
- [ ] README updated (if applicable)
- [ ] API documentation updated (if applicable)

## Deployment Notes

<!-- Any special considerations for deployment -->

## Screenshots/Videos

<!-- If UI changes, add screenshots or videos here -->

## Reviewers Checklist

- [ ] Code quality and standards met
- [ ] Tests adequate and passing
- [ ] Documentation sufficient
- [ ] No security vulnerabilities introduced
- [ ] Performance impact considered
