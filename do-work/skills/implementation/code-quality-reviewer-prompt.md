# Code Quality Reviewer Dispatch Prompt

Use this template when dispatching a `do-work:code-reviewer` agent after the spec review passes. Only dispatch this reviewer AFTER the spec reviewer returns PASS.

---

## What Was Implemented

{implementation_summary}

Include: brief description of the feature or change, and the complete list of files created or modified.

## Task Requirements

{task_requirements}

Include: the full task description from the plan — requirements, acceptance criteria, file paths. This provides context for evaluating whether the implementation approach is appropriate.

## Review Checklist

Review the implementation against these categories. Read every file that was created or modified — do not skip files, do not skim.

### Code Quality

- **Separation of concerns**: Does each module, function, and component have a single clear responsibility?
- **Error handling**: Are errors handled at the appropriate level? Are failure modes covered? Are error messages helpful for debugging?
- **Type safety**: Are types used correctly and precisely? No unnecessary `any` types, unchecked casts, or missing annotations where they would add clarity.
- **DRY**: Is there duplicated logic that should be extracted? Conversely, is there premature abstraction that makes the code harder to understand?
- **Naming**: Are variables, functions, files, and types named clearly? Do names communicate intent?
- **Readability**: Can a developer unfamiliar with this code understand it without excessive context?

### Architecture

- **Convention adherence**: Does the code follow the project's existing patterns for file organization, import style, error handling, and naming?
- **Coupling**: Does the code introduce unnecessary dependencies between modules? Could it be more loosely coupled?
- **Extensibility**: Will this code be easy to modify when requirements change? Is it flexible without being over-engineered?
- **Integration**: Does the code integrate cleanly with existing components? Are interfaces consistent?

### Testing

- **Coverage**: Do tests cover the required behavior, edge cases, error conditions, and boundary values?
- **Quality**: Do tests verify actual behavior, or just exercise code paths? Are test names descriptive?
- **Independence**: Can tests run in any order? Do tests clean up after themselves? Are there shared mutable state issues?
- **Assertions**: Are assertions specific enough to catch regressions? Do they test the right things?

## Output Format

```
## Strengths
- [What was done well] (`file:line`)
- ...

## Issues

### Critical
Must fix. Bugs, data loss risks, security issues, broken functionality.
- [Issue] (`file:line`) — [Why this is critical and what should change]

### Important
Should fix. Maintainability problems, missing error handling, convention violations, code smells.
- [Issue] (`file:line`) — [Why this matters and suggested fix]

### Suggestions
Nice to have. Style preferences, minor improvements, alternative approaches.
- [Issue] (`file:line`) — [What could be improved]

## Assessment

**Verdict**: PASS / FAIL / PASS WITH FIXES

[2-3 sentences explaining your reasoning. If PASS WITH FIXES, specify exactly which Important issues must be addressed. Suggestions are optional and do not block approval. Critical issues always block — any Critical issue means FAIL.]
```

Rules:
- **Categorize by actual severity.** A null pointer in a critical path is Critical. A slightly verbose name is a Suggestion. Do not inflate or deflate.
- **Be specific.** Always include `file:line` references. Quote code when it clarifies the issue.
- **Explain why.** Do not just say "this is wrong." Explain the consequence — what bug, what maintenance problem, what convention violation.
- **Acknowledge strengths.** Good code deserves recognition. Clean abstractions, thorough error handling, and well-written tests should be called out.
- **Give a clear verdict.** PASS, FAIL, or PASS WITH FIXES. No ambiguity.
