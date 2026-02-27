---
name: deployment
description: Deploys to configured target and handles git branch completion. Skipped when user chose no deployment.
---

# Deployment

## Purpose

Deploy the completed, reviewed implementation to the configured target. Handle git branch completion if the project uses managed git. Skip deployment (but still handle git) when the user chose "skip deployment" in project-setup.

## Process

### 1. Check Deployment Configuration

Read the project context from project-setup:
- **If user chose "skip deployment"**: Skip directly to step 4 (Git Branch Completion)
- **If deployment target is configured**: Continue to step 2

### 2. Pre-Deploy Verification

Before deploying, verify everything is green:

**Build must pass:**
```bash
# Use the appropriate command for the stack
npm run build      # Node.js / React / Next.js
python -m build    # Python
cargo build        # Rust
go build ./...     # Go
```

**Tests must pass:**
```bash
npm test           # Node.js
pytest             # Python
cargo test         # Rust
go test ./...      # Go
```

Apply verification skill — read the output, check exit codes. If either build or tests fail, stop. Do not deploy broken code. Fix the issue and re-verify.

### 3. Deploy

Dispatch `do-work:deployer` agent with the target configuration:

**Vercel:**
"Deploy {project} to Vercel. Run `vercel --prod` (or `vercel` for preview). Capture the deployment URL. Verify the deployment succeeded by checking the output for errors. Report: deployment URL, build time, any warnings."

**Docker:**
"Build and deploy {project} as a Docker container. Build the image: `docker build -t {name} .`. Run the container: `docker run -d -p {port}:{port} {name}`. Verify the container is running: `docker ps`. Report: container ID, exposed port, image size, any warnings."

**Other (user-specified):**
"Deploy {project} to {target} using the configuration provided. Follow the target's deployment process. Report: deployment result, access URL (if applicable), any warnings."

### 4. Git Branch Completion

**If git is not managed**: Skip this step entirely.

**If git is managed**: Apply the git-workflow skill's Branch Completion process. Present exactly 4 options:

```
Implementation complete. What would you like to do with the feature branch?

1. Merge back to main locally
2. Push and create a Pull Request
3. Keep the branch as-is
4. Discard this work
```

Follow the git-workflow skill for the detailed steps of each option.

### Checkpoint

Present to user:

```
## Deployment Summary

### Deployment
- **Target**: [Vercel / Docker / Other / Skipped]
- **Status**: [Succeeded / Failed / Skipped]
- **URL**: [deployment URL, if applicable]

### Git Branch
- **Branch**: feature/[name]
- **Action**: [Merged / PR created / Kept / Discarded / Not managed]
- **PR URL**: [if PR was created]

### Final Status
All phases complete. [N] tests passing, [X]% coverage.
```
