---
name: design
description: Explores architecture approaches using agent teams, synthesizes trade-offs, and recommends an approach for user approval.
---

# Architecture Design

## Purpose

Explore multiple architecture approaches in parallel, compare trade-offs, and get user approval on the chosen direction.

## Process

### 1. Dispatch Architecture Agent Team

Launch 2-3 `do-work:code-architect` agents in parallel, each given:
- The requirements spec from Phase 1
- Codebase findings from exploration agents (if existing project)
- A specific approach to optimize for

**Architect A — Minimal Approach:**
"Design an architecture for {spec} that minimizes changes. Maximum reuse of existing code, fewest new files, smallest footprint. Provide: component design, file map, data flow, trade-offs, implementation order."

**Architect B — Clean Architecture:**
"Design an architecture for {spec} that prioritizes maintainability and elegant abstractions. Introduce new patterns where they improve the codebase. Provide: component design, file map, data flow, trade-offs, implementation order."

**Architect C — Pragmatic Balance:**
"Design an architecture for {spec} that balances speed with quality. Reuse where sensible, new patterns only when clearly beneficial. Provide: component design, file map, data flow, trade-offs, implementation order."

### 2. Synthesize Results

After all architects return:
1. Read each blueprint
2. Compare approaches across dimensions:
   - Complexity (files to create/modify)
   - Maintainability (how easy to evolve)
   - Risk (what could go wrong)
   - Speed (how fast to implement)
3. Form a recommendation with clear reasoning

### 3. Present to User

```
## Architecture Options

### Option A: Minimal
[2-3 sentence summary]
- Pros: [key advantages]
- Cons: [key disadvantages]
- Files: [N] new, [N] modified

### Option B: Clean Architecture
[2-3 sentence summary]
- Pros: [key advantages]
- Cons: [key disadvantages]
- Files: [N] new, [N] modified

### Option C: Pragmatic
[2-3 sentence summary]
- Pros: [key advantages]
- Cons: [key disadvantages]
- Files: [N] new, [N] modified

## Recommendation: [Option X]
[Why this option is best for this specific situation]
```

### 4. Detail Chosen Approach

After user selects an approach, present the full blueprint:
- Component design with responsibilities and interfaces
- Complete file map (every file to create or modify)
- Data flow diagram (entry points through transformations to output)
- Error handling strategy
- Testing approach

### Checkpoint

Present detailed blueprint. Wait for user approval before planning.
