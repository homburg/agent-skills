---
name: jj-stacked-prs
description: "Creates stacked pull requests using native jj commands. Triggers on: stacked PRs, push PRs, create PR, land PR in repos with .jj/ directory."
---

# Stacked Pull Requests with Jujutsu

Create and manage stacked PRs using native `jj` commands with bookmarks.

## Quick Reference

| Task | Command |
|------|---------|
| Create bookmark for change | `jj bookmark create <name> -r <change-id>` |
| Push new bookmark | `jj git push --bookmark <name> --allow-new` |
| Push existing bookmark | `jj git push --bookmark <name>` |
| Push all bookmarks in stack | `jj git push --bookmark <name1> --bookmark <name2>` |
| List bookmarks | `jj bookmark list` |

## Creating Stacked PRs

### Step 1: Build Your Stack

Create commits in sequence:

```bash
jj new main -m "feat: first change"
# make changes
jj new -m "feat: second change"  
# make changes
jj new -m "feat: third change"
# make changes
jj new  # empty working copy on top
```

### Step 2: Add Bookmarks to Each Change

View your stack:
```bash
jj log
```

Example output:
```
@  tqywxrtz  (empty) (no description set)
○  mlwzqkqt  feat: third change
○  zmnynpqk  feat: second change  
○  utqmytlw  feat: first change
○  main
```

Create bookmarks for each change:
```bash
jj bookmark create pr/first-change -r utqmytlw
jj bookmark create pr/second-change -r zmnynpqk
jj bookmark create pr/third-change -r mlwzqkqt
```

### Step 3: Push All Bookmarks

```bash
jj git push --bookmark pr/first-change --bookmark pr/second-change --bookmark pr/third-change --allow-new
```

### Step 4: Create PRs on GitHub

Use `gh` CLI to create stacked PRs:

```bash
# First PR targets main
gh pr create --head pr/first-change --base main --title "feat: first change"

# Second PR targets first PR's branch
gh pr create --head pr/second-change --base pr/first-change --title "feat: second change"

# Third PR targets second PR's branch
gh pr create --head pr/third-change --base pr/second-change --title "feat: third change"
```

## Updating Changes

When you need to update a change in the stack:

```bash
# Edit the change directly
jj edit <change-id>
# make changes
jj new  # return to tip

# Or squash from working copy
jj squash --into <change-id>
```

Descendants automatically rebase. Then push updated bookmarks:
```bash
jj git push --bookmark pr/first-change --bookmark pr/second-change --bookmark pr/third-change
```

## Landing PRs

### Land in Order (Recommended)

1. Merge first PR on GitHub (squash or rebase)
2. Fetch and rebase:
   ```bash
   jj git fetch
   jj rebase -d main
   ```
3. Update remaining PRs' base branches on GitHub
4. Push updated bookmarks:
   ```bash
   jj git push --bookmark pr/second-change --bookmark pr/third-change
   ```
5. Repeat for next PR

### After Landing

Delete merged bookmarks:
```bash
jj bookmark delete pr/first-change
jj git push --bookmark pr/first-change --deleted
```

## Tips

### Bookmark Naming Convention

Use prefixes for organization:
- `pr/feature-name` - for PRs
- `wip/experiment` - for work in progress

### View Stack with Bookmarks

```bash
jj log -r 'ancestors(@, 10) & bookmarks()'
```

### Rebase Entire Stack on Latest Main

```bash
jj git fetch
jj rebase -d main -s <first-change-id>
jj git push --bookmark pr/first --bookmark pr/second --bookmark pr/third
```

### Quick Push Current Change

```bash
jj git push --change @-
```

This auto-creates a bookmark named `push-<change-id>` and pushes it.
