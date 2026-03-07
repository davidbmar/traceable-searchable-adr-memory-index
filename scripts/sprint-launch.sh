#!/usr/bin/env bash
set -euo pipefail

# Allow launching Claude from within a parent Claude session (e.g. via tmux)
unset CLAUDECODE 2>/dev/null || true

if [ $# -ne 1 ]; then
  echo "Usage: scripts/sprint-launch.sh <agent-name>"
  exit 1
fi

AGENT="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sprint-parse.sh
source "${SCRIPT_DIR}/sprint-parse.sh"

WT="${SPRINT_BASE}/${AGENT}"
PROMPT_FILE="${ROOT}/scripts/CLAUDE_RUN_PROMPT.txt"

if [ ! -d "${WT}" ]; then
  echo "Worktree not found: ${WT}"
  echo "Run: ./scripts/sprint-init.sh"
  exit 1
fi

if [ ! -f "${PROMPT_FILE}" ]; then
  echo "Prompt file not found: ${PROMPT_FILE}"
  exit 1
fi

PROMPT="$(cat "${PROMPT_FILE}")"

cd "${WT}"
echo "=== [$AGENT] Sprint ${SPRINT_NUM} — Launching Claude in: ${WT} ==="

# --- Phase 1: Run Claude agent and capture output ---
OUTPUT_FILE="${WT}/.claude-output.txt"
set +e
claude --dangerously-skip-permissions -p "$PROMPT" 2>&1 | tee "$OUTPUT_FILE"
CLAUDE_EXIT=$?
set -e

echo ""
echo "=== [$AGENT] Claude finished (exit $CLAUDE_EXIT) ==="

# --- Phase 2: Append summary to Sprint-Notes.md ---
{
  echo ""
  echo "---"
  echo ""
  echo "## ${AGENT}"
  echo ""
  echo "*Completed: $(date -u '+%Y-%m-%d %H:%M UTC')*"
  echo ""
  # Extract the summary section (everything after the last "Files changed" heading)
  # If that's not found, include the last 60 lines as a fallback
  if grep -qn "Files changed" "$OUTPUT_FILE"; then
    sed -n '/Files changed/,$p' "$OUTPUT_FILE" | tail -200
  else
    echo '```'
    tail -60 "$OUTPUT_FILE"
    echo '```'
  fi
  echo ""
} >> "$SPRINT_NOTES_FILE"

echo "=== [$AGENT] Summary appended to Sprint-Notes.md ==="

# --- Phase 3: Checkpoint — status, tests, diff ---
echo ""
echo "=== [$AGENT] Running checkpoint ==="

echo "--- git status ---"
git status

echo ""
echo "--- Running tests ---"
set +e
eval "$DEFAULT_TEST_CMD" 2>&1
TEST_EXIT=$?
set -e

echo ""
echo "--- git diff --stat vs main ---"
git diff --stat origin/main...HEAD

# --- Phase 4: Commit if tests pass ---
echo ""
if [ $TEST_EXIT -eq 0 ]; then
  echo "=== [$AGENT] Tests passed — committing ==="

  SESSION_ID="S-$(date -u +%Y-%m-%d-%H%M)-${AGENT}"

  git add -A
  if git diff --cached --quiet; then
    echo "No changes to commit."
  else
    git commit -m "$(cat <<EOF
${AGENT}: implement sprint ${SPRINT_NUM} tasks

Session: ${SESSION_ID}
Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
    echo "=== [$AGENT] Committed on branch $(git branch --show-current) ==="
  fi
else
  echo "=== [$AGENT] Tests FAILED (exit $TEST_EXIT) — skipping commit ==="
  echo "Review output above and fix manually."
fi

echo ""
echo "=== [$AGENT] Done ==="
