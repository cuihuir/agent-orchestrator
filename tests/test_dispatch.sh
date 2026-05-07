#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISPATCH="$ROOT/scripts/dispatch.sh"

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local name="$3"
  [[ "$haystack" == *"$needle"* ]] || fail "$name: expected output to contain '$needle', got: $haystack"
  pass "$name"
}

assert_fails_with() {
  local name="$1"
  local expected="$2"
  shift 2

  local output status
  set +e
  output="$(timeout 3 "$@" 2>&1)"
  status=$?
  set -e

  [[ "$status" -ne 0 ]] || fail "$name: expected failure"
  [[ "$output" == *"$expected"* ]] || fail "$name: expected '$expected', got: $output"
  pass "$name"
}

assert_contains "$("$DISPATCH" claude "review this" --dry-run)" "claude -p" "claude dry-run builds command"
assert_contains "$("$DISPATCH" codex "implement this" --dry-run)" "codex exec" "codex dry-run builds command"
assert_contains "$(printf 'stdin task' | "$DISPATCH" codex - --dry-run)" "codex exec" "stdin dry-run builds command"

assert_fails_with "missing prompt before options" "Missing prompt before options" "$DISPATCH" claude --dry-run
assert_fails_with "invalid timeout rejected" "Invalid --timeout" "$DISPATCH" claude "review this" --timeout abc --dry-run
assert_fails_with "zero timeout rejected" "Invalid --timeout" "$DISPATCH" claude "review this" --timeout 0 --dry-run
