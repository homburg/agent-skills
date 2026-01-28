# Terminal Output Capture & Search Tools

This document evaluates tools for capturing, indexing, and searching terminal/process output. These complement the tmux skill by providing **output analysis and retrieval** rather than interactive control.

## Terminal Session Recorders

Tools that record terminal sessions with replay and text search capabilities.

| Tool | Stars | Activity | Pros | Cons |
|------|-------|----------|------|------|
| **[asciinema](https://github.com/asciinema/asciinema)** ⭐ | 16.8k | Active (Rust rewrite) | Text-based recording, copy-paste from playback, web embedding, live streaming | No built-in search, requires server for sharing |
| **[VHS](https://github.com/charmbracelet/vhs)** | 15k+ | Active | Write recordings as code, GIF/MP4 output, great for demos | No search, demo-focused not logging |
| **[termtosvg](https://github.com/nbedos/termtosvg)** | 9.8k | Stable (last release 2020) | SVG output, lightweight, standalone files | Unmaintained, no search |
| **[t-rec](https://github.com/sassman/t-rec-rs)** | 1k+ | Active | Rust, GIF output, simple | No text search, GIF-focused |
| **[rewindtty](https://github.com/rewindtty/rewindtty)** | 50+ | New (2024) | C-based, analyze command, precise timing | New project, small community |
| **script (Unix builtin)** | N/A | Ubiquitous | Built-in everywhere, scriptreplay for timing | Raw capture, no indexing or search |

## Shell History with Output Capture

Tools that extend shell history to include command output, not just commands.

| Tool | Stars | Activity | Pros | Cons |
|------|-------|----------|------|------|
| **[Atuin](https://github.com/atuinsh/atuin)** ⭐⭐ | 28k | Very active | SQLite-backed history, sync across machines, E2E encrypted, context (exit code, duration, cwd) | History only, no output capture |
| **[nhi](https://github.com/strang1ato/nhi)** ⭐ | 326 | Stable (v0.2.6 Mar 2023) | **Captures command output**, eBPF-based, SQLite storage, powerful queries | Linux only, kernel 5.8+, bash/zsh only |
| **[dish](https://github.com/wolfwoolford/dish)** | 50+ | Stable | Logs commands with directory, simple text files | No output capture, commands only |
| **[ai-cli-log](https://github.com/alingse/ai-cli-log)** | New | Active (2025) | AI-powered session logging, smart filenames, captures AI tool output | Node.js, focused on AI CLI sessions |

## Local Log Aggregation & Search

Tools for aggregating and searching local CLI/process output.

| Tool | Stars | Activity | Pros | Cons |
|------|-------|----------|------|------|
| **[xogs](https://github.com/KarnerTh/xogs)** | 8 | New (v0.0.0 Dec 2024) | TUI for local logs, JSON/regex/logfmt parsers, real-time filtering | Very new, Go-based |
| **[sist2](https://github.com/sist2app/sist2)** | 1.2k | Active | File system indexer with text search, SQLite/ES backend, web UI | General-purpose, not terminal-focused |
| **[lnav](https://lnav.org/)** | 7k+ | Active | Log file navigator, syntax highlighting, SQLite queries | File-focused, not live capture |
| **[angle-grinder](https://github.com/rcoh/angle-grinder)** | 3.5k | Stable | CLI log aggregation, SQL-like queries | Pipeline tool, not storage |

## Observability & Tracing (Dev-focused)

Tools for capturing and analyzing process behavior, useful for debugging AI agent sessions.

| Tool | Stars | Activity | Pros | Cons |
|------|-------|----------|------|------|
| **[Langfuse](https://github.com/langfuse/langfuse)** | 10k+ | Very active | LLM observability, tracing, debugging | Cloud/self-host, LLM-specific |
| **[Weave (W&B)](https://github.com/wandb/weave)** | 2k+ | Active | AI agent tracing, experiment tracking | Weights & Biases ecosystem |
| **OpenTelemetry** | 10k+ | Very active | Industry standard tracing | Complex setup, not terminal-specific |

## Key Findings

### Output Capture Gap

Most tools focus on either:
- **Command history** (Atuin, shell history) - commands only, no output
- **Session recording** (asciinema, VHS) - visual replay, no indexing

**nhi is unique** in capturing both commands AND their output with queryable storage.

### Comparison Matrix

| Capability | asciinema | Atuin | nhi | script |
|------------|-----------|-------|-----|--------|
| Capture output | ✅ | ❌ | ✅ | ✅ |
| Text search | ❌ | ✅ | ✅ | Manual |
| Structured queries | ❌ | ✅ | ✅ | ❌ |
| Cross-machine sync | ✅ | ✅ | ❌ | ❌ |
| Session replay | ✅ | ❌ | ✅ | ✅ |
| Platform | All | All | Linux only | Unix |

## Recommendations

### For AI Agent Output Capture

**Best options:**
1. **[nhi](https://github.com/strang1ato/nhi)** (326⭐) - If on Linux 5.8+, captures everything with eBPF, powerful queries
2. **script + grep** - Universal fallback, capture with `script`, search with grep/ripgrep
3. **[ai-cli-log](https://github.com/alingse/ai-cli-log)** - For AI CLI tools specifically, smart naming

### For Searchable Shell History

**[Atuin](https://github.com/atuinsh/atuin)** (28k⭐) is the clear winner:
- SQLite-backed with full-text search
- Captures context (exit code, duration, cwd, hostname)
- E2E encrypted sync across machines
- Works with bash, zsh, fish, nushell

### For Session Recording & Demos

**[asciinema](https://github.com/asciinema/asciinema)** (16.8k⭐) remains the standard:
- Text-based (copy-paste works in playback)
- Live streaming support
- Lightweight `.cast` format

### For Log Analysis

**[lnav](https://lnav.org/)** (7k⭐) for interactive exploration
**[angle-grinder](https://github.com/rcoh/angle-grinder)** for pipeline processing

## Integration with tmux Skill

These tools complement the tmux skill:

| tmux Skill | Output Capture Tool | Use Case |
|------------|---------------------|----------|
| `send-keys` | nhi/script | Capture output of commands sent to REPL |
| `capture-pane` | asciinema | Record entire session for replay |
| Session control | Atuin | Query what commands were run |

**Example workflow:**
1. tmux skill sends commands to interactive session
2. nhi captures all output automatically
3. Query nhi to find specific output: `nhi log -c "python" --output-contains "error"`

## References

- [Awesome Terminal Recorder list](https://github.com/orangekame3/awesome-terminal-recorder)
- [Atuin documentation](https://docs.atuin.sh/)
- [asciinema documentation](https://docs.asciinema.org/)
- [nhi project](https://github.com/strang1ato/nhi)
- [Baeldung: Search Terminal Output](https://www.baeldung.com/linux/search-terminal-output)
