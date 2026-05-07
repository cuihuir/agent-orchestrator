---
name: agent-orchestrator
description: "Cross-agent orchestration - dispatch tasks to Claude Code and third-party models (GLM/Mimo/MiniMax). Use when: delegating work to Claude Code, reviewing Claude's output, running tasks on GLM or Mimo or MiniMax models, orchestrating multi-agent workflows, or when user says \"ask claude\", \"use claude\", \"delegate to\", \"let claude handle this\", \"use glm\", \"use mimo\", \"use minimax\", \"ccz\", \"ccm\", \"ccmx\"."
---

# Agent Orchestrator

Dispatch tasks to Claude Code as a subagent. You (Codex) act as orchestrator: assign task, receive result, review and integrate.

## Available Targets

| Target | Command | Best For |
|--------|---------|----------|
| `claude` | `claude -p` | Analysis, review, complex reasoning, code generation |
| `claude-glm` | Claude via GLM API | Cost-effective tasks, Chinese content |
| `claude-mimo` | Claude via Mimo API | Cost-effective tasks, Chinese content |
| `claude-minimax` | Claude via MiniMax API | Cost-effective tasks, Chinese content, long context |

## Dispatch Script

Location: `~/.claude/skills/agent-orchestrator/scripts/dispatch.sh`

```bash
# Basic usage
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh <target> "<prompt>"

# With options
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh <target> "<prompt>" \
  --cwd /path/to/project \
  --timeout 600 \
  --output result.txt

# Validate command construction without calling a model
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh <target> "<prompt>" --dry-run
```

## Workflow: Orchestrate

### 1. Plan the task
Break work into independent units. Each unit becomes one dispatch call.

### 2. Dispatch (parallel when possible)
```bash
# Single task
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh claude "Analyze src/auth.ts for vulnerabilities"

# Multiple independent tasks - run in parallel
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh claude "Review src/auth.ts" --output /tmp/auth.txt &
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh claude "Review src/api.ts" --output /tmp/api.txt &
wait
```

### 3. Review results
Read the output files. Check for:
- Correct analysis
- Actionable recommendations
- Completeness

### 4. Integrate
Apply approved changes. Run tests. Commit if satisfied.

## Direct CLI Patterns (without dispatch.sh)

### Codex -> Claude Code
```bash
claude -p "prompt"
echo "context" | claude -p "prompt with stdin"
claude -p --add-dir /path -- "prompt needing file access"
```

Use `--bare` only when you intentionally want Claude's minimal API-key mode. It skips OAuth/keychain auth.

### Codex -> GLM (third-party)
```bash
ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic" \
ANTHROPIC_AUTH_TOKEN="$GLM_API_KEY" \
ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.1" \
claude -p --bare "your prompt"
```

### Codex -> Mimo (third-party)
```bash
ANTHROPIC_BASE_URL="https://token-plan-cn.xiaomimimo.com/anthropic" \
ANTHROPIC_AUTH_TOKEN="$MIMO_API_KEY" \
ANTHROPIC_DEFAULT_SONNET_MODEL="mimo-v2.5-pro" \
claude -p --bare "your prompt"
```

### Codex -> MiniMax (third-party)
```bash
ANTHROPIC_BASE_URL="https://api.minimaxi.com/anthropic" \
ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY" \
ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2.7" \
ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2.7" \
ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M2.7" \
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1" \
claude -p --bare "your prompt"
```

## Review Protocol

When reviewing Claude Code's output:

1. **Check completeness** - Did it address all requirements?
2. **Verify correctness** - Read the actual code, don't trust summaries
3. **Run tests** - `npm test` / `pytest` / relevant test command
4. **Security scan** - No hardcoded secrets, proper input validation
5. **Style match** - Consistent with existing codebase patterns

If output is insufficient: dispatch again with more specific instructions, including the failed attempt as context.

## Orchestration Pattern

```
Codex (you) -> plan task
  -> dispatch to Claude Code: implement/analyze/review
  <- receive result
Codex (you) -> review result
  -> if issues: dispatch again with fix instructions
  -> if good: integrate
```

## Error Handling

- If dispatch fails: check if `claude` CLI is installed and authenticated
- If timeout: increase `--timeout` or simplify the prompt
- If output is empty: try with `--bare` or check logs
- For GLM/Mimo/MiniMax: ensure API keys are set in environment (`GLM_API_KEY`, `MIMO_API_KEY`, `MINIMAX_API_KEY`)
