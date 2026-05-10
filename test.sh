#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

AGENT_CONFIG_HOME="$tmp_dir/home" "$ROOT_DIR/deploy.sh"

cmp -s "$ROOT_DIR/rule.md" "$tmp_dir/home/.codex/AGENTS.md"
cmp -s "$ROOT_DIR/rule.md" "$tmp_dir/home/.claude/CLAUDE.md"

AGENT_CONFIG_HOME="$tmp_dir/home" "$ROOT_DIR/deploy.sh" --check >/dev/null

persona_root="$tmp_dir/persona-skills-core"
persona_log="$tmp_dir/persona-skills.log"
mkdir -p "$persona_root/scripts"
cat >"$persona_root/scripts/persona-skills.py" <<'EOF'
#!/usr/bin/env python3
from __future__ import annotations

import os
import sys

with open(os.environ["PERSONA_SKILLS_TEST_LOG"], "a", encoding="utf-8") as handle:
    handle.write(" ".join(sys.argv[1:]) + "\n")
print("persona-skills stub ok")
EOF

PERSONA_SKILLS_TEST_LOG="$persona_log" \
PERSONA_SKILLS_ROOT="$persona_root" \
AGENT_CONFIG_HOME="$tmp_dir/home" \
"$ROOT_DIR/deploy.sh" --persona-skills-status >/dev/null

rg -q 'codex-plugin-status --home' "$persona_log"
rg -q 'claude-skills-status --claude-skills-path' "$persona_log"

PERSONA_SKILLS_TEST_LOG="$persona_log" \
PERSONA_SKILLS_ROOT="$persona_root" \
AGENT_CONFIG_HOME="$tmp_dir/home" \
"$ROOT_DIR/deploy.sh" --install-persona-skills >/dev/null

rg -q 'install-codex-plugin --dry-run --home' "$persona_log"
rg -q 'install-codex-plugin --apply --home' "$persona_log"
rg -q 'install-claude-skills --dry-run --claude-skills-path' "$persona_log"
rg -q 'install-claude-skills --apply --claude-skills-path' "$persona_log"

printf '\n# drift\n' >>"$tmp_dir/home/.codex/AGENTS.md"
if AGENT_CONFIG_HOME="$tmp_dir/home" "$ROOT_DIR/deploy.sh" --check >/dev/null 2>&1; then
  printf 'expected --check to fail after drift\n' >&2
  exit 1
fi

sh -n "$ROOT_DIR/deploy.sh"
sh -n "$ROOT_DIR/test.sh"

printf 'test ok\n'
