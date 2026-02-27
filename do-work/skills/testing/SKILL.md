---
name: testing
description: Generates additional tests, analyzes coverage, and fills gaps using test-engineer agent teams.
---

# Testing

## Purpose

After implementation, generate additional tests to fill coverage gaps. Dispatch parallel test-engineer agents to cover unit, integration, and end-to-end layers. Consolidate results into a comprehensive test suite with measurable coverage.

## Process

### 1. Dispatch Test-Engineer Agent Team

Launch 2-3 `do-work:test-engineer` agents in parallel, each targeting a different testing layer:

**Engineer A — Unit Test Gaps + Edge Cases:**
"Analyze the implemented code for {spec}. Identify every function, method, and branch that lacks test coverage. Write unit tests for: uncovered branches, boundary conditions, error paths, null/empty/invalid inputs, type edge cases. Follow TDD skill conventions. One behavior per test."

**Engineer B — Integration Tests:**
"Write integration tests for {spec} that verify component interactions. Test: module boundaries, data flow between layers, API contract adherence, database interactions (if applicable), service-to-service communication. Focus on the seams where components meet."

**Engineer C — E2E / Happy Path:**
"Write end-to-end tests for {spec} covering critical user flows. Test: primary happy paths, the most common user journeys, form submissions and validations, navigation flows, authentication flows (if applicable). Use the appropriate E2E framework for the stack."

### 2. Consolidate Results

After all engineers return:
1. Read each test file produced
2. Remove duplicate tests across agents (keep the more thorough version)
3. Resolve naming conflicts and ensure consistent test organization
4. Verify all tests follow project conventions (file locations, naming patterns, setup/teardown)

### 3. Run Full Test Suite

Execute the complete test suite including all new tests:
```bash
# Use the appropriate command for the stack
npm test          # Node.js / React
pytest            # Python
cargo test        # Rust
go test ./...     # Go
```

Fix any failing tests before proceeding. Apply verification skill — read the full output, count passes and failures, check exit code.

### 4. Coverage Report

Generate a coverage report using the appropriate tool for the stack:

| Stack | Tool | Command |
|-------|------|---------|
| Node.js / React | c8 / istanbul / jest --coverage | `npm test -- --coverage` |
| Python | coverage.py / pytest-cov | `pytest --cov --cov-report=term-missing` |
| Rust | cargo-tarpaulin | `cargo tarpaulin` |
| Go | go test -cover | `go test -coverprofile=coverage.out ./...` |

Collect metrics across four dimensions:
- **Statements**: % of statements executed
- **Branches**: % of conditional branches covered
- **Functions**: % of functions called
- **Lines**: % of lines executed

### Checkpoint

Present to user:

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

Proceed to review?
```

Wait for user acknowledgment before continuing.
