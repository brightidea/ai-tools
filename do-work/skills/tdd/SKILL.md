---
name: tdd
description: Red-green-refactor discipline for implementation agents. Enforces test-first development.
---

# Test-Driven Development

## The Iron Law

No production code without a failing test first.

Write code before the test? Delete it. Start over. No exceptions.

This is not a guideline. This is the rule. Every line of production code exists to make a previously failing test pass. If you catch yourself writing implementation before a test failure demanded it, stop immediately, delete the code, and write the test first.

## Red-Green-Refactor Cycle

### RED -- Write Failing Test

Write one test that describes desired behavior:
- One behavior per test
- Clear name that describes what's being tested
- Real code, not mocks (unless testing at a boundary)

Run the test. Verify it FAILS. Verify it fails for the RIGHT reason:
- Missing function or module = correct failure
- Wrong return value = correct failure
- Syntax error = wrong failure (fix the test)
- Import error from misconfiguration = wrong failure (fix the setup)

If the test passes immediately, it is not testing new behavior. Rewrite it or move on.

### GREEN -- Minimal Code

Write the simplest code to make the test pass:
- Don't add features beyond what the test needs
- Don't refactor yet
- Don't "improve" surrounding code
- Don't handle edge cases that aren't tested yet
- Don't build abstractions prematurely

Run the test. Verify it PASSES. Run ALL tests. Verify nothing else broke. If other tests fail, fix the regression before moving forward.

### REFACTOR -- Clean Up

After green only:
- Remove duplication
- Improve names
- Extract helpers if needed
- Simplify logic
- Consolidate related code

Keep tests green after every change. If a refactor breaks a test, undo it and try a different approach. Never refactor on red.

### Repeat

Next failing test for the next behavior. Continue the cycle until all requirements are implemented.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. The test takes 30 seconds to write. Bugs in "simple" code waste hours to debug. |
| "I'll test after" | Tests written after implementation confirm what you built, not what you should have built. Tests that pass immediately prove nothing. |
| "Need to explore first" | Fine. Spike it. Then throw away the spike and start over with TDD. Exploration code is not production code. |
| "TDD will slow me down" | TDD is faster than debugging. The time you "save" skipping tests you spend tenfold on finding and fixing bugs later. |

## Verification Checklist

Before marking work complete:
- [ ] Every new function has a corresponding test
- [ ] Watched each test fail before writing the implementation
- [ ] Wrote minimal code to pass each test -- nothing extra
- [ ] All tests pass (ran the full suite, read the output)
- [ ] Output is clean -- no warnings, no skipped tests, no partial failures
