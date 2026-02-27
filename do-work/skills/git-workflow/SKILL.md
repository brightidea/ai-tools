---
name: git-workflow
description: Manages git operations throughout the lifecycle -- worktrees, branching, commits, and branch completion. Only active when user opts in.
---

# Git Workflow

## Setup (Phase 0)

When user opts into managed git:

1. **Check if in a git repo**: `git rev-parse --is-inside-work-tree`
   - If not: `git init` and create initial commit
2. **Create feature branch**: `git checkout -b feature/<feature-name>`
   - Use a short, descriptive kebab-case name derived from the feature description
3. **Optionally create worktree** for isolation:
   - Check for `.worktrees/` directory
   - Verify `.worktrees/` is listed in `.gitignore` (add it if not)
   - Create worktree: `git worktree add .worktrees/<name> -b feature/<name>`
   - Install dependencies in the worktree (`npm install`, `pip install -r requirements.txt`, etc.)
   - Run tests in the worktree to verify clean baseline

## During Implementation (Phase 5)

After each task completes and passes review:

```bash
git add <specific files from task>
git commit -m "<type>: <description>"
```

Commit types:
- `feat` -- new feature or capability
- `fix` -- bug fix
- `refactor` -- code restructuring without behavior change
- `test` -- adding or updating tests
- `docs` -- documentation changes
- `chore` -- tooling, config, dependencies, maintenance

Write commit messages that describe WHAT changed and WHY, not HOW. Keep the subject line under 72 characters. Use imperative mood ("add login form", not "added login form").

## Branch Completion (Phase 8)

Present exactly 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to main locally
2. Push and create a Pull Request
3. Keep the branch as-is
4. Discard this work
```

### Option 1: Merge Locally

```bash
git checkout main
git pull                        # sync with remote if applicable
git merge feature/<name>        # merge the feature branch
# Run full test suite on merged result
# Only proceed if tests pass
git branch -d feature/<name>    # delete the feature branch
```

### Option 2: Push and Create PR

```bash
git push -u origin feature/<name>
gh pr create --title "<title>" --body "<summary of changes>"
```

Report the PR URL to the user.

### Option 3: Keep As-Is

Report the branch name and location. Do nothing else.

### Option 4: Discard

Require the user to type "discard" as confirmation. Do not accept "yes", "y", or any other shorthand.

```bash
git checkout main
git branch -D feature/<name>
```

Clean up worktree if one was created:
```bash
git worktree remove .worktrees/<name>
```

## Rules

- **Never force-push** without explicit user consent. Force-pushing rewrites history and can destroy other people's work.
- **Never commit secrets** -- no `.env` files, no credentials, no API keys, no tokens. If a secrets file is staged, unstage it and warn the user.
- **Always commit specific files**, not `git add -A` or `git add .`. Explicit file lists prevent accidentally committing generated files, build artifacts, or secrets.
- **Verify tests pass before merge**. Run the full test suite on the merged result. If tests fail, do not complete the merge.
- **Require confirmation before discarding work**. Typed "discard" confirmation. No shortcuts. Lost work cannot be recovered.
