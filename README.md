# Agent Orchestrator

Cross-agent orchestration skill for Claude Code and Codex. Dispatch tasks between agents and third-party models (GLM, Mimo, MiniMax).

## Features

- **Claude Code <-> Codex** mutual delegation
- **Third-party model support**: GLM (智谱), Mimo (小米), MiniMax
- **Parallel task dispatch** for independent workloads
- **Dispatch script** with timeout, output capture, dry-run mode

## Install

```bash
git clone https://github.com/cuihuir/agent-orchestrator.git
cd agent-orchestrator
./install.sh
```

The installer:

- Installs the Claude Code skill to `~/.claude/skills/agent-orchestrator`
- Installs the Codex skill to `~/.codex/skills/agent-orchestrator`
- Makes `scripts/dispatch.sh` executable
- Creates `~/.local/bin/agent-dispatch`
- Optionally writes GLM/Mimo/MiniMax API keys to `~/.zshrc`

Installer options:

```bash
./install.sh --no-api-keys  # Skip API key prompt, don't write keys to ~/.zshrc
./install.sh --api-keys      # Prompt for GLM/Mimo/MiniMax keys immediately (non-interactive: error)
./install.sh --no-bin        # Don't create ~/.local/bin/agent-dispatch shortcut
./install.sh --dry-run       # Preview what would be installed, write nothing
```

Manual dispatcher path:

```bash
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh
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
agent-dispatch codex "Create src/utils/parser.ts"

# Dispatch to Claude
agent-dispatch claude "Review src/auth.ts for security issues"

# Dispatch to third-party models
agent-dispatch claude-glm "translate this to Chinese"
agent-dispatch claude-mimo "analyze this code"
agent-dispatch claude-minimax "implement this feature"

# Parallel dispatch
agent-dispatch codex "task A" --output /tmp/a.txt &
agent-dispatch codex "task B" --output /tmp/b.txt &
wait

# Dry run (preview command without executing)
agent-dispatch claude "test prompt" --dry-run
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
