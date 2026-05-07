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
claude skills install agent-orchestrator.skill

# Or manually
cp -r agent-orchestrator ~/.claude/skills/
```

For Codex, also copy the SKILL.md:

```bash
mkdir -p ~/.codex/skills/agent-orchestrator
cp SKILL.md ~/.codex/skills/agent-orchestrator/
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
dispatch.sh codex "Create src/utils/parser.ts"

# Dispatch to Claude
dispatch.sh claude "Review src/auth.ts for security issues"

# Dispatch to third-party models
dispatch.sh claude-glm "translate this to Chinese"
dispatch.sh claude-mimo "analyze this code"
dispatch.sh claude-minimax "implement this feature"

# Parallel dispatch
dispatch.sh codex "task A" --output /tmp/a.txt &
dispatch.sh codex "task B" --output /tmp/b.txt &
wait

# Dry run (preview command without executing)
dispatch.sh claude "test prompt" --dry-run
```

## Interactive Aliases

Add to `~/.zshrc`:

```bash
alias ccz='export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic";export ANTHROPIC_AUTH_TOKEN="$GLM_API_KEY";export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1";export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.1";export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-5.1";claude'
alias ccm='export ANTHROPIC_BASE_URL="https://token-plan-cn.xiaomimimo.com/anthropic";export ANTHROPIC_AUTH_TOKEN="$MIMO_API_KEY";export ANTHROPIC_DEFAULT_OPUS_MODEL="mimo-v2.5-pro";export ANTHROPIC_DEFAULT_SONNET_MODEL="mimo-v2.5-pro";export ANTHROPIC_DEFAULT_HAIKU_MODEL="mimo-v2.5-pro";claude'
alias ccmx='export ANTHROPIC_BASE_URL="https://api.minimaxi.com/anthropic";export ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY";export ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2.7";export ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2.7";export ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M2.7";export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1";claude'
```

## Orchestration Patterns

| Pattern | Flow |
|---------|------|
| Codex implements, Claude reviews | Claude plans -> Codex builds -> Claude reviews |
| Claude analyzes, Codex implements | Codex needs help -> Claude analyzes -> Codex implements |
| Multi-model pipeline | Claude plans -> GLM drafts -> Codex refines -> Claude integrates |

## License

MIT
