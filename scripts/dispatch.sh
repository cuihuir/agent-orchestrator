#!/usr/bin/env bash
# dispatch.sh - Cross-agent task dispatcher
# Usage: dispatch.sh <target> <prompt> [options]
#   target: codex | claude | claude-glm | claude-mimo | claude-minimax
#   prompt: task description (or "-" to read from stdin)
#   --cwd <dir>        working directory
#   --timeout <secs>   max wait time (default 300)
#   --sandbox <mode>   codex sandbox: read-only|workspace-write|danger-full-access
#   --model <model>    override model
#   --output <file>    write result to file instead of stdout
#   --bare             use Claude --bare mode for Claude targets
#   --dry-run          print the command that would run without dispatching

set -euo pipefail

usage() {
  echo "Usage: dispatch.sh <codex|claude|claude-glm|claude-mimo|claude-minimax> <prompt> [options]" >&2
}

if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

TARGET="$1"
PROMPT="$2"
if [[ "$PROMPT" == --* ]]; then
  echo "Missing prompt before options" >&2
  usage
  exit 1
fi
shift 2

CWD="$(pwd)"
TIMEOUT=300
SANDBOX="workspace-write"
MODEL=""
OUTPUT=""
BARE=0
DRY_RUN=0

require_value() {
  local option="$1"
  local value="${2:-}"
  if [[ -z "$value" || "$value" == --* ]]; then
    echo "Missing value for $option" >&2
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cwd) require_value "$1" "${2:-}"; CWD="$2"; shift 2 ;;
    --timeout) require_value "$1" "${2:-}"; TIMEOUT="$2"; shift 2 ;;
    --sandbox) require_value "$1" "${2:-}"; SANDBOX="$2"; shift 2 ;;
    --model) require_value "$1" "${2:-}"; MODEL="$2"; shift 2 ;;
    --output) require_value "$1" "${2:-}"; OUTPUT="$2"; shift 2 ;;
    --bare) BARE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ ! "$TIMEOUT" =~ ^[1-9][0-9]*$ ]]; then
  echo "Invalid --timeout: $TIMEOUT (must be a positive integer)" >&2
  exit 1
fi

# Build stdin content if prompt is "-"
STDIN_CONTENT=""
if [[ "$PROMPT" == "-" ]]; then
  STDIN_CONTENT="$(cat)"
  PROMPT=""
fi

print_command() {
  printf '%q ' "$@"
  printf '\n'
}

run_codex() {
  local args=(exec -s "$SANDBOX" --skip-git-repo-check -C "$CWD" --ephemeral)
  [[ -n "$MODEL" ]] && args+=(-m "$MODEL")
  if [[ "$DRY_RUN" == "1" ]]; then
    if [[ -n "$STDIN_CONTENT" ]]; then
      print_command printf '%s\\n' "$STDIN_CONTENT" "|" timeout "$TIMEOUT" codex "${args[@]}" -
    else
      print_command timeout "$TIMEOUT" codex "${args[@]}" "$PROMPT"
    fi
    return
  fi
  if [[ -n "$STDIN_CONTENT" ]]; then
    printf '%s\n' "$STDIN_CONTENT" | timeout "$TIMEOUT" codex "${args[@]}" -
  else
    timeout "$TIMEOUT" codex "${args[@]}" "$PROMPT"
  fi
}

run_claude() {
  local cmd=(claude -p)
  [[ "${CLAUDE_BARE:-$BARE}" == "1" ]] && cmd+=(--bare)
  [[ -n "$MODEL" ]] && cmd+=(--model "$MODEL")
  [[ -n "$CWD" ]] && cmd+=(--add-dir "$CWD")
  cmd+=(--)
  if [[ "$DRY_RUN" == "1" ]]; then
    if [[ -n "$STDIN_CONTENT" ]]; then
      print_command printf '%s\\n' "$STDIN_CONTENT" "|" timeout "$TIMEOUT" "${cmd[@]}" "$PROMPT"
    else
      print_command timeout "$TIMEOUT" "${cmd[@]}" "$PROMPT"
    fi
    return
  fi
  if [[ -n "$STDIN_CONTENT" ]]; then
    printf '%s\n' "$STDIN_CONTENT" | timeout "$TIMEOUT" "${cmd[@]}" "$PROMPT"
  else
    timeout "$TIMEOUT" "${cmd[@]}" "$PROMPT"
  fi
}

run_claude_glm() {
  [[ "$DRY_RUN" != "1" && -z "${GLM_API_KEY:-}" ]] && { echo "Error: GLM_API_KEY not set in environment" >&2; return 1; }
  ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic" \
  ANTHROPIC_AUTH_TOKEN="${GLM_API_KEY:-}" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.1" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-5.1" \
  CLAUDE_BARE=1 \
    run_claude
}

run_claude_mimo() {
  [[ "$DRY_RUN" != "1" && -z "${MIMO_API_KEY:-}" ]] && { echo "Error: MIMO_API_KEY not set in environment" >&2; return 1; }
  ANTHROPIC_BASE_URL="https://token-plan-cn.xiaomimimo.com/anthropic" \
  ANTHROPIC_AUTH_TOKEN="${MIMO_API_KEY:-}" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="mimo-v2.5-pro" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="mimo-v2.5-pro" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="mimo-v2.5-pro" \
  CLAUDE_BARE=1 \
    run_claude
}

run_claude_minimax() {
  [[ "$DRY_RUN" != "1" && -z "${MINIMAX_API_KEY:-}" ]] && { echo "Error: MINIMAX_API_KEY not set in environment" >&2; return 1; }
  ANTHROPIC_BASE_URL="https://api.minimaxi.com/anthropic" \
  ANTHROPIC_AUTH_TOKEN="${MINIMAX_API_KEY:-}" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2.7" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2.7" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M2.7" \
  CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1" \
  CLAUDE_BARE=1 \
    run_claude
}

RESULT=""
case "$TARGET" in
  codex)         RESULT=$(run_codex) ;;
  claude)        RESULT=$(run_claude) ;;
  claude-glm)    RESULT=$(run_claude_glm) ;;
  claude-mimo)   RESULT=$(run_claude_mimo) ;;
  claude-minimax) RESULT=$(run_claude_minimax) ;;
  *) echo "Unknown target: $TARGET (use: codex, claude, claude-glm, claude-mimo, claude-minimax)" >&2; exit 1 ;;
esac

if [[ -n "$OUTPUT" ]]; then
  echo "$RESULT" > "$OUTPUT"
  echo "Output written to: $OUTPUT"
else
  echo "$RESULT"
fi
