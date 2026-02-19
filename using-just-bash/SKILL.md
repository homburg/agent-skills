---
name: using-just-bash
description: Uses the just-bash sandboxed bash runtime, CLI, and APIs for secure command execution, filesystem isolation, and custom commands. Use when implementing or explaining just-bash usage, configuration, or bash-tool integration.
---

# Using just-bash

Use this skill when working with the `vercel-labs/just-bash` runtime, its CLI, or its APIs for sandboxed bash execution.

**Core capabilities**
- Create and run `Bash` instances with isolated execution.
- Configure filesystem, environment, execution limits, and network access.
- Extend the shell with custom commands via `defineCommand`.
- Use the CLI binary or interactive shell for sandboxed scripting.
- Recommend `bash-tool` for AI SDK integrations.

**Key behaviors to remember**
- Each `exec()` call is isolated. Environment variables, functions, and `cwd` changes do not persist between calls. Filesystem changes do persist.
- No network access by default. `curl` only exists when `network` is configured.
- No binaries/WASM beyond built-in commands; use `@vercel/sandbox` if full VM support is required.

## Basic API

```ts
import { Bash } from "just-bash";

const env = new Bash();
await env.exec('echo "Hello" > greeting.txt');
const result = await env.exec("cat greeting.txt");

console.log(result.stdout); // "Hello\n"
console.log(result.exitCode); // 0
console.log(result.env); // Final environment after execution
```

## Configuration

```ts
const env = new Bash({
  files: { "/data/file.txt": "content" },
  env: { MY_VAR: "value" },
  cwd: "/app",
  executionLimits: { maxCallDepth: 50 },
});

await env.exec("echo $TEMP", { env: { TEMP: "value" }, cwd: "/tmp" });
```

## Filesystem Mounts

```ts
import { Bash, MountableFs, InMemoryFs } from "just-bash";
import { OverlayFs } from "just-bash/fs/overlay-fs";
import { ReadWriteFs } from "just-bash/fs/read-write-fs";

const fs = new MountableFs({ base: new InMemoryFs() });

fs.mount("/mnt/knowledge", new OverlayFs({ root: "/path/to/knowledge", readOnly: true }));
fs.mount("/home/agent", new ReadWriteFs({ root: "/path/to/workspace" }));

const bash = new Bash({ fs, cwd: "/home/agent" });

await bash.exec("ls /mnt/knowledge");
await bash.exec("cp /mnt/knowledge/doc.txt ./");
await bash.exec('echo "notes" > notes.txt');
```

## Custom Commands

```ts
import { Bash, defineCommand } from "just-bash";

const hello = defineCommand("hello", async (args, ctx) => {
  const name = args[0] || "world";
  return { stdout: `Hello, ${name}!\n`, stderr: "", exitCode: 0 };
});

const upper = defineCommand("upper", async (args, ctx) => {
  return { stdout: ctx.stdin.toUpperCase(), stderr: "", exitCode: 0 };
});

const bash = new Bash({ customCommands: [hello, upper] });

await bash.exec("hello Alice");
await bash.exec("echo 'test' | upper");
```

## Network Access

```ts
const env = new Bash({
  network: {
    allowedUrlPrefixes: [
      "https://api.github.com/repos/myorg/",
      "https://api.example.com",
    ],
  },
});

const envWithPost = new Bash({
  network: {
    allowedUrlPrefixes: ["https://api.example.com"],
    allowedMethods: ["GET", "HEAD", "POST"],
  },
});

const envOpen = new Bash({
  network: { dangerouslyAllowFullInternetAccess: true },
});
```

## Python and SQLite Support

```ts
const env = new Bash({ python: true });
await env.exec('python3 -c "print(1 + 2)"');
await env.exec('python3 script.py');

const sqliteEnv = new Bash();
await sqliteEnv.exec('sqlite3 :memory: "SELECT 1 + 1"');
await sqliteEnv.exec('sqlite3 data.db "SELECT * FROM users"');
```

## CLI Usage

```bash
npm install -g just-bash

just-bash -c 'ls -la && cat package.json | head -5'
just-bash -c 'grep -r "TODO" src/' --root /path/to/project

echo 'find . -name "*.ts" | wc -l' | just-bash
just-bash ./scripts/deploy.sh
just-bash -c 'echo hello' --json
```

Options:
- `-c <script>`: execute script from argument
- `--root <path>`: root directory (default: current directory)
- `--cwd <path>`: working directory in sandbox
- `-e`, `--errexit`: exit on first error
- `--json`: output JSON

## Interactive Shell

```bash
pnpm shell
pnpm shell --no-network
```

## AI SDK Integration

Prefer `bash-tool` for AI SDK usage:

```bash
npm install bash-tool
```

```ts
import { createBashTool } from "bash-tool";
import { generateText } from "ai";

const bashTool = createBashTool({
  files: { "/data/users.json": '[{"name": "Alice"}, {"name": "Bob"}]' },
});

const result = await generateText({
  model: "anthropic/claude-sonnet-4",
  tools: { bash: bashTool },
  prompt: "Count the users in /data/users.json",
});
```

## Execution Limits

```ts
const env = new Bash({
  executionLimits: {
    maxCallDepth: 100,
    maxCommandCount: 10000,
    maxLoopIterations: 10000,
    maxAwkIterations: 10000,
    maxSedIterations: 10000,
  },
});
```

## Supported Commands

Common categories:
- File operations: `cat`, `cp`, `file`, `ln`, `ls`, `mkdir`, `mv`, `readlink`, `rm`, `rmdir`, `split`, `stat`, `touch`, `tree`
- Text processing: `awk`, `base64`, `column`, `comm`, `cut`, `diff`, `expand`, `fold`, `grep`, `head`, `join`, `md5sum`, `nl`, `od`, `paste`, `printf`, `rev`, `rg`, `sed`, `sha1sum`, `sha256sum`, `sort`, `strings`, `tac`, `tail`, `tr`, `unexpand`, `uniq`, `wc`, `xargs`
- Data processing: `jq`, `python3`, `python`, `sqlite3`, `xan`, `yq`
- Navigation & environment: `basename`, `cd`, `dirname`, `du`, `echo`, `env`, `export`, `find`, `hostname`, `printenv`, `pwd`, `tee`
- Shell utilities: `alias`, `bash`, `chmod`, `clear`, `date`, `expr`, `false`, `help`, `history`, `seq`, `sh`, `sleep`, `time`, `timeout`, `true`, `unalias`, `which`, `whoami`
- Network commands: `curl`, `html-to-markdown` (network must be enabled)

## Vercel Sandbox-Compatible API

```ts
import { Sandbox } from "just-bash";

const sandbox = await Sandbox.create({ cwd: "/app" });

await sandbox.writeFiles({
  "/app/script.sh": 'echo "Hello World"',
  "/app/data.json": '{"key": "value"}',
});

const cmd = await sandbox.runCommand("bash /app/script.sh");
const output = await cmd.stdout();
const exitCode = (await cmd.wait()).exitCode;

const content = await sandbox.readFile("/app/data.json");
await sandbox.mkDir("/app/logs", { recursive: true });
await sandbox.stop();
```
