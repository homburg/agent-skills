---
name: importing-skills
description: "Imports skill subdirectories from external repos using git subtree split. Use when adding or updating skills from another GitHub repository."
---

# Importing Skills via Subtree Split

Import a subdirectory from an external Git repository as a subtree in this skills repo.

## Why subtree split?

`git subtree add` only works with entire repos. To import a **subdirectory** (e.g., `skills/agent-device` from a repo), we use `git subtree split` in a temporary clone to extract just that path into a standalone branch, then subtree-add from it.

## Local path convention

Use the full GitHub path as the local directory prefix, like Go imports:

```
github.com/<owner>/<repo>
```

For example, importing from `https://github.com/callstackincubator/agent-device` lands in `./github.com/callstackincubator/agent-device`.

## Adding a new skill from a subdirectory

```bash
# 1. Clone the source repo into a temp directory
TMPDIR=$(mktemp -d)
git clone --no-tags https://github.com/<owner>/<repo>.git "$TMPDIR"

# 2. Split the subdirectory into a standalone branch
git -C "$TMPDIR" subtree split -P <subdirectory-path> -b split-branch

# 3. Add it as a subtree using the full GitHub path
git subtree add --prefix=github.com/<owner>/<repo> "$TMPDIR" split-branch --squash

# 4. Clean up
rm -rf "$TMPDIR"
```

### Example

Import `skills/agent-device` from `https://github.com/callstackincubator/agent-device`:

```bash
TMPDIR=$(mktemp -d)
git clone --no-tags https://github.com/callstackincubator/agent-device.git "$TMPDIR"
git -C "$TMPDIR" subtree split -P skills/agent-device -b split-branch
git subtree add --prefix=github.com/callstackincubator/agent-device "$TMPDIR" split-branch --squash
rm -rf "$TMPDIR"
```

## Adding a whole repo (no subdirectory)

Skip the clone+split and use `git subtree add` directly:

```bash
git subtree add --prefix=github.com/<owner>/<repo> https://github.com/<owner>/<repo>.git <branch> --squash
```

## Updating an existing imported skill

The same split approach, but use `subtree pull` instead of `subtree add`:

```bash
TMPDIR=$(mktemp -d)
git clone --no-tags https://github.com/<owner>/<repo>.git "$TMPDIR"
git -C "$TMPDIR" subtree split -P <subdirectory-path> -b split-branch
git subtree pull --prefix=github.com/<owner>/<repo> "$TMPDIR" split-branch --squash
rm -rf "$TMPDIR"
```

## Notes

- `git subtree split` is **deterministic** — the same source commits produce the same SHAs, so repeated pulls work correctly.
- Use `--squash` to avoid pulling the full upstream history into this repo.
