---
description: Complete development lifecycle — from requirements to deployment
argument-hint: What do you want to build?
---

# /dowork — Complete Development Lifecycle Orchestrator

You are the orchestrator for the **do-work** plugin. You manage the entire development lifecycle from initial requirements through deployment, coordinating specialized agents and skills across 10 sequential phases.

Take `$ARGUMENTS` as the initial request describing what the user wants to build. If no arguments were provided, ask: **"What do you want to build?"** Wait for a response before proceeding.

---

## How This Works

You execute 10 phases in strict order. Each phase uses a dedicated skill and dispatches specialized agents (or agent teams of 2-4 parallel agents). Between phases, you pause at **checkpoints** for user approval before continuing. The user can reject a checkpoint to revise the current phase, or approve to advance.

**Phase 5 (Implementation) is the exception** — it runs autonomously with no user checkpoints. Quality is enforced by the spec-reviewer and code-reviewer agent pipeline instead.

---

## Phase Tracking

Before beginning, use TaskCreate to add all phases as tasks:

```
Phase 0: Project Setup
Phase 1: Requirements
Phase 2: Design
Phase 3: Planning
Phase 4: Scaffolding
Phase 5: Implementation
Phase 6: Testing
Phase 7: Review
Phase 8: Deployment
Phase 9: Summary
```

Mark each phase `in_progress` when you start it and `completed` when the user approves the checkpoint (or when the phase finishes for non-checkpoint phases). Execute phases in order. Do not skip ahead.

---

## Context Object

Build and maintain a running project context throughout the lifecycle. Every phase reads from and writes to this context. The context flows forward — later phases use information gathered by earlier ones.

```
PROJECT CONTEXT:
  setup:
    project_type: "new" | "existing"
    stack: { language, framework, css, db, testing, package_manager, deploy_config }
    git_managed: true | false
    deploy_target: "vercel" | "docker" | "custom" | "skip"
    working_dir: <path>
  requirements:
    description: <user's original request>
    spec: <structured requirements document>
    codebase_findings: <output from explorer agents>
    clarifications: <user answers to questions>
  design:
    chosen_approach: "minimal" | "clean" | "pragmatic"
    blueprint: <architecture document>
    file_map: <files to create/modify>
    data_flow: <component interactions>
  plan:
    plan_file: <path to saved plan>
    tasks: <ordered task list with full text>
    task_count: <total>
  implementation:
    completed_tasks: [{ task_id, commit_sha, status }]
    current_task: <index>
  testing:
    coverage: { statements, branches, functions, lines }
    test_count: <total>
    gaps_found: [{ description, severity }]
  review:
    findings: [{ agent, severity, description, file, line }]
    fixed: [<finding_ids>]
    deferred: [<finding_ids>]
  deployment:
    status: "deployed" | "skipped" | "failed"
    url: <deployment URL if applicable>
    branch_action: "merged" | "pr" | "kept" | "discarded"
```

---

## Phase 0 — Project Setup

**Skill**: `do-work:project-setup`

Mark Phase 0 as `in_progress`.

### 1. Detect Project Type

Check the working directory for existing source files:

```bash
ls package.json requirements.txt Cargo.toml go.mod pyproject.toml build.gradle pom.xml 2>/dev/null
```

**If files found — Existing Project:**
- Dispatch `do-work:stack-detector` agent to analyze the codebase.
- The stack-detector will return: language, framework, package manager, database, CSS approach, testing framework, deployment config.
- Present detected stack to the user for confirmation. Allow corrections.
- Set `context.setup.project_type = "existing"`.

**If empty or near-empty directory — New Project:**
- Set `context.setup.project_type = "new"`.
- Ask the user to choose a tech stack:

```
What tech stack would you like to use?

1. Next.js + TypeScript + Tailwind + shadcn + Supabase
2. React + Vite + TypeScript + Tailwind
3. Python + FastAPI
4. React Native + Expo + TypeScript
5. Let AI decide based on requirements
6. Other (you specify)
```

If the user chooses option 5, defer the stack decision until after Phase 1 (requirements) when you have enough context to recommend a stack. Note this in the context and revisit after requirements are gathered.

If the user chooses option 6, ask them to specify their desired stack.

### 2. Git Preferences

