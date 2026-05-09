#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

AGENT_CONFIG_HOME="$tmp_dir/home" "$ROOT_DIR/deploy.sh"

cmp -s "$ROOT_DIR/rule.md" "$tmp_dir/home/.codex/AGENTS.md"
cmp -s "$ROOT_DIR/rule.md" "$tmp_dir/home/.claude/CLAUDE.md"

AGENT_CONFIG_HOME="$tmp_dir/home" "$ROOT_DIR/deploy.sh" --check >/dev/null

printf '\n# drift\n' >>"$tmp_dir/home/.codex/AGENTS.md"
if AGENT_CONFIG_HOME="$tmp_dir/home" "$ROOT_DIR/deploy.sh" --check >/dev/null 2>&1; then
  printf 'expected --check to fail after drift\n' >&2
  exit 1
fi

sh -n "$ROOT_DIR/deploy.sh"
sh -n "$ROOT_DIR/test.sh"

printf 'test ok\n'
