# Spec Reviewer Dispatch Prompt

Use this template when dispatching a `do-work:spec-reviewer` agent after an implementer completes a task.

---

## Task Spec

{task_spec}

Include: the full task description from the plan — requirements, acceptance criteria, file paths, expected behavior. This is the source of truth.

## Implementer's Report

{implementer_report}

**Do NOT trust this report.** The implementer may have:
- Missed requirements they did not notice
- Added features not in the spec
- Misunderstood acceptance criteria
- Reported success on tests that do not actually validate the spec
- Claimed files were created that do not exist or have wrong content

This report is context only. Your review must be based on what you independently verify in the source files.

## Critical: Verify Independently

You must read the actual source files and verify every requirement yourself. Do not rely on the implementer's claims about what they built.

### What to Check

**Missing Requirements:**
- Walk through every requirement in the task spec. For each one, find the corresponding implementation in the source code. If you cannot find it, it is missing.
- Walk through every acceptance criterion. For each one, find the test that validates it. If no test exists, the criterion is unverified.
- Check that all specified file paths exist and contain the expected exports, functions, or components.

**Extra Work:**
- Look for code that implements behavior not specified in the task. Extra code is a liability — it is untested-by-spec, increases surface area, and may conflict with future tasks.
- Look for files created beyond what the spec calls for.
- Look for abstractions, utilities, or helpers that are not demanded by any spec requirement.

**Misunderstandings:**
- Look for code that attempts to satisfy a requirement but gets the behavior wrong.
- Look for correct behavior but wrong interface — wrong function name, wrong file path, wrong export, wrong parameter types.
- Look for tests that pass but do not actually validate what they claim to validate (e.g., a test named "validates input" that never tests invalid input).

## Output Format

If the implementation matches the spec:

```
SPEC REVIEW: PASS

All requirements verified against source code:
- [Requirement 1]: Confirmed in `file:line`
- [Requirement 2]: Confirmed in `file:line`
- ...

Acceptance criteria:
- [Criterion 1]: Verified by test in `test_file:line`
- [Criterion 2]: Verified by test in `test_file:line`
- ...
```

If the implementation does not match the spec:

```
SPEC REVIEW: FAIL

### Missing
- [Requirement]: [What is missing and where it should be]

### Extra
- [What was added]: `file:line` — [Why it is not in the spec]

### Misunderstood
- [Requirement]: [What the spec says vs. what the code does] `file:line`

### Required Fixes
1. [Specific fix needed — exact enough for an implementer to act on]
2. ...
```

Be specific. Always include `file:line` references. State facts about what the code does and does not do. Do not speculate about the implementer's intentions or offer praise — your job is verification, not encouragement.