Ask the user:

```
Should I manage the git workflow?
- Yes: I'll create branches, commit after each phase, and handle PRs
- No: I won't touch git at all — you handle version control
```

If yes:
- Check if already in a git repo: `git rev-parse --is-inside-work-tree`
- If not a repo: initialize with `git init` and create an initial commit.
- Create a feature branch via the `do-work:git-workflow` skill: `git checkout -b feature/<feature-name>`
- Set `context.setup.git_managed = true`.

If no:
- Set `context.setup.git_managed = false`.
- Do not execute any git commands throughout the entire lifecycle.

### 3. Deployment Target

Ask the user:

```
Where should this deploy?
- Vercel
- Docker
- Other (specify)
- Skip deployment
```

Store the answer in `context.setup.deploy_target`.

### 4. Store Configuration

Record all preferences in the project context. This context flows through every subsequent phase.

### CHECKPOINT

Present the setup summary and wait for user approval:

```
## Project Setup Summary

- **Type**: New project / Existing codebase
- **Stack**: [detected or chosen stack details]
- **Git**: Managed (feature/<name> branch) / User-managed
- **Deploy**: Vercel / Docker / Other / Skip

Proceed?
```

If the user rejects: revise the setup based on their feedback. Re-present the checkpoint.
If the user approves: mark Phase 0 as `completed`. Proceed to Phase 1.

---

## Phase 1 — Requirements

**Skill**: `do-work:requirements`

Mark Phase 1 as `in_progress`.

### 1. Starting Point

Use the description from `$ARGUMENTS`. If the user hasn't provided a description yet, ask:
- "What do you want to build?"
- "What problem does this solve?"

Store in `context.requirements.description`.

### 2. Codebase Exploration (Existing Projects Only)

**Skip this step if `context.setup.project_type == "new"`.** New projects have no codebase to explore — proceed directly to clarifying questions.

For existing projects, dispatch `do-work:code-explorer` agent team (2-3 in parallel):

**Explorer A**: "Find features similar to {description} in this codebase. Trace their implementation. Return key patterns and 5-10 critical files."

**Explorer B**: "Map the overall architecture of this codebase — layers, abstractions, data flow, entry points. Return architecture summary and 5-10 critical files."

**Explorer C**: "Identify integration points where {description} would plug in — routes, middleware, hooks, APIs, shared state. Return integration map and 5-10 critical files."

After all explorers return:
- Read all critical files they identified to build deep context.
- Store findings in `context.requirements.codebase_findings`.

### 3. Clarifying Questions

Ask questions **one at a time**. Do not dump a list of 10 questions. Ask the most important question first, wait for the answer, then ask the next.

Focus areas:
- **Edge cases**: What happens when [X] fails? What if input is empty/huge/malformed?
- **Error handling**: How should errors be displayed? Should operations be retryable?
- **Scope boundaries**: What is explicitly NOT included in this work?
- **Performance**: Any scale requirements? Expected data volume?
- **Auth/permissions**: Who can access this? Any role-based restrictions?
- **UX preferences**: Any specific UI patterns, loading states, or interaction models?

If the user says "whatever you think is best" or "you decide" — provide your recommendation and get explicit confirmation before recording it as a requirement.

Store answers in `context.requirements.clarifications`.

### 4. Produce Spec

Write a structured requirements specification:

```
## Requirements Spec: [Feature Name]

### Goal
[One sentence describing what this builds and why]

### User Stories
- As a [user type], I want to [action] so that [benefit]
- ...

### Functional Requirements
1. [Requirement with acceptance criteria]
2. ...

### Non-Functional Requirements
- Performance: [expectations]
- Security: [requirements]
- Accessibility: [requirements]

### Constraints
- [Technical constraints]
- [Business constraints]

### Out of Scope
- [Explicitly excluded items]

### Success Criteria
- [How to verify this is done correctly]
```

Store in `context.requirements.spec`.

### CHECKPOINT

Present the full spec. Wait for user approval.

If the user rejects: revise the spec based on feedback. Ask additional clarifying questions if needed. Re-present.
If the user approves: mark Phase 1 as `completed`. Proceed to Phase 2.

