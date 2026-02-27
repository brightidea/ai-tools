---
name: verification
description: Evidence-based completion checking. Ensures tests are actually run and output is read before claiming success.
---

# Verification Before Completion

## The Iron Law

No completion claims without fresh verification evidence.

If you haven't run the verification command in this message, you cannot claim it passes. Memory of a previous run is not evidence. Confidence is not evidence. Only fresh output is evidence.

## The Gate

Before claiming ANY status, walk through all five steps in order:

1. **IDENTIFY**: What command proves this claim? (e.g., `npm test`, `npm run build`, `pytest`)
2. **RUN**: Execute the command right now. Fresh. Complete. No partial runs.
3. **READ**: Read the full output. Check the exit code. Count the failures. Read the error messages.
4. **VERIFY**: Does the output actually confirm the claim you want to make?
   - If NO: state the actual status with evidence from the output
   - If YES: state the claim WITH the evidence that supports it
5. **ONLY THEN**: Make the claim

Skip any step = lying, not verifying.

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test output showing 0 failures, run in this message | "should pass", "passed last time", previous run output |
| Build succeeds | Build output showing exit code 0, run in this message | "linter passed", "no errors in editor" |
| Bug fixed | Reproduction test that now passes, run in this message | "code looks correct", "changed the logic" |
| Requirements met | Line-by-line checklist verified against actual code and output | "tests pass" (tests may not cover all requirements) |

## Red Flags -- STOP

If you catch yourself doing any of these, stop and run The Gate:

- Using the words "should", "probably", "seems to", "likely"
- Feeling satisfied or confident before running the command
- About to commit code without running the test suite
- Trusting an agent's success report without checking the actual output
- Relying on a partial verification ("the unit tests pass" when you need integration tests too)
- Assuming a fix worked because the code change looks correct
- Claiming completion based on what you wrote rather than what you verified

No shortcuts. Run the command. Read the output. Then -- and only then -- claim the result.
