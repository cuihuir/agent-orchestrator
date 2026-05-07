#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$ROOT/install.sh"
TMP_HOME="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_HOME"
}
trap cleanup EXIT

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_file() {
  local path="$1"
  local name="$2"
  [[ -f "$path" ]] || fail "$name: missing $path"
  pass "$name"
}

assert_executable() {
  local path="$1"
  local name="$2"
  [[ -x "$path" ]] || fail "$name: not executable $path"
  pass "$name"
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local name="$3"
  [[ "$haystack" == *"$needle"* ]] || fail "$name: expected '$needle', got: $haystack"
  pass "$name"
}

HELP_OUTPUT="$("$INSTALL" --help)"
assert_contains "$HELP_OUTPUT" "Usage: install.sh" "help output"

HOME="$TMP_HOME" "$INSTALL" --no-api-keys >/tmp/agent-orchestrator-install-test.log

assert_file "$TMP_HOME/.claude/skills/agent-orchestrator/SKILL.md" "claude skill installed"
assert_file "$TMP_HOME/.claude/skills/agent-orchestrator/scripts/dispatch.sh" "dispatch installed"
assert_executable "$TMP_HOME/.claude/skills/agent-orchestrator/scripts/dispatch.sh" "dispatch executable"
assert_file "$TMP_HOME/.codex/skills/agent-orchestrator/SKILL.md" "codex skill installed"
assert_executable "$TMP_HOME/.local/bin/agent-dispatch" "agent-dispatch shortcut"

if cmp -s "$ROOT/codex/SKILL.md" "$TMP_HOME/.codex/skills/agent-orchestrator/SKILL.md"; then
  pass "codex skill content"
else
  fail "codex skill content: installed file differs"
fi

DRY_RUN_OUTPUT="$(HOME="$TMP_HOME" "$INSTALL" --dry-run --no-api-keys)"
assert_contains "$DRY_RUN_OUTPUT" "Would install Claude skill" "dry run prints planned install"

set +e
API_KEYS_OUTPUT="$(HOME="$TMP_HOME" "$INSTALL" --api-keys 2>&1)"
API_KEYS_STATUS=$?
set -e
[[ "$API_KEYS_STATUS" -ne 0 ]] || fail "noninteractive api key prompt: expected failure"
assert_contains "$API_KEYS_OUTPUT" "--api-keys requires an interactive terminal" "noninteractive api key prompt"
