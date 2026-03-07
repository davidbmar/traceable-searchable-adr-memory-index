#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sprint-parse.sh
source "${SCRIPT_DIR}/sprint-parse.sh"

echo "=== Sprint ${SPRINT_NUM} — Initializing ${#AGENTS[@]} agents ==="
echo ""

mkdir -p "${SPRINT_BASE}"

for agent in "${AGENTS[@]}"; do
  WT="${SPRINT_BASE}/${agent}"

  # Create worktree if needed
  WT_ABS="$(cd "$WT" 2>/dev/null && pwd -P || echo "$WT")"
  if git worktree list | awk '{print $1}' | grep -qxF "$WT_ABS"; then
    echo "[exists]  ${agent}"
  elif [ -d "${WT}" ]; then
    echo "[error]   Directory exists but not a worktree: ${WT}"
    echo "          Remove it manually and rerun."
    exit 1
  else
    git worktree add "${WT}" -b "${agent}"
    echo "[created] ${agent}"
  fi

  # Write per-agent AGENT_BRIEF.md (with sprint-level constraints prepended)
  brief_content=$(get_agent_brief "$agent")
  {
    echo "${agent} — Sprint ${SPRINT_NUM}"
    echo ""
    # Inject sprint-level Goal + Constraints (not Merge Order/Verification)
    if [ -n "$(echo "$AGENT_META" | tr -d '[:space:]')" ]; then
      echo "Sprint-Level Context"
      echo "$AGENT_META"
      echo ""
    fi
    echo "$brief_content"
  } > "${WT}/AGENT_BRIEF.md"
  echo "          -> AGENT_BRIEF.md written"
done

echo ""
echo "Worktrees created under: ${SPRINT_BASE}"
echo ""
echo "Next: ./scripts/sprint-tmux.sh"
