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
  ./deploy.sh [deploy|--check|--dry-run|--persona-skills-status|--install-persona-skills]

Commands:
  deploy                   Copy rule.md to Codex and Claude Code global instruction files.
  --check                  Verify deployed files already match rule.md.
  --dry-run                Print target paths without writing files.
  --persona-skills-status  Show Persona Skills Core Codex / Claude Code registration status.
  --install-persona-skills Register Persona Skills Core for Codex plugin and Claude Code slash skills.

Environment:
  AGENT_CONFIG_HOME   Override the target home directory. Used by tests.
  RULE_FILE           Override the source rule file.
  PERSONA_SKILLS_ROOT Path to a Persona Skills Core checkout. Required for Persona Skills commands.
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
  --persona-skills-status|persona-skills-status)
    mode=persona-skills-status
    ;;
  --install-persona-skills|install-persona-skills)
    mode=install-persona-skills
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

run_persona_skills_cli() {
  if [ -z "${PERSONA_SKILLS_ROOT:-}" ]; then
    printf 'PERSONA_SKILLS_ROOT is required for Persona Skills commands\n' >&2
    return 1
  fi

  persona_skills_cli="$PERSONA_SKILLS_ROOT/scripts/persona-skills.py"
  if [ ! -f "$persona_skills_cli" ]; then
    printf 'Persona Skills CLI not found: %s\n' "$persona_skills_cli" >&2
    return 1
  fi

  python3 "$persona_skills_cli" --repo-root "$PERSONA_SKILLS_ROOT" "$@"
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
  persona-skills-status)
    run_persona_skills_cli codex-plugin-status --home "$TARGET_HOME"
    run_persona_skills_cli \
      claude-skills-status \
      --claude-skills-path "$TARGET_HOME/.claude/skills"
    ;;
  install-persona-skills)
    run_persona_skills_cli install-codex-plugin --dry-run --home "$TARGET_HOME"
    run_persona_skills_cli install-codex-plugin --apply --home "$TARGET_HOME"
    run_persona_skills_cli \
      install-claude-skills \
      --dry-run \
      --claude-skills-path "$TARGET_HOME/.claude/skills"
    run_persona_skills_cli \
      install-claude-skills \
      --apply \
      --claude-skills-path "$TARGET_HOME/.claude/skills"
    run_persona_skills_cli codex-plugin-status --home "$TARGET_HOME"
    run_persona_skills_cli \
      claude-skills-status \
      --claude-skills-path "$TARGET_HOME/.claude/skills"
    ;;
  deploy)
    mkdir -p "$(dirname "$CODEX_TARGET")" "$(dirname "$CLAUDE_TARGET")"
    cp "$RULE_FILE" "$CODEX_TARGET"
    cp "$RULE_FILE" "$CLAUDE_TARGET"
    printf 'deployed: %s\n' "$CODEX_TARGET"
    printf 'deployed: %s\n' "$CLAUDE_TARGET"
    ;;
esac
