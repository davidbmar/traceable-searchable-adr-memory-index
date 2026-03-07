#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sprint-parse.sh
source "${SCRIPT_DIR}/sprint-parse.sh"

SESSION="sprint${SPRINT_NUM}"
LAUNCH_CMD="${SCRIPT_DIR}/sprint-launch.sh"

# Handle existing session
if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session '$SESSION' already exists."
  echo "  Attach:  tmux attach -t $SESSION"
  echo "  Kill:    tmux kill-session -t $SESSION"
  echo "  Force:   $0 --force"
  if [[ "${1:-}" == "--force" ]]; then
    tmux kill-session -t "$SESSION"
    echo "Killed existing session."
  else
    exit 1
  fi
fi

# Initialize Sprint-Notes.md (fresh per sprint)
cat > "$SPRINT_NOTES_FILE" <<EOF
# Sprint ${SPRINT_NUM} — Agent Notes

*Started: $(date -u '+%Y-%m-%d %H:%M UTC')*

Agents: ${#AGENTS[@]}
$(printf -- '- %s\n' "${AGENTS[@]}")

Automated summaries from each agent are appended below as they complete.
EOF
echo "Created ${SPRINT_NOTES_FILE}"

# Create tmux session with first agent tab
first_agent="${AGENTS[0]}"
tmux new-session -d -s "$SESSION" -n "$first_agent" \
  "unset CLAUDECODE; bash -lc '${LAUNCH_CMD} ${first_agent}; echo; echo === DONE — scroll up to review. This tab stays open. ===; exec bash'"

# Create a tab for each remaining agent
for agent in "${AGENTS[@]:1}"; do
  tmux new-window -t "$SESSION" -n "$agent" \
    "unset CLAUDECODE; bash -lc '${LAUNCH_CMD} ${agent}; echo; echo === DONE — scroll up to review. This tab stays open. ===; exec bash'"
done

# Select the first tab
tmux select-window -t "$SESSION:0"

NUM=${#AGENTS[@]}
LAST_IDX=$((NUM - 1))

echo ""
echo "=== Sprint ${SPRINT_NUM} — ${NUM} agents launched ==="
echo ""
for i in "${!AGENTS[@]}"; do
  echo "  [$i] ${AGENTS[$i]}"
done
echo ""
echo "Each agent will:"
echo "  1. Run Claude to implement its brief"
echo "  2. Append its summary to Sprint-Notes.md"
echo "  3. Run tests ($DEFAULT_TEST_CMD)"
echo "  4. Auto-commit if tests pass"
echo ""
echo "Navigation:"
echo "  Ctrl+B then n/p    — next/prev tab"
echo "  Ctrl+B then 0-${LAST_IDX}    — jump to tab by number"
echo "  Ctrl+B then w      — tab picker"
echo "  Ctrl+B then d      — detach (agents keep running)"
echo ""
echo "Lifecycle:"
echo "  tmux attach -t $SESSION       — reattach"
echo "  tmux kill-session -t $SESSION — stop everything"
echo ""
echo "Attaching now..."
exec tmux attach -t "$SESSION"
