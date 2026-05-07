# Claude Code -> Codex

## Quick Reference

```bash
# Basic task
codex exec -s workspace-write --skip-git-repo-check -C /path/to/project "your prompt here"

# With stdin context
echo "context data" | codex exec -s workspace-write --skip-git-repo-check "analyze this"

# Full auto (no sandbox, use with caution)
codex exec --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check "your prompt"

# Save output to file
codex exec -s workspace-write --skip-git-repo-check -o result.txt "your prompt"

# JSON output for parsing
codex exec -s workspace-write --skip-git-repo-check --json "your prompt" 2>/dev/null | jq .
```

## Key Flags

| Flag | Purpose |
|------|---------|
| `-s workspace-write` | Sandbox: read + write in workspace |
| `-s read-only` | Sandbox: read only, no writes |
| `-C <dir>` | Set working directory |
| `--ephemeral` | Don't persist session to disk |
| `-o <file>` | Write last message to file |
| `--json` | Output events as JSONL |
| `-m <model>` | Override model |
| `--skip-git-repo-check` | Allow running outside git repo |
| `--dangerously-bypass-approvals-and-sandbox` | Full auto, no prompts |

## Workflow Pattern

1. **Delegate implementation task** to Codex
2. **Review output** - Codex returns full conversation
3. **Integrate results** into your codebase

## Example: Codex writes a module

```bash
codex exec -s workspace-write --skip-git-repo-check -C /home/tope/myproject \
  "Create a TypeScript utility module at src/utils/parser.ts that:
   - Exports parseConfig(input: string): Config
   - Handles YAML and JSON input
   - Includes error handling
   - Write unit tests in src/utils/parser.test.ts"
```

## Tips

- Use `--ephemeral` to avoid cluttering disk with sessions
- Pipe file contents via stdin for context: `cat existing.ts | codex exec --skip-git-repo-check "refactor this"`
- Use `-o` to capture large outputs without terminal truncation
- For code review: `codex exec review` (dedicated subcommand)
