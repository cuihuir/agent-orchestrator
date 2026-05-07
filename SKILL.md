---
name: agent-orchestrator
description: "Cross-agent orchestration - dispatch tasks between Claude Code, Codex, and third-party models (GLM/Mimo/MiniMax). Use when: delegating work to another agent, reviewing another agent's output, running tasks on GLM or Mimo or MiniMax models, orchestrating multi-agent workflows, or when user says \"ask codex\", \"use codex\", \"delegate to\", \"let codex/claude handle this\", \"use glm\", \"use mimo\", \"use minimax\", \"ccz\", \"ccm\", \"ccmx\"."
---

# Agent Orchestrator

Dispatch tasks to other AI agents as subagents. The current agent acts as orchestrator: assign task, receive result, review and integrate.

## Available Targets

| Target | Command | Best For |
|--------|---------|----------|
| `codex` | `codex exec` | Implementation, code generation, refactoring |
| `claude` | `claude -p` | Analysis, review, complex reasoning |
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
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh codex "Create src/utils/parser.ts with parseConfig function"

# Multiple independent tasks - run in parallel
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh codex "Create src/utils/parser.ts" --output /tmp/parser.txt &
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh codex "Create src/utils/validator.ts" --output /tmp/validator.txt &
wait
```

### 3. Review results
Read the output files. Check for:
- Correct implementation
- Error handling
- Test coverage
- Style consistency

### 4. Integrate
Apply approved changes. Run tests. Commit if satisfied.

## Direct CLI Patterns (without dispatch.sh)

### Claude Code -> Codex
```bash
codex exec -s workspace-write --skip-git-repo-check -C /path "prompt"
echo "context" | codex exec -s workspace-write --skip-git-repo-check "prompt with stdin"
```

### Codex -> Claude Code
```bash
claude -p "prompt"
echo "context" | claude -p "prompt with stdin"
claude -p --add-dir /path -- "prompt needing file access"
```

Use `--bare` only when you intentionally want Claude's minimal API-key mode. It skips OAuth/keychain auth.

### Third-Party Models
See [references/third-party-models.md](references/third-party-models.md) for GLM/Mimo/MiniMax setup.

```bash
# Quick dispatch to GLM
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh claude-glm "translate this to Chinese"

# Quick dispatch to Mimo
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh claude-mimo "analyze this code"

# Quick dispatch to MiniMax
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh claude-minimax "implement this feature"
```

## Review Protocol

When reviewing another agent's output:

1. **Check completeness** - Did it address all requirements?
2. **Verify correctness** - Read the actual code, don't trust summaries
3. **Run tests** - `npm test` / `pytest` / relevant test command
4. **Security scan** - No hardcoded secrets, proper input validation
5. **Style match** - Consistent with existing codebase patterns

If output is insufficient: dispatch again with more specific instructions, including the failed attempt as context.

## Orchestration Patterns

### Pattern A: Codex implements, Claude reviews
```
Claude (you) -> plan task
  -> dispatch to Codex: implement
  <- receive implementation
Claude (you) -> review code
  -> if issues: dispatch to Codex: fix
  -> if good: integrate
```

### Pattern B: Claude analyzes, Codex implements
```
Codex (you) -> need analysis
  -> dispatch to Claude: analyze/review
  <- receive analysis
Codex (you) -> implement based on analysis
```

### Pattern C: Multi-model pipeline
```
Claude (you) -> plan
  -> dispatch to GLM: draft implementation (cost-effective)
  <- receive draft
  -> dispatch to Codex: refine and test
  <- receive final
Claude (you) -> review and integrate
```

## Error Handling

- If dispatch fails: check if target CLI is installed and authenticated
- If timeout: increase `--timeout` or simplify the prompt
- If output is empty: the target may have hit an error; try with `--bare` or check logs
- For Codex permission errors: use `-s workspace-write` or `--dangerously-bypass-approvals-and-sandbox`
