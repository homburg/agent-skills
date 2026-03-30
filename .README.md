# Agent Skills

A collection of reusable skills for AI coding agents (Amp, Claude Code, Cursor, etc.).

## What are Skills?

Skills are specialized instruction sets that agents can load to handle specific tasks. They provide domain-specific workflows, commands, and context that help agents work more effectively.

## Available Skills

| Skill | Description |
|-------|-------------|
| **[ampdo](./ampdo)** | Find and execute `AMPDO:` or `AGENTDO:` comments left in code as instructions for agents |
| **[ast-grep](./ast-grep)** | Structural code search using AST patterns — more powerful than text search |
| **[ralph](./ralph)** | Autonomous feature development loop with task dependencies |
| **[tmux](./tmux)** | Manage background processes (servers, watchers) via tmux |
| **[ui-preview](./ui-preview)** | Screenshot and preview local dev servers and storybooks |
| **[work-on-linear-issue](./work-on-linear-issue)** | Fetch Linear issues and create implementation plans |

## Installation

Clone to your agents skills directory:

```bash
git clone git@github.com:homburg/agent-skills.git ~/.agents/skills
```

## Usage

Skills are loaded automatically when relevant, or manually invoked depending on your agent's configuration.

For Amp, reference skills in your `~/.config/amp/settings.json` or project-level `.amp/settings.json`.
