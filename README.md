# Agent Orchestrator

Cross-agent orchestration skill for Claude Code and Codex. Dispatch tasks between agents and third-party models (GLM, Mimo, MiniMax).

## Features

- **Claude Code <-> Codex** mutual delegation
- **Third-party model support**: GLM (智谱), Mimo (小米), MiniMax
- **Parallel task dispatch** for independent workloads
- **Dispatch script** with timeout, output capture, dry-run mode

## Install

```bash
# Claude Code
git clone https://github.com/cuihuir/agent-orchestrator.git
cp -r agent-orchestrator ~/.claude/skills/
```

For Codex, also copy the Codex-specific SKILL.md:

```bash
mkdir -p ~/.codex/skills/agent-orchestrator
cp agent-orchestrator/codex/SKILL.md ~/.codex/skills/agent-orchestrator/SKILL.md
```

The bundled dispatcher lives at:

```bash
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh
```

Optional shell shortcut:

```bash
ln -sf ~/.claude/skills/agent-orchestrator/scripts/dispatch.sh ~/.local/bin/agent-dispatch
```

## API Key Setup

Add to `~/.zshrc` (keys only, no model variables):

```bash
export GLM_API_KEY="your-glm-key"
export MIMO_API_KEY="your-mimo-key"
export MINIMAX_API_KEY="your-minimax-key"
```

## Usage

```bash
# Dispatch to Codex
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh codex "Create src/utils/parser.ts"

# Dispatch to Claude
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh claude "Review src/auth.ts for security issues"

# Dispatch to third-party models
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh claude-glm "translate this to Chinese"
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh claude-mimo "analyze this code"
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh claude-minimax "implement this feature"

# Parallel dispatch
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh codex "task A" --output /tmp/a.txt &
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh codex "task B" --output /tmp/b.txt &
wait

# Dry run (preview command without executing)
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh claude "test prompt" --dry-run
```

## Interactive Aliases

Add to `~/.zshrc`:

```bash
alias ccz='ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic" ANTHROPIC_AUTH_TOKEN="$GLM_API_KEY" ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1" ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.1" ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-5.1" claude'
alias ccm='ANTHROPIC_BASE_URL="https://token-plan-cn.xiaomimimo.com/anthropic" ANTHROPIC_AUTH_TOKEN="$MIMO_API_KEY" ANTHROPIC_DEFAULT_OPUS_MODEL="mimo-v2.5-pro" ANTHROPIC_DEFAULT_SONNET_MODEL="mimo-v2.5-pro" ANTHROPIC_DEFAULT_HAIKU_MODEL="mimo-v2.5-pro" claude'
alias ccmx='ANTHROPIC_BASE_URL="https://api.minimaxi.com/anthropic" ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY" ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2.7" ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2.7" ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M2.7" CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1" claude'
```

## Orchestration Patterns

| Pattern | Flow |
|---------|------|
| Codex implements, Claude reviews | Claude plans -> Codex builds -> Claude reviews |
| Claude analyzes, Codex implements | Codex needs help -> Claude analyzes -> Codex implements |
| Multi-model pipeline | Claude plans -> GLM drafts -> Codex refines -> Claude integrates |

## License

MIT
