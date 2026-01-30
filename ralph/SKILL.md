---
name: ralph
description: "Autonomous feature development - setup and execution. Triggers on: ralph, set up ralph, run ralph, run the loop, implement tasks. Two phases: (1) Setup - chat through feature, create tasks file (2) Loop - pick ready tasks, implement, commit, repeat until done."
---

# Ralph: Autonomous Feature Development

Interactive feature planning and execution using file-based task tracking.

---

## Overview

Ralph uses **markdown files** for task management - no external tools required. Tasks live in `scripts/ralph/tasks.md` with checkbox tracking.

**Two phases:**
1. **Setup** - Chat through feature, create task file with dependencies
2. **Loop** - Pick ready tasks, implement, commit, repeat until done

---

## The Job

**Two modes:**

### Mode 1: New Feature
1. Chat through the feature - Ask clarifying questions
2. Break into small tasks - Each completable in one iteration
3. Create tasks.md file with dependencies
4. Initialize progress.txt

### Mode 2: Existing Tasks
1. Read existing `scripts/ralph/tasks.md`
2. Show status - Which tasks are ready, completed, blocked
3. Continue the loop

**Ask the user which mode they need:**
```
Are you:
1. Starting a new feature (I'll help you plan and create tasks)
2. Continuing existing tasks (I'll pick up where we left off)
```

---

# Phase 1: Feature Setup

## Step 1: Understand the Feature

Start by asking the user about their feature. Don't assume - ASK:

```
What feature are you building?
```

Then ask clarifying questions (3-5 critical ones):
- What's the user-facing goal?
- What parts of the codebase will this touch? (database, UI, API, etc.)
- Are there any existing patterns to follow?
- What should it look like when done?

**Keep asking until you have enough detail to break it into tasks.**

---

## Step 2: Break Into Tasks

**Each task must be completable in ONE Ralph iteration (~one context window).**

Ralph spawns a fresh Amp instance per iteration with no memory of previous work. If a task is too big, the LLM runs out of context before finishing.

### Right-sized tasks:
- Add a database column + migration
- Create a single UI component
- Implement one server action
- Add a filter to an existing list
- Write tests for one module

### Too big (split these):
- "Build the entire dashboard" → Split into: schema, queries, components, filters
- "Add authentication" → Split into: schema, middleware, login UI, session handling
- "Refactor the API" → Split into one task per endpoint

**Rule of thumb:** If you can't describe the change in 2-3 sentences, it's too big.

---

## Step 3: Order by Dependencies

Tasks execute in order. Earlier tasks must complete before dependent ones start.

**Typical order:**
1. Schema/database changes (migrations)
2. Server actions / backend logic  
3. UI components that use the backend
4. Integration / E2E tests

Use `dependsOn: [task-number]` comments to express dependencies for parallel tasks.

---

## Step 4: Create the Tasks File

Create `scripts/ralph/tasks.md` with this structure:

```markdown
# Feature: [Feature Name]

[One-line description of the feature]

## Relevant Files

- `path/to/file1.ts` - Brief description
- `path/to/file2.tsx` - Brief description

## Notes

- Project-specific notes (e.g., "Use npm run typecheck to verify")
- Patterns to follow

---

## Tasks

- [ ] 1.0 [First Parent Task Title]
  - [ ] 1.1 [Sub-task description]
    
    **What to do:**
    - Specific implementation steps
    - Files to create/modify
    
    **Acceptance criteria:**
    - Specific, verifiable outcomes
    - npm run typecheck passes
    
  - [ ] 1.2 [Sub-task description]
    
    **What to do:**
    - Implementation steps
    
    **Acceptance criteria:**
    - Outcomes to verify

- [ ] 2.0 [Second Parent Task Title] (dependsOn: 1.0)
  - [ ] 2.1 [Sub-task description]
    
    **What to do:**
    - Implementation steps
    
    **Acceptance criteria:**
    - Outcomes to verify
```

### Task Description Format

Write descriptions that a future Ralph iteration can pick up without context:

