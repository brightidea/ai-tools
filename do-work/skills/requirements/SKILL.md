---
name: requirements
description: Gathers requirements through clarifying questions, explores existing codebases with agent teams, and produces a structured spec.
---

# Requirements Gathering

## Purpose

Understand what needs to be built before designing or coding anything.

## Process

### 1. Starting Point

Take the user's description from `/dowork` arguments. If no arguments, ask:
- "What do you want to build?"
- "What problem does this solve?"

### 2. Codebase Exploration (Existing Projects Only)

Dispatch `do-work:code-explorer` agent team (2-3 in parallel):

**Explorer A**: "Find features similar to {description} in this codebase. Trace their implementation. Return key patterns and 5-10 critical files."

**Explorer B**: "Map the overall architecture of this codebase — layers, abstractions, data flow, entry points. Return architecture summary and 5-10 critical files."

**Explorer C**: "Identify integration points where {description} would plug in — routes, middleware, hooks, APIs, shared state. Return integration map and 5-10 critical files."

After agents return: read all critical files they identified to build deep context.

### 3. Clarifying Questions

Ask questions ONE AT A TIME. Focus on:

- **Edge cases**: What happens when [X] fails? What if input is empty/huge/malformed?
- **Error handling**: How should errors be displayed? Should operations be retryable?
- **Scope boundaries**: What is explicitly NOT included in this work?
- **Performance**: Any scale requirements? Expected data volume?
- **Auth/permissions**: Who can access this? Any role-based restrictions?
- **UX preferences**: Any specific UI patterns, loading states, or interaction models?

If user says "whatever you think is best" — provide your recommendation and get explicit confirmation.

### 4. Produce Spec

Write a structured requirements document:

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

### Checkpoint

Present the spec. Wait for user approval before proceeding to design.
