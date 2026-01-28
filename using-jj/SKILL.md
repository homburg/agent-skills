---
name: using-jj
description: "Uses Jujutsu (jj) version control instead of git. Triggers on: version control, commits, branches, push, pull, rebase in repos with .jj/ directory."
---

# Jujutsu (jj) Version Control

Use `jj` instead of `git` when the repository contains a `.jj/` directory.

## Key Concepts

- **Working copy auto-commits**: No staging area. All changes are automatically part of the working copy commit (`@`)
- **Bookmarks**: jj's equivalent of git branches. Create with `jj bookmark create`
- **Change IDs**: Short stable identifiers (like `abc123`) that persist across rebases
- **Commit IDs**: SHA hashes that change when commits are rewritten
- **Conflicts are first-class**: You can commit conflicted files and resolve later

## Common Commands

| Task | Command |
|------|---------|
| Status | `jj status` or `jj st` |
| Log | `jj log` |
| Diff | `jj diff` |
| Describe current commit | `jj describe -m "message"` |
| Create new empty commit | `jj new` |
| Commit (describe + new) | `jj commit -m "message"` |
| Edit a previous commit | `jj edit <change-id>` |
| Squash into parent | `jj squash` |
| Split a commit | `jj split` |
| Rebase onto destination | `jj rebase -d <dest>` |
| Abandon a commit | `jj abandon` |
| Undo last operation | `jj undo` |

## Working with Remotes

| Task | Command |
|------|---------|
| Fetch | `jj git fetch` |
| Push bookmark | `jj git push --bookmark <name>` |
| Push new bookmark | `jj git push --bookmark <name> --allow-new` |
| Push current change | `jj git push --change @` |
| Clone | `jj git clone <url>` |
| Init colocated repo | `jj git init --colocate` |

## Bookmarks (Branches)

| Task | Command |
|------|---------|
| List bookmarks | `jj bookmark list` |
| Create bookmark | `jj bookmark create <name>` |
| Move bookmark to @ | `jj bookmark move <name> --to @` |
| Delete bookmark | `jj bookmark delete <name>` |
| Track remote bookmark | `jj bookmark track <name>@origin` |

## Revsets

Use revsets to select commits:

- `@` - Working copy commit
- `@-` - Parent of working copy
- `main` - The main bookmark
- `trunk()` - Main branch (main/master)
- `ancestors(@, 5)` - Last 5 ancestors of @
- `@::` - Working copy and all descendants
- `::@` - Working copy and all ancestors
- `visible_heads()` - All visible head commits

## Workflows

### Squash Workflow (default)
1. Make changes (auto-committed to @)
2. `jj squash` to move changes into parent
3. `jj new` to start fresh working copy

### Edit Workflow
1. `jj new -m "feature"` to create commit
2. `jj edit <change-id>` to resume work on it
3. Changes auto-amend into that commit

### Stacked Changes
1. Create commits: `jj new -m "part 1"`, make changes, `jj new -m "part 2"`
2. Push stack: `jj git push --bookmark feature`
3. Edit any commit: `jj edit <change-id>` - descendants auto-rebase

### Moving Changes into Specific Commits

**`jj squash --into`** — Explicit, works for any changes:
```bash
jj squash --into <change-id> <files>

# Example: move a new file into commit xsnulpzq
jj squash --into xsnulpzq .agents/skills/my-skill/SKILL.md
```
Use when: adding new files/lines, or you know exactly where changes belong.

**`jj absorb`** — Automatic, line-based:
```bash
jj absorb                    # Auto-distribute all changes
jj absorb --into <revset>    # Limit destination commits
```
Use when: modifying existing lines across a stack. jj determines destination by which commit last touched each line. Does NOT work for new files or new lines.

## Operation Log

Every jj command creates an operation. Undo mistakes easily:

```bash
jj op log          # View operation history
jj undo            # Undo last operation
jj op restore <id> # Restore to specific operation
```

## Conflict Resolution

Conflicts don't block operations:

```bash
jj rebase -d main  # May create conflicts, still succeeds
jj resolve         # Open merge tool
jj resolve --list  # List conflicted files
```

Edit conflict markers directly in files - changes auto-save to @.
