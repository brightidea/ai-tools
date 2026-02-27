---
name: scaffolding
description: Creates project structure for new projects. Dispatches scaffolder agent, installs dependencies, verifies clean baseline.
---

# Project Scaffolding

## Purpose

Create the foundational project structure for new projects so that implementation can begin from a clean, building baseline. Skip entirely for existing projects.

## When to Skip

If the working directory contains an existing project (detected by `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, or other project manifests), skip this phase entirely. Scaffolding is only for new projects starting from an empty or near-empty directory.

## Process

### 1. Dispatch Scaffolder Agent

Launch the `do-work:scaffolder` agent with:
- **Stack**: The tech stack chosen or detected in the project-setup phase
- **Blueprint**: The approved architecture blueprint from the design phase
- **File map**: The complete file map from the blueprint, showing every directory and file to create

The scaffolder will:
- Create the full directory structure
- Generate all configuration files with production-ready settings
- Install dependencies
- Create placeholder files for all components in the blueprint
- Verify the scaffold builds, lints, and type-checks cleanly

### 2. Verify Clean Baseline

After the scaffolder reports completion, independently verify:

```bash
# Build verification (stack-dependent)
npm run build          # Node.js projects
python -m py_compile src/main.py  # Python projects

# Lint verification
npm run lint           # If configured
ruff check .           # Python with ruff

# Test verification (should find 0 tests, 0 errors)
npm test               # Node.js
pytest                 # Python
```

All three must pass with zero errors. If any fail:
1. Read the error output
2. Fix the issue or re-dispatch the scaffolder with specific instructions
3. Re-verify until clean

### 3. Commit Scaffold

If the project has managed git (opted in during project-setup):

```bash
git add -A
git commit -m "feat: scaffold project structure"
```

**Note:** `git add -A` is acceptable here and ONLY here — the initial scaffold is the one case where adding everything is correct. All subsequent commits must use explicit file lists.

### 4. Record Baseline

Note the verification results as the baseline. All future implementation tasks must maintain this baseline — builds must keep passing, lints must stay clean, tests must not regress.

## Checkpoint

Present the scaffold status to the user:

```
## Scaffold Complete

**Stack**: [tech stack]
**Files Created**: [count]
**Dependencies Installed**: [count] packages

**Verification:**
- Build: PASS
- Lint: PASS
- Tests: PASS (0 tests, 0 errors)

**Baseline committed**: feat: scaffold project structure

Ready to proceed to implementation?
```

**Wait for user approval before continuing.**