```markdown
- [ ] 3.1 Implement category name to ID mapping for expenses
  
  **What to do:**
  - Create function mapExpenseCategoryNameToId(name, isChildExpense)
  - Query item_category table with category_type filter
  - Add alias mapping for common synonyms (rent → Rent or Mortgage)
  
  **Files:**
  - workflows/tools/upsert-expense.ts
  
  **Acceptance criteria:**
  - Function returns category ID for valid names
  - Returns null for unknown categories
  - npm run typecheck passes
  
  **Notes:**
  - Follow pattern from upsert-income.ts
  - EXPENSE type for family, CHILD_EXPENSE for child
```

---

## Step 5: Initialize Progress Tracking

Create/reset `scripts/ralph/progress.txt`:

```markdown
# Ralph Progress Log
Started: [current date]
Feature: [feature name from tasks.md]

## Codebase Patterns
(Patterns discovered during this feature build)

---
```

If progress.txt already has content from a previous feature, archive it first:

```bash
DATE=$(date +%Y-%m-%d)
FEATURE="previous-feature-name"
mkdir -p scripts/ralph/archive/$DATE-$FEATURE
mv scripts/ralph/progress.txt scripts/ralph/archive/$DATE-$FEATURE/
```

---

## Step 6: Confirm Setup

Show the user what was created:

```
✅ Ralph is ready!

**Feature:** [title]
**Tasks file:** scripts/ralph/tasks.md

**Tasks:**
1.0 [Parent Task 1] - ready
  1.1 [Sub-task] - ready  
  1.2 [Sub-task] - blocked by 1.1
2.0 [Parent Task 2] - blocked by 1.0
  2.1 [Sub-task] - blocked by 2.0

**To run Ralph:** Tell me "run ralph" or "continue the loop"
```

---

# Phase 2: The Execution Loop

Once setup is complete, Ralph runs the autonomous loop to implement tasks one by one.

---

## Loop Workflow

### 0. Read the Tasks File

```bash
cat scripts/ralph/tasks.md
```

If this file doesn't exist, ask the user to set up Ralph first.

### 1. Find Ready Tasks

Scan the tasks.md file for tasks that are:
- Unchecked (`- [ ]`)
- Have no unchecked dependencies (earlier numbered tasks are complete, or no dependsOn)
- Are leaf tasks (sub-tasks like 1.1, 1.2, not parent tasks like 1.0)

**Dependency rules:**
- Sub-tasks within a parent execute in order (1.1 before 1.2)
- Parent tasks with `(dependsOn: X.0)` wait for all of X.0's sub-tasks
- Tasks without dependsOn can run immediately

### 2. If No Ready Tasks

Check if all tasks are completed (all checkboxes marked `[x]`):

If **all complete**:
1. Archive the feature:
   ```bash
   DATE=$(date +%Y-%m-%d)
   FEATURE="feature-name-here"
   mkdir -p scripts/ralph/archive/$DATE-$FEATURE
   mv scripts/ralph/tasks.md scripts/ralph/archive/$DATE-$FEATURE/
   mv scripts/ralph/progress.txt scripts/ralph/archive/$DATE-$FEATURE/
   ```
2. Commit: `git add scripts/ralph && git commit -m "chore: archive ralph progress for [feature-name]"`
3. Stop and report "✅ Build complete - all tasks finished!"

If **some are blocked**: Report which tasks are blocked and why.

### 3. If Ready Tasks Exist

**Pick the next task:**
- First ready sub-task in document order
- Prefer tasks in the same area as just-completed work

**Execute the task:**

Use the `handoff` tool with this goal:

```
Implement and verify task [task-number]: [task-title].

[Copy the full task description from tasks.md including What to do, Files, Acceptance criteria, Notes]

FIRST: Read scripts/ralph/progress.txt - check the "Codebase Patterns" section for important context from previous iterations.

When complete:

1. Run quality checks (as specified in tasks.md, typically `npm run typecheck` and `npm test`)
   - If either fails, FIX THE ISSUES and re-run until both pass
   - Do NOT proceed until quality checks pass

2. Mark the task complete in scripts/ralph/tasks.md:
   - Change `- [ ] X.X` to `- [x] X.X`
   - This is critical for tracking progress

3. Update scripts/ralph/progress.txt (APPEND, never replace):
   ```
   ## [Date] - Task [X.X]: [Task Title]
   Thread: [current thread URL]
   - What was implemented
   - Files changed
   - **Learnings for future iterations:**
     - Patterns discovered
     - Gotchas encountered
   ---
   ```

4. If you discovered a reusable pattern for THIS FEATURE, add it to the "## Codebase Patterns" section at the TOP of progress.txt

5. Update AGENTS.md files if you learned something important:
   - Add learnings that future developers/agents should know
   - This is LONG-TERM memory - things anyone editing this code should know

6. Commit all changes with message: `feat: [Task Title]`

7. Invoke the ralph skill to continue the loop
```

