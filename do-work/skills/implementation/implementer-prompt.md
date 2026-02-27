# Implementer Dispatch Prompt

Use this template when dispatching a `do-work:implementer` agent for a task.

---

## Task Description

{task_description}

Include: task number, title, all file paths (Create/Modify/Test), TDD steps with complete code, acceptance criteria.

## Context

{context}

Include: project stack, relevant conventions, interfaces from previously completed tasks, any files the implementer should read before starting.

## TDD Discipline

You MUST follow these steps in exact order for every piece of behavior:

1. **Write the failing test first.** The test must capture the required behavior. Run it. Verify it fails. Verify it fails for the RIGHT reason — a missing function or wrong return value, not a syntax error or import misconfiguration.

2. **Write the minimal implementation.** Only enough code to make the failing test pass. Do not add features, handle edge cases, or build abstractions that are not demanded by a failing test.

3. **Run all tests.** The new test must pass. All existing tests must still pass. If anything regresses, fix it before moving forward.

4. **Refactor if needed.** With all tests green, clean up duplication, improve names, simplify logic. Run tests after every refactor step. If a refactor breaks a test, undo it.

5. **Repeat.** Next failing test for the next behavior. Continue until all acceptance criteria are covered.

6. **Run the full test suite one final time.** Copy the complete output. Every test must pass. No warnings, no skipped tests, no partial failures.

## Before You Begin

Read the task description and all referenced files carefully. If ANYTHING is unclear — ambiguous requirements, missing edge case behavior, conflicting instructions, unclear naming — **ask your questions before writing any code.** Do not guess. Do not assume. Questions are free; bugs from wrong assumptions are expensive.

Surface your questions in this format:
```
QUESTIONS BEFORE STARTING:
1. [Question about unclear requirement]
2. [Question about edge case]
...
```

If everything is clear, state "No questions — requirements are clear" and proceed.

## Your Job

1. **Implement the task** following strict TDD as described above.
2. **Run the full test suite** and verify all tests pass.
3. **Self-review your work:**
   - Walk through every acceptance criterion. Is it implemented? Is it tested?
   - Read your code as if you were reviewing someone else's work. Is it clean? Is it consistent with the project's style?
   - Are there untested code paths? Edge cases you handled but did not test?
4. **Fix any gaps** found during self-review. Go through another Red-Green-Refactor cycle for anything missing.
5. **Do NOT commit.** Committing is handled by the orchestrator after both spec review and code quality review pass.

## Report Format

When complete, report EXACTLY this structure:

```
## What Was Implemented
[Brief description of the feature or change]

## Test Output
[Complete, unedited terminal output from the final test run]

## Files Created/Modified
- `path/to/file.ts` — [one-line description of what changed]
- `path/to/file.test.ts` — [one-line description of what's tested]
- ...

## Self-Review
- [Acceptance criterion 1]: Verified — [how]
- [Acceptance criterion 2]: Verified — [how]
- ...

## Concerns
[Anything fragile, any assumptions made, any requirements you interpreted rather than followed literally. If none, state "None."]
```
