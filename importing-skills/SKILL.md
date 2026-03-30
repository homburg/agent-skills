---
name: importing-skills
description: "Imports skills from external repos. Use when adding or updating skills from another GitHub repository."
---

# Importing Skills

## Recommended: `npx skills add`

Use the [skills CLI](https://skills.sh/) to install skills from GitHub repos:

```bash
# Install all skills from a repo, globally, for all agents
npx skills add <owner>/<repo> -g --agent '*' --all

# Install a specific skill
npx skills add <owner>/<repo> -g --agent '*' --skill <name> -y

# List available skills without installing
npx skills add <owner>/<repo> --list

# Check for updates
npx skills check

# Update all skills
npx skills update
```

### Examples

```bash
# Vercel skills
npx skills add vercel-labs/agent-skills -g --agent '*' --all

# Callstack agent-device
npx skills add callstackincubator/agent-device -g --agent '*' --all
```

### How it works

- `--agent '*'` installs to `~/.agents/skills/` (universal location) and symlinks from agent-specific directories
- `--agent pi` copies directly to `~/.pi/agent/skills/` (pi-specific)
- Includes security risk assessments (Gen, Socket, Snyk)
- Tracks sources via `skills-lock.json`

## Alternative: Git subtree split

For repos not compatible with the skills CLI, or when you need more control:

```bash
# 1. Clone the source repo into a temp directory
TMPDIR=$(mktemp -d)
git clone --no-tags https://github.com/<owner>/<repo>.git "$TMPDIR"

# 2. Split the subdirectory into a standalone branch
git -C "$TMPDIR" subtree split -P <subdirectory-path> -b split-branch

# 3. Add it as a subtree
git subtree add --prefix=<local-prefix> "$TMPDIR" split-branch --squash

# 4. Clean up
rm -rf "$TMPDIR"
```

### Updating a subtree import

```bash
TMPDIR=$(mktemp -d)
git clone --no-tags https://github.com/<owner>/<repo>.git "$TMPDIR"
git -C "$TMPDIR" subtree split -P <subdirectory-path> -b split-branch
git subtree pull --prefix=<local-prefix> "$TMPDIR" split-branch --squash
rm -rf "$TMPDIR"
```

## Notes

- Prefer `npx skills add` — it handles installs, updates, security scanning, and source tracking automatically.
- Use `--squash` with git subtree to avoid pulling full upstream history.
- `git subtree split` is **deterministic** — repeated pulls work correctly.