---

## Progress File Format

```markdown
# Ralph Progress Log
Started: [date]
Feature: [feature name]

## Codebase Patterns
(Patterns discovered during this feature build)
- Pattern 1: Description
- Pattern 2: Description

---

## [Date] - Task 1.1: [Task Title]
Thread: https://ampcode.com/threads/[thread-id]
- What was implemented
- Files changed
- **Learnings for future iterations:**
  - Patterns discovered
  - Gotchas encountered
---

## [Date] - Task 1.2: [Task Title]
...
```

---

## Task Discovery

While working, **add new tasks** when you discover:
- Failing tests or test gaps
- Code that needs refactoring
- Missing error handling
- Documentation gaps
- TODOs or FIXMEs in the code
- Build/lint warnings

Add them to `scripts/ralph/tasks.md` at the appropriate location with proper numbering.

---

## Browser Verification

For UI tasks, specify the right verification method in acceptance criteria:

**Functional testing** (checking behavior):
```
Use Chrome DevTools MCP with take_snapshot to read page content
```
- `take_snapshot` returns the a11y tree as text

**Visual testing** (checking appearance):
```
Use take_screenshot to capture and verify visual appearance
```

---

## Quality Requirements

Before marking any task complete:
- Quality checks (typecheck, test, lint) must pass
- Changes must be committed
- Task checkbox must be marked `[x]`
- Progress must be logged

---

## Stop Condition

When no ready tasks remain AND all tasks are completed:
1. Output: "✅ Build complete - all tasks finished!"
2. Summarize what was accomplished
3. Archive the feature files

---

## Example Conversation

**User:** set up ralph for adding expense tracking

**Assistant:** What feature are you building?

**User:** I want Grace to create, update, and delete expenses when users mention them in conversation.

**Assistant:** Got it - an expense upsert tool. A few questions:

1. Are there existing tools to follow as a pattern?
2. Do expenses have different types (family vs child)?
3. Should it also list expenses or just CRUD?

**User:** Follow upsert-income.ts. Yes family and child expenses. Yes list too.

**Assistant:** Here's my proposed breakdown:

1.0 **Create tool skeleton** - Zod schema, basic structure
2.0 **Category mapping** - Map names to category IDs
3.0 **Amount parsing** - Handle currency formats
4.0 **Create expenses** - Insert into expense tables
5.0 **Update action** - Modify existing expenses
6.0 **Delete action** - Remove expenses
7.0 **List action** - Show expenses with totals
8.0 **Register tool** - Add to workflow
9.0 **Tests** - Unit and E2E tests

Does this look right? Any tasks to add or remove?

**User:** Looks good, create the tasks

**Assistant:** [Creates scripts/ralph/tasks.md and scripts/ralph/progress.txt]

✅ Ralph is ready!

**Feature:** Grace Expense Upsert Tool
**Tasks:** 9 parent tasks with sub-tasks

**To run:** Tell me "run ralph" or "continue the loop"

---

## Checklist Before Creating Tasks

- [ ] Chatted through feature to understand scope
- [ ] Each task completable in one iteration (small enough)
- [ ] Tasks ordered by dependency (schema → backend → UI → tests)
- [ ] Every task has quality check requirement in acceptance criteria
- [ ] UI tasks have browser verification in acceptance criteria
- [ ] Descriptions have enough detail for Ralph to implement without context
- [ ] scripts/ralph/tasks.md created
- [ ] scripts/ralph/progress.txt initialized

---

## Important Notes

- Tasks are tracked in `scripts/ralph/tasks.md` with checkboxes
- Always mark tasks `[x]` when complete - this is how Ralph tracks progress
- Each handoff runs in a fresh thread with clean context
- progress.txt is the memory between iterations - keep it updated
- The handoff goal MUST include instructions to mark the task complete, update progress.txt, commit, and re-invoke this skill