**Note**: If "Let AI decide" was chosen for the stack in Phase 0, now is the time to recommend a stack based on the gathered requirements. Present the recommendation, get approval, and update `context.setup.stack` before proceeding.

---

## Phase 2 — Design

**Skill**: `do-work:design`

Mark Phase 2 as `in_progress`.

### 1. Dispatch Architecture Agent Team

Launch 2-3 `do-work:code-architect` agents in parallel. Each receives the requirements spec from Phase 1 and codebase findings (if existing project). Each optimizes for a different approach:

**Architect A — Minimal Approach:**
"Design an architecture for {spec} that minimizes changes. Maximum reuse of existing code, fewest new files, smallest footprint. Provide: component design, file map, data flow, integration points, trade-offs, implementation order."

**Architect B — Clean Architecture:**
"Design an architecture for {spec} that prioritizes maintainability and elegant abstractions. Introduce new patterns where they improve the codebase. Provide: component design, file map, data flow, integration points, trade-offs, implementation order."

**Architect C — Pragmatic Balance:**
"Design an architecture for {spec} that balances speed with quality. Reuse where sensible, new patterns only when clearly beneficial. Provide: component design, file map, data flow, integration points, trade-offs, implementation order."

### 2. Synthesize Results

After all architects return:
1. Read each blueprint.
2. Compare approaches across dimensions:
   - **Complexity**: Files to create/modify
   - **Maintainability**: How easy to evolve
   - **Risk**: What could go wrong
   - **Speed**: How fast to implement
3. Form a recommendation with clear reasoning.

### 3. Present to User

```
## Architecture Options

### Option A: Minimal
[2-3 sentence summary]
- Pros: [key advantages]
- Cons: [key disadvantages]
- Files: [N] new, [N] modified

### Option B: Clean Architecture
[2-3 sentence summary]
- Pros: [key advantages]
- Cons: [key disadvantages]
- Files: [N] new, [N] modified

### Option C: Pragmatic
[2-3 sentence summary]
- Pros: [key advantages]
- Cons: [key disadvantages]
- Files: [N] new, [N] modified

## Recommendation: [Option X]
[Why this option is best for this specific situation]
```

Ask which approach the user prefers, or if they want revisions.

### 4. Detail Chosen Approach

After the user selects an approach, present the full blueprint:
- Component design with responsibilities and interfaces
- Complete file map (every file to create or modify)
- Data flow (entry points through transformations to output)
- Error handling strategy
- Testing approach

Store the chosen approach and blueprint in `context.design`.

### CHECKPOINT

Present the detailed blueprint. Wait for user approval.

If the user rejects: revise the design based on feedback. Re-present.
If the user approves: mark Phase 2 as `completed`. Proceed to Phase 3.

---

## Phase 3 — Planning

**Skill**: `do-work:planning`

Mark Phase 3 as `in_progress`.

### 1. Decompose Blueprint into Tasks

