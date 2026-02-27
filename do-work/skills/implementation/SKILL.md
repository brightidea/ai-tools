---
name: implementation
description: Executes the plan task-by-task using subagent-driven development. Dispatches implementer agent per task, followed by spec-reviewer and code-quality-reviewer.
---

# Implementation

## Purpose

Execute the approved implementation plan task-by-task. Each task is implemented by a fresh subagent, then independently reviewed for spec compliance and code quality before it is committed and marked complete.

## Core Principle

**Fresh subagent per task + spec review + quality review.**

Every task gets a clean implementer with no accumulated context drift. Every implementation is verified by independent reviewers who do not trust the implementer's self-report. This three-stage pipeline catches bugs, spec drift, and quality issues before they compound.

## Process

### 1. Setup

1. Read the implementation plan from `docs/plans/`.
2. Extract the ordered task list.
3. Use TaskCreate to add each task if not already created during planning.
4. Verify the project baseline is clean (build, lint, tests pass).

### 2. Per-Task Execution (Sequential)

For each task in dependency order:

#### a. Mark In Progress

Use TaskUpdate to mark the task as `in_progress`.

#### b. Dispatch Implementer

Launch a `do-work:implementer` agent using the prompt template in `./implementer-prompt.md`.

Provide:
- The full task description from the plan (file paths, TDD steps, acceptance criteria)
- Relevant context (project stack, conventions, related files)
- Any accumulated context from previous tasks (what was built, what interfaces exist)

**Handle questions:** If the implementer surfaces questions about ambiguous requirements, pause and either:
- Answer from the spec/blueprint if the answer is clear
- Escalate to the user if the answer requires a judgment call

Wait for the implementer to report completion.

#### c. Dispatch Spec Reviewer

Launch a `do-work:spec-reviewer` agent using the prompt template in `./spec-reviewer-prompt.md`.

Provide:
- The task specification (requirements, acceptance criteria, file paths)
- The implementer's report (but instruct the reviewer NOT to trust it)

The spec reviewer independently reads the actual code and verifies every requirement.

**If FAIL:** Feed the spec reviewer's findings back to a new implementer agent. Do not reuse the previous implementer — dispatch a fresh one with the original task plus the reviewer's specific feedback. Re-review after fixes. Loop until the spec reviewer returns PASS.

#### d. Dispatch Code Quality Reviewer

Launch a `do-work:code-reviewer` agent using the prompt template in `./code-quality-reviewer-prompt.md`.

Provide:
- What was implemented (summary and file list)
- The task requirements
- The project's conventions and patterns

The code quality reviewer checks for code quality, architecture fit, and test quality.

**If Critical or Important issues found:** Feed findings back to a new implementer agent. Fix the issues. Re-review. Loop until the code quality reviewer returns a clean verdict (no Critical issues, no Important issues, only Suggestions which are optional).

#### e. Commit

After both reviews pass:

```bash
git add <specific files from task>
git commit -m "<type>: <description>"
```

Use the commit conventions from the git-workflow skill. Commit specific files only — never `git add -A` or `git add .` during implementation.

#### f. Mark Complete

Use TaskUpdate to mark the task as `completed`.

### 3. Repeat

Move to the next task in dependency order. Continue until all tasks are complete.

## Rules

- **Never run implementers in parallel.** Tasks are sequential. Each task may depend on the output of the previous one. Parallel implementation causes merge conflicts and integration failures.
- **Never skip reviews.** Every task gets both a spec review and a quality review. No exceptions, even for "simple" tasks. Simple tasks have simple reviews — the cost is low, the protection is high.
- **Never proceed with unfixed issues.** If a reviewer finds Critical or Important issues, they must be fixed before moving to the next task. Accumulated tech debt from skipped fixes compounds exponentially.
- **Spec review before quality review.** Always. There is no point reviewing code quality if the code does not meet the spec. Fix correctness first, then quality.
- **Fresh agents per task.** Do not reuse an implementer agent across tasks. Context accumulation causes drift — the agent starts making assumptions based on previous tasks instead of reading the current spec carefully.

## No Checkpoint

This phase runs autonomously once started. The review pipeline provides quality gates. The user is not interrupted unless the implementer surfaces a question that cannot be answered from the spec.
