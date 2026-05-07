# Codex -> Claude Code

## Quick Reference

```bash
# Basic task
claude -p "your prompt here"

# With stdin context
echo "context data" | claude -p "analyze this"

# With working directory
claude -p --add-dir /path/to/project -- "your prompt"

# With custom system prompt
claude -p --system-prompt "You are a code reviewer" -- "review src/"

# Append instructions to default system prompt
claude -p --append-system-prompt "Focus on security" -- "audit this file"

# Save to file (use shell redirect)
claude -p "your prompt" > result.txt
```

## Key Flags

| Flag | Purpose |
|------|---------|
| `-p` / `--print` | Non-interactive mode, output to stdout |
| `--bare` | Minimal mode: skip hooks, LSP, memory |
| `--add-dir <dir>` | Grant tool access to directory |
| `--system-prompt <prompt>` | Replace system prompt entirely |
| `--append-system-prompt <prompt>` | Append to default system prompt |
| `--agent <name>` | Use a specific agent |
| `--agents <json>` | Define custom agents inline |

**Important:** When using `--add-dir`, `--system-prompt`, or `--append-system-prompt`, place the prompt AFTER `--` to avoid argument conflicts. Use `--bare` only when you intentionally want Claude's minimal API-key mode; it skips OAuth/keychain auth.

## Workflow Pattern

1. **Delegate analysis/review task** to Claude Code
2. **Parse structured output** from Claude's response
3. **Apply findings** to your codebase

## Example: Claude Code reviews code

```bash
claude -p --add-dir /home/tope/myproject -- \
  "Review src/auth.ts for security vulnerabilities. Output a JSON array of findings with: severity, line, description, fix"
```

## Example: Claude Code with GLM model

```bash
ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic" \
ANTHROPIC_AUTH_TOKEN="your-glm-key" \
ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.1" \
claude -p --bare "your prompt"
```

## Example: Claude Code with Mimo model

```bash
ANTHROPIC_BASE_URL="https://token-plan-cn.xiaomimimo.com/anthropic" \
ANTHROPIC_AUTH_TOKEN="$MIMO_API_KEY" \
ANTHROPIC_DEFAULT_SONNET_MODEL="mimo-v2.5-pro" \
claude -p --bare "your prompt"
```

## Example: Claude Code with MiniMax model

```bash
ANTHROPIC_BASE_URL="https://api.minimaxi.com/anthropic" \
ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY" \
ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2.7" \
ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2.7" \
ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M2.7" \
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1" \
claude -p --bare "your prompt"
```

## Tips

- `--bare` mode is fastest, but it requires API-key style auth and skips OAuth/keychain auth
- Use `--add-dir` for each directory the agent needs to read/write
- Pipe large context via stdin rather than embedding in prompt
- For structured output, ask for JSON format in the prompt