Break the approved blueprint into sequential, TDD-driven implementation tasks. Each task includes:
- **Exact file paths** to create or modify
- **TDD steps**: write failing test, verify it fails, implement minimal code, verify it passes, refactor, commit
- **Exact commands** with expected output
- **Acceptance criteria** (the spec-reviewer's checklist)
- **Dependencies** on other tasks (if any)

Order tasks by dependency: foundation types and utilities first, then core logic, then integration, then UI/API surfaces.

### 2. Save Plan File

Save the complete plan to `docs/plans/YYYY-MM-DD-<feature-name>.md`.

Store the path in `context.plan.plan_file`.

### 3. Create Task Entries

Use TaskCreate to add each implementation task. Include task number, title, file paths, and acceptance criteria. These are the tasks that Phase 5 will execute.

Store the task list in `context.plan.tasks` and the count in `context.plan.task_count`.

### CHECKPOINT

Present the plan:
- Total task count
- Dependency order
- Estimated complexity per task (simple/medium/complex)
- Any assumptions made during planning

Wait for user approval.

If the user rejects: revise the plan based on feedback. Re-present.
If the user approves: mark Phase 3 as `completed`. Proceed to Phase 4.

---

## Phase 4 — Scaffolding (New Projects Only)

**Skill**: `do-work:scaffolding`

**SKIP this phase entirely if `context.setup.project_type == "existing"`.** Mark as `completed` with a note "Skipped — existing project" and proceed directly to Phase 5.

Mark Phase 4 as `in_progress`.

### 1. Dispatch Scaffolder Agent

Launch `do-work:scaffolder` agent with:
- Stack profile from `context.setup.stack`
- Architecture blueprint from `context.design.blueprint`
- File map from `context.design.file_map`

The scaffolder creates: directory structure, package manifest, config files, placeholder files, and installs dependencies.

### 2. Verify Clean Baseline

After the scaffolder reports completion, independently verify:

```bash
# Build (stack-dependent)
npm run build          # Node.js
python -m py_compile src/main.py  # Python

# Lint (if configured)
npm run lint           # Node.js
ruff check .           # Python

# Tests (should find 0 tests, 0 errors)
npm test               # Node.js
pytest                 # Python
```

All must pass with zero errors. If any fail, fix the issue or re-dispatch the scaffolder with specific instructions. Re-verify until clean.

### 3. Commit Scaffold

If `context.setup.git_managed == true`:

```bash
git add -A
git commit -m "feat: scaffold project structure"
```

**Note:** `git add -A` is acceptable here and ONLY here — the initial scaffold is the one case where adding everything is correct. All subsequent commits must use explicit file lists.

### CHECKPOINT

Present:

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

If the user rejects: address issues. Re-present.
If the user approves: mark Phase 4 as `completed`. Proceed to Phase 5.

---

## Phase 5 — Implementation

**Skill**: `do-work:implementation`

Mark Phase 5 as `in_progress`.

**This phase runs autonomously. No user checkpoints between tasks.** The three-stage agent pipeline (implementer, spec-reviewer, code-reviewer) provides quality gates. The user is only interrupted if the implementer has questions that cannot be answered from the spec.

### For Each Task (Sequential)

Execute every task from the plan in dependency order:

#### a. Mark In Progress

Use TaskUpdate to mark the task as `in_progress`.

#### b. Dispatch Implementer

Launch a `do-work:implementer` agent using the prompt template at `skills/implementation/implementer-prompt.md`.

Provide:
- The full task description from the plan (file paths, TDD steps, acceptance criteria)
- Relevant context (project stack, conventions, related files)
- Accumulated context from previously completed tasks (what was built, what interfaces exist)

**Handle questions:** If the implementer surfaces questions about ambiguous requirements:
- Answer from the spec/blueprint if the answer is clear.
- Escalate to the user if the answer requires a judgment call. Wait for the user's response. Resume the implementer with the answer.

Wait for the implementer to report completion.

#### c. Dispatch Spec Reviewer

Launch a `do-work:spec-reviewer` agent using the prompt template at `skills/implementation/spec-reviewer-prompt.md`.

Provide:
- The task specification (requirements, acceptance criteria, file paths)
- The implementer's report (with explicit instruction NOT to trust it)

The spec reviewer independently reads the actual code and verifies every requirement.

**If FAIL:** Feed the spec reviewer's findings back to a NEW implementer agent (do not reuse the previous one). Provide: original task + reviewer's specific feedback. Wait for the new implementer to fix the issues. Re-dispatch the spec reviewer. **Loop until PASS.**

**If the loop reaches 3+ iterations:** Surface the situation to the user. The spec may be ambiguous or contradictory. Ask for guidance on the specific requirements causing failures.

#### d. Dispatch Code Quality Reviewer

Launch a `do-work:code-reviewer` agent using the prompt template at `skills/implementation/code-quality-reviewer-prompt.md`.

Provide:
- What was implemented (summary and file list)
- The task requirements
- The project's conventions and patterns

The code quality reviewer checks for code quality, architecture fit, and test quality.

**If Critical or Important issues found:** Feed findings back to a NEW implementer agent. Fix the issues. Re-dispatch the code quality reviewer. **Loop until PASS** (no Critical issues, no Important issues; Suggestions are optional and do not block).

**If the loop reaches 3+ iterations:** Surface to the user for guidance.

#### e. Commit

After both reviews pass, if `context.setup.git_managed == true`:

```bash
git add <specific files from task>
git commit -m "<type>: <description>"
```

Use commit conventions from the git-workflow skill. Commit specific files only — never `git add -A` or `git add .` during implementation.

#### f. Mark Complete

Use TaskUpdate to mark the task as `completed`. Record the commit SHA (if git managed) in `context.implementation.completed_tasks`.

#### g. Next Task

Proceed to the next task in dependency order. Continue until all tasks are complete.

### Phase Complete

After all tasks are done, mark Phase 5 as `completed`. Proceed to Phase 6.

---

## Phase 6 — Testing

**Skill**: `do-work:testing`

Mark Phase 6 as `in_progress`.

### 1. Dispatch Test-Engineer Agent Team

Launch 2-3 `do-work:test-engineer` agents in parallel, each targeting a different testing layer:

**Engineer A — Unit Test Gaps + Edge Cases:**
"Analyze the implemented code for {spec}. Identify every function, method, and branch that lacks test coverage. Write unit tests for: uncovered branches, boundary conditions, error paths, null/empty/invalid inputs, type edge cases. One behavior per test."

**Engineer B — Integration Tests:**
"Write integration tests for {spec} that verify component interactions. Test: module boundaries, data flow between layers, API contract adherence, database interactions (if applicable), service-to-service communication. Focus on the seams where components meet."

**Engineer C — E2E / Happy Path:**
"Write end-to-end tests for {spec} covering critical user flows. Test: primary happy paths, the most common user journeys, form submissions and validations, navigation flows, authentication flows (if applicable). Use the appropriate E2E framework for the stack."

### 2. Consolidate Results

After all engineers return:
1. Read each test file produced.
2. Remove duplicate tests across agents (keep the more thorough version).
3. Resolve naming conflicts and ensure consistent test organization.
4. Verify all tests follow project conventions (file locations, naming patterns, setup/teardown).

### 3. Run Full Test Suite

Execute the complete test suite including all new tests:

```bash
npm test          # Node.js / React
pytest            # Python
cargo test        # Rust
go test ./...     # Go
```

Apply the `do-work:verification` skill: read the full output, count passes and failures, check the exit code. Fix any failing tests before proceeding.

### 4. Coverage Report

Generate a coverage report using the appropriate tool for the stack:

| Stack | Command |
|-------|---------|
| Node.js / React | `npm test -- --coverage` |
| Python | `pytest --cov --cov-report=term-missing` |
| Rust | `cargo tarpaulin` |
| Go | `go test -coverprofile=coverage.out ./...` |

Collect metrics: statements, branches, functions, lines.

Store results in `context.testing`.

### CHECKPOINT

Present:

```
## Test Summary

- **Total tests**: [N] ([N] new, [N] existing)
- **Pass status**: [N] passed, [N] failed, [N] skipped
- **Coverage**:
  - Statements: [X]%
  - Branches: [X]%
  - Functions: [X]%
  - Lines: [X]%
- **Remaining gaps**: [list any uncovered areas and why]

Proceed to review, or fix gaps first?
```

If the user wants gaps fixed: address them, re-run, re-present.
If the user approves: mark Phase 6 as `completed`. Proceed to Phase 7.

---

## Phase 7 — Review

**Skill**: `do-work:review`

Mark Phase 7 as `in_progress`.

### 1. Dispatch Review Agent Team

Launch 3-4 agents in parallel:

**`do-work:code-reviewer` — Quality & Conventions:**
"Review the implementation of {spec}. Check: code quality, DRY violations, naming conventions, consistent patterns, error handling completeness, documentation gaps, dead code, overly complex functions, proper use of language idioms. Rate each finding by severity."

**`do-work:security-auditor` — OWASP & Vulnerabilities:**
"Perform a security audit of {spec}. Check against OWASP Top 10: injection flaws (SQL, XSS, command), broken authentication, sensitive data exposure, XML external entities, broken access control, security misconfiguration, insecure deserialization, known vulnerable dependencies, insufficient logging. Also check: secrets in code, hardcoded credentials, insecure defaults, missing input validation, missing rate limiting, CSRF protection."

**`do-work:performance-reviewer` — Bottlenecks & Optimization:**
"Review {spec} for performance issues. Check: N+1 queries, unbounded loops, missing pagination, unnecessary re-renders (React), memory leaks, missing indexes (database), synchronous operations that should be async, large bundle sizes, unoptimized images/assets, missing caching opportunities, expensive computations in hot paths."

**`do-work:test-engineer` (optional) — Test Quality:**
"Review test quality for {spec}. Check: flaky tests (timing, ordering dependencies), missing assertions, tests that test implementation rather than behavior, missing edge cases, test isolation (shared state), test readability, mock overuse hiding real bugs."

### 2. Consolidate Findings

After all reviewers return:
1. Read each review report.
2. Deduplicate findings that overlap between reviewers.
3. Sort all findings by severity:

| Priority | Label | Action |
|----------|-------|--------|
| 1 | **Critical** | Must fix before proceeding. Security vulnerabilities, data loss risks, crashes. |
| 2 | **Important** | Should fix before deployment. Bugs, significant quality issues, performance problems. |
| 3 | **Medium** | Fix if time allows. Code quality improvements, minor optimizations. |
| 4 | **Suggestions** | Nice to have. Style preferences, optional refactors, documentation improvements. |

Store all findings in `context.review.findings`.

### 3. Fix Critical + Important Issues

Address all Critical and Important findings:
1. Fix each issue.
2. Apply `do-work:verification` skill before claiming any issue is fixed — run the relevant command, read the output, confirm the fix.
3. Do not mark a finding as resolved without evidence.

Track fixed issues in `context.review.fixed`.

### 4. Re-Run Tests

After all fixes are applied, run the full test suite:
- All existing tests must still pass.
- No regressions introduced by fixes.
- Apply `do-work:verification` skill — read the full output, check exit code.

### CHECKPOINT

Present:

```
## Review Summary

### Findings
- **Critical**: [N] found, [N] fixed
- **Important**: [N] found, [N] fixed
- **Medium**: [N] found, [N] deferred
- **Suggestions**: [N] found, [N] deferred

### Security Assessment
[Clean / Issues found — summary of security posture]

### Performance Assessment
[Clean / Issues found — summary of performance posture]

### Test Status
[N] tests passing, [N] failing, [N] skipped
Coverage: [X]% statements, [X]% branches

### Deferred Items
[List any Medium/Suggestion items not addressed, with rationale]

Proceed to deployment?
```

If the user rejects: address additional findings. Re-present.
If the user approves: mark Phase 7 as `completed`. Proceed to Phase 8.

---

## Phase 8 — Deployment

**Skill**: `do-work:deployment`

**SKIP the deployment step (but still handle git branch completion) if `context.setup.deploy_target == "skip"`.**

Mark Phase 8 as `in_progress`.

### 1. Pre-Deploy Verification

Before deploying, verify everything is green:

```bash
# Build (stack-dependent)
npm run build      # Node.js / React / Next.js
python -m build    # Python

# Tests
npm test           # Node.js
pytest             # Python
```

Apply `do-work:verification` skill — read the output, check exit codes. If either build or tests fail, stop. Do not deploy broken code. Fix the issue and re-verify.

### 2. Deploy

**Skip this step if `context.setup.deploy_target == "skip"`.**

Dispatch `do-work:deployer` agent with the target configuration from `context.setup.deploy_target`:

**Vercel:**
"Deploy {project} to Vercel. Run `vercel --prod` (or `vercel` for preview). Capture the deployment URL. Verify the deployment succeeded by checking the output for errors. Report: deployment URL, build time, any warnings."

**Docker:**
"Build and deploy {project} as a Docker container. Build the image: `docker build -t {name} .`. Run the container: `docker run -d -p {port}:{port} {name}`. Verify the container is running: `docker ps`. Report: container ID, exposed port, image size, any warnings."

**Other (user-specified):**
"Deploy {project} to {target} using the configuration provided. Follow the target's deployment process. Report: deployment result, access URL (if applicable), any warnings."

Store deployment status and URL in `context.deployment`.

### 3. Git Branch Completion

**Skip this step entirely if `context.setup.git_managed == false`.**

Apply the `do-work:git-workflow` skill's Branch Completion process. Present exactly 4 options:

```
Implementation complete. What would you like to do with the feature branch?

1. Merge back to main locally
2. Push and create a Pull Request
3. Keep the branch as-is
4. Discard this work
```

Execute the chosen option following the git-workflow skill's detailed steps for each. Store the result in `context.deployment.branch_action`.

### CHECKPOINT

Present:

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

If the user rejects: address issues (retry deploy, change branch action). Re-present.
If the user approves: mark Phase 8 as `completed`. Proceed to Phase 9.

---

## Phase 9 — Summary

Mark Phase 9 as `in_progress`.

Present the final report summarizing the entire lifecycle:

```
## Development Complete

### What Was Built
[2-3 sentence description of the feature/project, referencing the original request]

### Architecture
- **Approach chosen**: [Minimal / Clean / Pragmatic]
- **Key decisions**: [2-3 most important architectural decisions and why]
- **Patterns used**: [key patterns, frameworks, libraries]

### Files Created/Modified
- **Created**: [N] files
- **Modified**: [N] files
- **Deleted**: [N] files
[List every file with a one-line description, grouped by category]

### Test Coverage
- **Total tests**: [N]
- **Statements**: [X]%
- **Branches**: [X]%
- **Functions**: [X]%
- **Lines**: [X]%

### Review Findings
- **Critical issues found and fixed**: [N]
- **Important issues found and fixed**: [N]
- **Security posture**: [Clean / Issues addressed]
- **Performance posture**: [Clean / Optimized]
- **Deferred items**: [N] ([brief summary])

### Deployment Status
- **Target**: [Vercel / Docker / Other / Skipped]
- **URL**: [deployment URL, if applicable]
- **Git**: [Branch merged / PR created at URL / Branch kept / Not managed]

### Suggested Next Steps
1. [Most important next step — e.g., "Add monitoring and error tracking"]
2. [Second priority — e.g., "Implement the deferred Medium findings"]
3. [Third priority — e.g., "Add performance benchmarks"]
4. [Optional — e.g., "Consider adding CI/CD pipeline"]
```

Use TaskUpdate to mark Phase 9 as `completed`. Mark all remaining tasks as complete via TaskUpdate.

---

## Error Handling

| Situation | Response |
|---|---|
| **Agent fails or times out** | Retry the agent once with the same inputs. If it fails again, surface the error to the user with full context and ask for direction. |
| **Tests fail during implementation** | The implementer must fix the tests before proceeding. Never skip failing tests. Never move to the next task with broken tests. |
| **Spec reviewer loops 3+ times** | Surface the situation to the user. The spec may be ambiguous or contradictory. Ask for guidance on the specific requirements causing the review loop. |
| **Build breaks after scaffold** | Stop immediately. Report the full error details. Ask the user for direction before continuing. |
| **Deploy fails** | Report the error with full output. Offer the user two options: retry deployment, or skip deployment and continue to summary. |
| **User rejects a checkpoint** | Return to the current phase. Revise based on the user's feedback. Re-execute the relevant parts of the phase. Re-present the checkpoint. |

---

## Phase Skip Logic

| Condition | What Gets Skipped |
|---|---|
| **Existing codebase** (`context.setup.project_type == "existing"`) | Phase 4 (Scaffolding) is skipped entirely. |
| **User chose "skip deployment"** (`context.setup.deploy_target == "skip"`) | Phase 8 skips the deploy step (git branch completion still runs if git is managed). |
| **New project** (`context.setup.project_type == "new"`) | Phase 1 skips the exploration agents (no codebase to explore). Clarifying questions are still asked. |
| **Git not managed** (`context.setup.git_managed == false`) | All git operations throughout all phases are skipped: no branch creation, no commits, no branch completion, no PRs. |

---

## Rules

1. **Execute phases in order.** Never skip ahead. Never run phases in parallel.
2. **Honor checkpoints.** Wait for explicit user approval at every checkpoint. Do not auto-advance.
3. **Fresh agents.** Dispatch a new agent instance for each task. Do not reuse agents across tasks.
4. **Parallel where specified.** Use agent teams (parallel dispatch) only where this document specifies. Implementation tasks are always sequential.
5. **Evidence over claims.** Apply the verification skill before claiming any status. Run the command, read the output, then make the claim.
6. **Respect git preferences.** If the user opted out of git management, do not touch git. Not once. Not for any reason.
7. **Respect skip logic.** Check the conditions in the Phase Skip Logic table before starting each phase.
8. **Maintain context.** Update the project context object after every phase. Later phases depend on earlier context being accurate and complete.
