# Commit Conventions

This document outlines the commit message format and branching strategy for this repository.

## Commit Message Format

All commit messages should follow a semantic format:

```
type(scope): brief description
```

### Types

- `recipe`: Adding or modifying recipes
- `docs`: Documentation changes
- `fix`: Bug fixes
- `feat`: New features
- `chore`: Maintenance tasks
- `style`: Formatting changes
- `refactor`: Code refactoring without functionality changes

### Scopes

For recipes, the scope should indicate the category:
- `cocktail`
- `breakfast`
- `pasta`
- `bread`
- `salad`
- `main`
- etc.

For other changes, the scope can indicate the affected component:
- `readme`
- `metadata`
- `structure`
- `workflow`

### Examples

```
recipe(cocktail): add Negroni, Margarita and Cloud Lily recipes
docs(readme): update metadata documentation
fix(metadata): correct nutrition information format
feat(workflow): add automatic image optimization
```

## Branching Strategy

### Branch Naming

Branches should be named according to their purpose:

- `recipe/category-name`: For adding new recipes
- `fix/issue-description`: For bug fixes
- `feat/feature-name`: For new features
- `docs/documentation-update`: For documentation changes

### Examples

```
recipe/cocktails
recipe/summer-salads
fix/missing-metadata
feat/search-functionality
docs/update-readme
```

### Workflow

1. Create a branch from `main` with an appropriate name
2. Make changes and commit with semantic commit messages
3. Push the branch to the remote repository
4. Create a pull request to merge back into `main`
5. After review, merge the changes
