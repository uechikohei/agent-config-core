#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RULE_FILE=${RULE_FILE:-"$ROOT_DIR/rule.md"}
TARGET_HOME=${AGENT_CONFIG_HOME:-"$HOME"}
CODEX_TARGET="$TARGET_HOME/.codex/AGENTS.md"
CLAUDE_TARGET="$TARGET_HOME/.claude/CLAUDE.md"

usage() {
  cat <<'EOF'
Usage:
  ./deploy.sh [deploy|--check|--dry-run]

Commands:
  deploy     Copy rule.md to Codex and Claude Code global instruction files.
  --check    Verify deployed files already match rule.md.
  --dry-run  Print target paths without writing files.

Environment:
  AGENT_CONFIG_HOME  Override the target home directory. Used by tests.
  RULE_FILE          Override the source rule file.
EOF
}

mode=${1:-deploy}
case "$mode" in
  deploy)
    ;;
  --check|check)
    mode=check
    ;;
  --dry-run|dry-run)
    mode=dry-run
    ;;
  -h|--help|help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

if [ ! -f "$RULE_FILE" ]; then
  printf 'rule.md not found: %s\n' "$RULE_FILE" >&2
  exit 1
fi

check_target() {
  target=$1
  if [ ! -f "$target" ]; then
    printf 'missing: %s\n' "$target" >&2
    return 1
  fi
  if ! cmp -s "$RULE_FILE" "$target"; then
    printf 'out of date: %s\n' "$target" >&2
    return 1
  fi
}

case "$mode" in
  check)
    check_target "$CODEX_TARGET"
    check_target "$CLAUDE_TARGET"
    printf 'deploy check ok\n'
    ;;
  dry-run)
    printf 'source: %s\n' "$RULE_FILE"
    printf 'codex:  %s\n' "$CODEX_TARGET"
    printf 'claude: %s\n' "$CLAUDE_TARGET"
    ;;
  deploy)
    mkdir -p "$(dirname "$CODEX_TARGET")" "$(dirname "$CLAUDE_TARGET")"
    cp "$RULE_FILE" "$CODEX_TARGET"
    cp "$RULE_FILE" "$CLAUDE_TARGET"
    printf 'deployed: %s\n' "$CODEX_TARGET"
    printf 'deployed: %s\n' "$CLAUDE_TARGET"
    ;;
esac
