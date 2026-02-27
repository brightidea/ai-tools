---
name: planning
description: Breaks the chosen architecture into bite-sized, TDD-driven implementation tasks with exact file paths and commands.
---

# Implementation Planning

## Purpose

Transform the approved architecture blueprint into a step-by-step implementation plan. Each task must be small, independent, ordered by dependency, and executable through strict TDD.

## Process

### 1. Read the Blueprint

Read the approved architecture document. Extract:
- Component list with responsibilities
- File map (every file to create or modify)
- Data flow and integration points
- Testing approach
- Dependency order between components

### 2. Decompose into Tasks

Break the blueprint into the smallest possible implementation units. Each task must be:

- **Independent**: Completable without waiting on unfinished tasks (may depend on completed ones)
- **Small**: One behavior, one component, one integration point. If a task takes more than 15-20 minutes, split it further.
- **Ordered by dependency**: Foundation types and utilities first, then core logic, then integration, then UI/API surfaces.
- **Testable**: Every task must have clear success criteria that can be verified with automated tests.

### 3. Define Each Task

Every task in the plan must include ALL of the following:

#### File Paths

Exact paths for every file involved. No ambiguity.

- **Create**: Files that do not exist yet. Full path from project root.
- **Modify**: Files that exist and will be changed. Full path from project root.
- **Test**: Test files to create or update. Full path from project root.

#### TDD Steps

Each task specifies the Red-Green-Refactor cycle:

1. **Write the failing test**: Complete test code — not a description, the actual code. The test must capture the required behavior.
2. **Run to verify failure**: Exact command to run (e.g., `npm test -- --grep "task name"`, `pytest tests/test_module.py::test_function`). The test must fail for the right reason.
3. **Write minimal implementation**: Complete production code — not pseudocode, the actual code. Only enough to make the test pass.
4. **Run to verify pass**: Same command as step 2. The test must pass. Run the full suite to check for regressions.
5. **Commit**: `git add <specific files> && git commit -m "<type>: <description>"`

#### Acceptance Criteria

Bullet list of what must be true when the task is complete. These are the spec-reviewer's checklist.

### 4. Save the Plan

Save the plan to `docs/plans/YYYY-MM-DD-<feature-name>.md` where:
- `YYYY-MM-DD` is today's date
- `<feature-name>` is a kebab-case name derived from the feature

### 5. Create Task Entries

Use TaskCreate to add each task in the plan. Include:
- Task number and title as the subject
- File paths and acceptance criteria in the description
- Tasks ordered by dependency

## Plan Structure

```markdown
# Implementation Plan: [Feature Name]

**Date**: YYYY-MM-DD
**Blueprint**: [Reference to approved blueprint]
**Total Tasks**: [N]

## Task 1: [Title]

**Files:**
- Create: `src/types/widget.ts`
- Test: `tests/types/widget.test.ts`

**TDD Steps:**

1. Write failing test:
\`\`\`typescript
// tests/types/widget.test.ts
[complete test code]
\`\`\`

2. Run: `npm test -- tests/types/widget.test.ts`
   Expected: FAIL (Widget type not found)

3. Implement:
\`\`\`typescript
// src/types/widget.ts
[complete implementation code]
\`\`\`

4. Run: `npm test -- tests/types/widget.test.ts`
   Expected: PASS

5. Commit: `git add src/types/widget.ts tests/types/widget.test.ts && git commit -m "feat: add Widget type"`

**Acceptance Criteria:**
- [ ] Widget type exported from `src/types/widget.ts`
- [ ] All required properties defined with correct types
- [ ] Test verifies type structure

---

## Task 2: [Title]
[...]
```

## Rules

- **Exact file paths.** Every path must be complete from the project root. No "create a file somewhere in src." The implementer should never have to guess where a file goes.
- **Complete code.** Test code and implementation code must be complete and runnable. No pseudocode, no "implement the logic here" placeholders, no `// TODO` markers.
- **Exact commands.** Every run command must be copy-pasteable. Include flags, file paths, and test filters as needed.
- **DRY.** If multiple tasks share setup or utilities, create a task for the shared code first and list it as a dependency.
- **YAGNI.** Only plan tasks that are required by the blueprint. No "nice to have" tasks, no "while we're at it" additions.
- **TDD.** Every task follows Red-Green-Refactor. No exceptions. If a task cannot be tested (e.g., pure config), explicitly state why and what verification replaces the test.

## Checkpoint

Present the complete plan to the user. Include:
- Total task count
- Dependency order visualization (which tasks depend on which)
- Estimated complexity (simple/medium/complex per task)
- Any assumptions made during planning

**Wait for user approval before proceeding to implementation.**
