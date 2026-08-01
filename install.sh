#!/usr/bin/env bash
#
# Installs the claude-skills skills for Claude Code.
#
#   ./install.sh                       both skills → ~/.claude/skills/
#   ./install.sh weekend-project       just one
#   ./install.sh --project             both → ./.claude/skills/ (current project)
#   ./install.sh --uninstall           remove from ~/.claude/skills/
#   ./install.sh --list                show available skills
#
# Can also be run without cloning first:
#   curl -fsSL https://raw.githubusercontent.com/maneja81/claude-skills/main/install.sh | bash

set -euo pipefail

REPO_URL="https://github.com/maneja81/claude-skills.git"
ALL_SKILLS=(weekend-project code-better)
SCOPE="personal"
ACTION="install"
SELECTED=()

for arg in "$@"; do
  case "$arg" in
    --project)   SCOPE="project" ;;
    --personal)  SCOPE="personal" ;;
    --uninstall) ACTION="uninstall" ;;
    --list)      ACTION="list" ;;
    -h|--help)
      sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    -*)
      echo "Unknown option: $arg (try --help)" >&2
      exit 1 ;;
    *)
      found=""
      for s in "${ALL_SKILLS[@]}"; do [ "$s" = "$arg" ] && found="$s"; done
      if [ -z "$found" ]; then
        echo "Unknown skill: $arg" >&2
        echo "Available: ${ALL_SKILLS[*]}" >&2
        exit 1
      fi
      SELECTED+=("$found") ;;
  esac
done

[ ${#SELECTED[@]} -eq 0 ] && SELECTED=("${ALL_SKILLS[@]}")

if [ "$ACTION" = "list" ]; then
  echo "Available skills:"
  echo "  weekend-project   Autonomous PR-by-PR project builder"
  echo "  code-better       40 stackable behavioural mode commands"
  exit 0
fi

if [ "$SCOPE" = "project" ]; then
  DEST_ROOT="$(pwd)/.claude/skills"
else
  DEST_ROOT="${HOME}/.claude/skills"
fi

if [ "$ACTION" = "uninstall" ]; then
  for skill in "${SELECTED[@]}"; do
    if [ -d "${DEST_ROOT}/${skill}" ]; then
      rm -rf "${DEST_ROOT:?}/${skill}"
      echo "Removed ${DEST_ROOT}/${skill}"
    else
      echo "Not installed: ${DEST_ROOT}/${skill}"
    fi
  done
  exit 0
fi

# Locate the source: the local clone if we're inside it, otherwise a temp clone.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
CLONE_DIR=""

if [ -n "$SCRIPT_DIR" ] && [ -d "${SCRIPT_DIR}/plugins" ]; then
  SRC_ROOT="$SCRIPT_DIR"
else
  command -v git >/dev/null 2>&1 || { echo "git is required to fetch the skills." >&2; exit 1; }
  CLONE_DIR="$(mktemp -d)"
  trap 'rm -rf "$CLONE_DIR"' EXIT
  echo "Fetching ${REPO_URL}..."
  git clone --depth 1 --quiet "$REPO_URL" "$CLONE_DIR"
  SRC_ROOT="$CLONE_DIR"
fi

mkdir -p "$DEST_ROOT"

for skill in "${SELECTED[@]}"; do
  SRC="${SRC_ROOT}/plugins/${skill}/skills/${skill}"
  DEST="${DEST_ROOT}/${skill}"

  if [ ! -f "${SRC}/SKILL.md" ]; then
    echo "Could not find SKILL.md at ${SRC}" >&2
    exit 1
  fi

  # Back up an existing install rather than clobbering local edits.
  if [ -d "$DEST" ]; then
    BACKUP="${DEST}.backup-$(date +%Y%m%d%H%M%S)"
    mv "$DEST" "$BACKUP"
    echo "Existing ${skill} moved to ${BACKUP}"
  fi

  cp -R "$SRC" "$DEST"
  find "$DEST" -name '.DS_Store' -delete 2>/dev/null || true
  echo "Installed ${skill} → ${DEST}"
done

echo
echo "Next: restart Claude Code (or run /reload-plugins) so it picks up the new skills."
echo
for skill in "${SELECTED[@]}"; do
  case "$skill" in
    weekend-project) echo "  weekend-project  cd into a project and run:  weekend-project" ;;
    code-better)     echo "  code-better      try:  cb-help   or   cb-read-only look at my auth code" ;;
  esac
done
echo
echo "Docs: https://github.com/maneja81/claude-skills"
