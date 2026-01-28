# Alternative Process Managers

This document evaluates alternatives to tmux for the tmux skill's use case: controlling interactive terminal sessions (REPLs, debuggers, etc.).

## Terminal Multiplexers (PTY-based)

These tools provide interactive stdin control and live terminal capture, making them suitable replacements for tmux.

| Tool | Stars | Activity | Pros | Cons |
|------|-------|----------|------|------|
| **tmux** ✅ | 36k+ | Mature, active | Excellent scriptability (`send-keys -l`, `capture-pane -p`), structured session/window/pane model, widely available | Requires installation on some systems |
| **screen** | N/A | Mature, stable | Ubiquitous (even more than tmux), simpler | Harder to script, less structured pane model |
| **[zellij](https://github.com/zellij-org/zellij)** | 28.5k | Active (3k+ commits) | Modern, built-in layouts, WASM plugins, web-client | Different command model, newer ecosystem |
| **[Ferrix](https://github.com/DavidLiedle/Ferrix)** | 18 | New (Oct 2025 v1.0) | Rust tmux alt, session recording, WASM plugins, TCP/TLS | Very new, small community |
| **[mtm](https://github.com/deadpixi/mtm)** | 1.2k | Stable (last release Oct 2021) | ~1000 lines C, minimal, "finished" | No plugins, minimal by design |
| **abduco + dvtm** | ~500 | Stable | Minimal, separates session/multiplexing | Two tools, less scriptable |
| **dtach** | ~700 | Stable | Ultra-minimal attach/detach | No panes/windows, no capture |

## Direct PTY Control

| Tool | Stars | Activity | Pros | Cons |
|------|-------|----------|------|------|
| **expect** | N/A | Mature | Direct PTY control, powerful scripting | Complex syntax, no session persistence |
| **[Termitty](https://github.com/Termitty/termitty)** | 41 | New (v0.1.1 May 2025) | Python Selenium-like API, session recording, AI-ready | SSH-focused, very new |
| **[terminal-mcp](https://github.com/ianks/terminal-mcp)** | 8 | New (1 commit) | Native MCP server for Unix PTY, Rust/Tokio | Extremely early, proof-of-concept |
| **Python `pty` module** | N/A | Stdlib | Built-in, no dependencies | Low-level, no session management |
| **script + pty** | N/A | Unix builtin | Native Unix, no dependencies | No attach/detach, manual parsing |
| **conpty** | N/A | Windows | Windows-native | Platform-specific |

## AI Agent Session Managers

Tools specifically designed for managing AI agent terminal sessions:

| Tool | Stars | Activity | Description |
|------|-------|----------|-------------|
| **[Agent Deck](https://github.com/asheshgoplani/agent-deck)** ⭐ | 593 | Very active (505 commits, 102 releases) | tmux wrapper for AI agents, session forking, MCP manager, multi-agent support |
| **[DesktopCommanderMCP](https://github.com/wonderwhy-er/DesktopCommanderMCP)** | 5.3k | Very active (26 contributors) | MCP server for terminal control, file search, diff editing |
| **[AIShell](https://github.com/PowerShell/AIShell)** | 513 | Active (348 commits) | Microsoft's interactive AI shell with pluggable agents |

## Process Managers (NOT suitable)

These tools manage daemon processes but **cannot** interact with interactive sessions.

| Tool | Purpose | Why not suitable |
|------|---------|------------------|
| **pm2** | Node.js process management | No stdin interaction, log files only |
| **supervisord** | Python daemon management | No PTY support, log files only |
| **systemd** | System service management | No interactive control, journald logs only |

### Key Limitations of Process Managers

Process managers like pm2 and supervisord are designed for:
- Starting/stopping background services
- Auto-restarting crashed processes
- Log aggregation

They **cannot**:
- Send keystrokes to a running process
- Interact with REPLs (Python, Node, etc.)
- Control debuggers (gdb, lldb)
- Capture live terminal state (only tail logs)

## Comparison Matrix

| Capability | tmux/screen | pm2/supervisord |
|------------|-------------|-----------------|
| Interactive stdin | ✅ | ❌ |
| Live terminal capture | ✅ | ❌ |
| Session persistence | ✅ | ✅ |
| Process restart | ❌ | ✅ |
| Best for | REPLs, debuggers | Servers, workers |

## Recommendation

**tmux remains the best choice** for this skill because:

1. Excellent scriptability with `send-keys -l` and `capture-pane -p`
2. Structured session/window/pane model
3. Widely available on macOS and Linux
4. Socket isolation works well for agent sessions

**Fallback options:**
- **screen** - most portable fallback for environments without tmux
- **expect** - for direct PTY scripting without session persistence
- **Termitty** - if you prefer Python and Selenium-like APIs

**Notable projects to watch:**
- **[Agent Deck](https://github.com/asheshgoplani/agent-deck)** (593⭐, very active) - purpose-built for AI agent session management, wraps tmux with agent-friendly features
- **[terminal-mcp](https://github.com/ianks/terminal-mcp)** (8⭐, early) - native MCP server approach, could replace tmux skill if MCP becomes standard
- **[Ferrix](https://github.com/DavidLiedle/Ferrix)** (18⭐, new v1.0) - modern Rust alternative with session recording
- **[zellij](https://github.com/zellij-org/zellij)** (28.5k⭐, mature) - if you want a tmux alternative with WASM plugins and web-client

**Complementary skills to consider:**
- A separate **pm2 skill** or **supervisor skill** for managing background services (dev servers, workers)

## References

- [GitHub: terminal-ai topic](https://github.com/topics/terminal-ai)
- [Reddit: tmux vs Zellij vs Wezterm](https://www.reddit.com/r/neovim/comments/1bjztoo/which_multiplexer_do_yall_use_tmux_zellij_wezterm/)
- [Python pty module docs](https://docs.python.org/3/library/pty.html)
- [DEV: Terminal AI agents comparison](https://dev.to/thedavestack/i-tested-the-3-major-terminal-ai-agents-and-this-is-my-winner-6oj)
