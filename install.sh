#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SKILL_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}/agent-orchestrator"
CODEX_SKILL_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}/agent-orchestrator"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
SHELL_RC="${SHELL_RC:-$HOME/.zshrc}"
INSTALL_BIN=1
CONFIGURE_KEYS=auto
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: install.sh [options]

Install agent-orchestrator for Claude Code and Codex.

Options:
  --no-api-keys        Do not prompt for third-party model API keys
  --api-keys           Prompt for GLM/Mimo/MiniMax API keys
  --no-bin             Do not create ~/.local/bin/agent-dispatch
  --bin-dir <dir>      Directory for agent-dispatch shortcut
  --shell-rc <file>    Shell rc file for API key exports (default: ~/.zshrc)
  --dry-run            Print planned actions without writing files
  -h, --help           Show this help
EOF
}

log() {
  printf '%s\n' "$1"
}

require_file() {
  local path="$1"
  [[ -e "$path" ]] || { echo "Missing required file: $path" >&2; exit 1; }
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-api-keys) CONFIGURE_KEYS=0; shift ;;
    --api-keys) CONFIGURE_KEYS=1; shift ;;
    --no-bin) INSTALL_BIN=0; shift ;;
    --bin-dir)
      [[ -n "${2:-}" && "$2" != --* ]] || { echo "Missing value for --bin-dir" >&2; exit 1; }
      BIN_DIR="$2"
      shift 2
      ;;
    --shell-rc)
      [[ -n "${2:-}" && "$2" != --* ]] || { echo "Missing value for --shell-rc" >&2; exit 1; }
      SHELL_RC="$2"
      shift 2
      ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

require_file "$ROOT/SKILL.md"
require_file "$ROOT/codex/SKILL.md"
require_file "$ROOT/scripts/dispatch.sh"

log "Installing agent-orchestrator"

if [[ "$DRY_RUN" == "1" ]]; then
  log "Would install Claude skill to $CLAUDE_SKILL_DIR"
  log "Would install Codex skill to $CODEX_SKILL_DIR"
else
  rm -rf "$CLAUDE_SKILL_DIR"
  mkdir -p "$CLAUDE_SKILL_DIR/scripts" "$CLAUDE_SKILL_DIR/references" "$CODEX_SKILL_DIR"
  cp "$ROOT/SKILL.md" "$CLAUDE_SKILL_DIR/SKILL.md"
  cp "$ROOT/README.md" "$CLAUDE_SKILL_DIR/README.md"
  cp "$ROOT/LICENSE" "$CLAUDE_SKILL_DIR/LICENSE"
  cp "$ROOT/scripts/dispatch.sh" "$CLAUDE_SKILL_DIR/scripts/dispatch.sh"
  cp "$ROOT"/references/*.md "$CLAUDE_SKILL_DIR/references/"
  cp "$ROOT/codex/SKILL.md" "$CODEX_SKILL_DIR/SKILL.md"
  chmod +x "$CLAUDE_SKILL_DIR/scripts/dispatch.sh"
fi

if [[ "$INSTALL_BIN" == "1" ]]; then
  if [[ "$DRY_RUN" == "1" ]]; then
    log "Would create shortcut $BIN_DIR/agent-dispatch"
  else
    mkdir -p "$BIN_DIR"
    ln -sf "$CLAUDE_SKILL_DIR/scripts/dispatch.sh" "$BIN_DIR/agent-dispatch"
  fi
fi

configure_api_keys() {
  if [[ "$CONFIGURE_KEYS" == "auto" ]]; then
    [[ -t 0 ]] || return 0
    printf 'Configure GLM/Mimo/MiniMax API keys in %s? [y/N] ' "$SHELL_RC"
    local answer
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]] || return 0
  elif [[ "$CONFIGURE_KEYS" != "1" ]]; then
    return 0
  fi

  [[ -t 0 ]] || { echo "--api-keys requires an interactive terminal" >&2; exit 1; }

  local glm_key mimo_key minimax_key
  printf 'GLM_API_KEY (blank to skip): '
  read -r glm_key
  printf 'MIMO_API_KEY (blank to skip): '
  read -r mimo_key
  printf 'MINIMAX_API_KEY (blank to skip): '
  read -r minimax_key

  if [[ "$DRY_RUN" == "1" ]]; then
    log "Would update $SHELL_RC with provided API key exports"
    return 0
  fi

  mkdir -p "$(dirname "$SHELL_RC")"
  touch "$SHELL_RC"
  {
    printf '\n# agent-orchestrator API keys\n'
    [[ -n "$glm_key" ]] && printf 'export GLM_API_KEY=%q\n' "$glm_key"
    [[ -n "$mimo_key" ]] && printf 'export MIMO_API_KEY=%q\n' "$mimo_key"
    [[ -n "$minimax_key" ]] && printf 'export MINIMAX_API_KEY=%q\n' "$minimax_key"
  } >> "$SHELL_RC"
}

configure_api_keys

log "Installed Claude skill: $CLAUDE_SKILL_DIR"
log "Installed Codex skill: $CODEX_SKILL_DIR"
if [[ "$INSTALL_BIN" == "1" ]]; then
  log "Shortcut: $BIN_DIR/agent-dispatch"
fi
log "Done. Restart Claude/Codex sessions so they reload skills."
