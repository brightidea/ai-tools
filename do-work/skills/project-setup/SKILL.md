---
name: project-setup
description: Detects or selects tech stack, configures git and deployment preferences. First phase of the lifecycle.
---

# Project Setup

## Purpose

Establish project context before any work begins. Detect what exists or choose what to build with.

## Process

### 1. Detect Project Type

Check working directory for source files:
```bash
ls package.json requirements.txt Cargo.toml go.mod pyproject.toml 2>/dev/null
```

**If files found — existing project:**
- Dispatch `do-work:stack-detector` agent to analyze the codebase
- Present detected stack to user for confirmation

**If empty directory — new project:**
- Ask user to choose a tech stack:
  1. Next.js + TypeScript + Tailwind + shadcn + Supabase
  2. React + Vite + TypeScript + Tailwind
  3. Python + FastAPI
  4. React Native + Expo + TypeScript
  5. Let AI decide based on requirements
  6. Other (user specifies)

### 2. Git Preferences

Ask user:
```
Should I manage the git workflow?
- Yes: I'll create branches, commit after each phase, and handle PRs
- No: I won't touch git at all — you handle version control
```

If yes:
- Initialize repo if needed
- Create feature branch
- Set up worktree if desired (for isolation)

### 3. Deployment Target

Ask user:
```
Where should this deploy?
- Vercel
- Docker
- Other (specify)
- Skip deployment
```

### 4. Store Configuration

Build project context object with all preferences. This context flows through every subsequent phase.

### Checkpoint

Present summary:
```
## Project Setup Summary

- **Type**: New project / Existing codebase
- **Stack**: [detected or chosen stack]
- **Git**: Managed (feature/<name> branch) / User-managed
- **Deploy**: Vercel / Docker / Skip

Proceed?
```

Wait for user approval before continuing.
