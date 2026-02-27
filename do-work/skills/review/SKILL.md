---
name: review
description: Multi-agent quality gate. Dispatches code-reviewer, security-auditor, and performance-reviewer in parallel. Consolidates and prioritizes findings.
---

# Review

## Purpose

Final quality gate before deployment. Dispatch parallel review agents covering code quality, security, and performance. Consolidate findings, prioritize by severity, fix critical issues, and verify fixes.

## Process

### 1. Dispatch Review Agent Team

Launch 3-4 agents in parallel:

**Code Reviewer — Quality & Conventions:**
"Review the implementation of {spec}. Check: code quality, DRY violations, naming conventions, consistent patterns, error handling completeness, documentation gaps, dead code, overly complex functions (cyclomatic complexity), proper use of language idioms. Rate each finding by severity."

**Security Auditor — OWASP & Vulnerabilities:**
"Perform a security audit of {spec}. Check against OWASP Top 10: injection flaws (SQL, XSS, command), broken authentication, sensitive data exposure, XML external entities, broken access control, security misconfiguration, insecure deserialization, known vulnerable dependencies, insufficient logging. Also check: secrets in code, hardcoded credentials, insecure defaults, missing input validation, missing rate limiting, CSRF protection."

**Performance Reviewer — Bottlenecks & Optimization:**
"Review {spec} for performance issues. Check: N+1 queries, unbounded loops, missing pagination, unnecessary re-renders (React), memory leaks, missing indexes (database), synchronous operations that should be async, large bundle sizes, unoptimized images/assets, missing caching opportunities, expensive computations in hot paths."

**Test Engineer (optional) — Test Quality:**
"Review test quality for {spec}. Check: flaky tests (timing, ordering dependencies), missing assertions, tests that test implementation rather than behavior, missing edge cases, test isolation (shared state), test readability, mock overuse hiding real bugs."

### 2. Consolidate Findings

After all reviewers return:
1. Read each review report
2. Deduplicate findings that overlap between reviewers
3. Sort all findings by severity:

| Priority | Label | Action |
|----------|-------|--------|
| 1 | **Critical** | Must fix before deployment. Security vulnerabilities, data loss risks, crashes. |
| 2 | **Important / High** | Should fix before deployment. Bugs, significant quality issues, performance problems. |
| 3 | **Medium** | Fix if time allows. Code quality improvements, minor optimizations. |
| 4 | **Suggestions / Low** | Nice to have. Style preferences, optional refactors, documentation improvements. |

### 3. Fix Critical + Important Issues

Address all Critical and Important findings:
1. Fix each issue
2. Apply verification skill before claiming any issue is fixed — run the relevant command, read the output, confirm the fix
3. Do not mark a finding as resolved without evidence

### 4. Re-Run Tests

After all fixes are applied, run the full test suite:
- All existing tests must still pass
- No regressions introduced by fixes
- Apply verification skill — read the full output, check exit code

### Checkpoint

Present to user:

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

Wait for user acknowledgment before continuing.
