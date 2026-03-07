#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=./sprint-parse.sh
source "${SCRIPT_DIR}/sprint-parse.sh"

echo "=== Sprint ${SPRINT_NUM} — Merging ${#MERGE_ORDER[@]} branches ==="
echo ""
echo "Merge order:"
for i in "${!MERGE_ORDER[@]}"; do
  echo "  $((i+1)). ${MERGE_ORDER[$i]}"
done
echo ""
echo "Verification after each merge:"
for cmd in "${MERGE_VERIFY[@]}"; do
  echo "  - ${cmd}"
done
echo ""

# Confirm we're on main
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "Error: Must be on main branch (currently on '${CURRENT_BRANCH}')"
  exit 1
fi

MERGED=0
TOTAL=${#MERGE_ORDER[@]}

for agent in "${MERGE_ORDER[@]}"; do
  MERGED=$((MERGED + 1))
  echo "=== [$MERGED/$TOTAL] Merging ${agent} ==="

  # Check branch exists
  if ! git rev-parse --verify "$agent" >/dev/null 2>&1; then
    echo "Error: Branch '${agent}' does not exist"
    exit 1
  fi

  # Attempt merge
  if git merge "$agent" --no-edit 2>&1; then
    echo "[clean]   ${agent} merged without conflicts"
  else
    echo "[conflict] Attempting auto-resolution of ephemeral files..."

    # Try to resolve known ephemeral file conflicts
    UNRESOLVED=false
    for file in $(git diff --name-only --diff-filter=U); do
      IS_EPHEMERAL=false
      for eph in "${EPHEMERAL_FILES[@]}"; do
        if [[ "$file" == "$eph" ]] || [[ "$file" == docs/project-memory/.index/* ]]; then
          IS_EPHEMERAL=true
          break
        fi
      done

      if $IS_EPHEMERAL; then
        git checkout --theirs "$file" 2>/dev/null && git add "$file"
        echo "  [auto]  ${file} — accepted theirs"
      else
        UNRESOLVED=true
        echo "  [MANUAL] ${file} — requires manual resolution"
      fi
    done

    if $UNRESOLVED; then
      echo ""
      echo "=== MERGE PAUSED ==="
      echo "Resolve the conflicts above, then run:"
      echo "  git add <resolved files>"
      echo "  git commit --no-edit"
      echo "  ./scripts/sprint-merge.sh --continue"
      exit 1
    fi

    # All conflicts were ephemeral — commit
    git add docs/project-memory/.index/ 2>/dev/null || true
    git commit --no-edit
    echo "[resolved] ${agent} merged (ephemeral conflicts auto-resolved)"
  fi

  # Run verification after each merge
  echo ""
  echo "--- Verification ---"
  for cmd in "${MERGE_VERIFY[@]}"; do
    echo "Running: ${cmd}"
    if eval "$cmd" 2>&1; then
      echo "[pass] ${cmd}"
    else
      echo ""
      echo "=== VERIFICATION FAILED ==="
      echo "Command failed: ${cmd}"
      echo "Branch ${agent} was merged but verification failed."
      echo "Fix the issue, commit, then continue with remaining merges."
      exit 1
    fi
    echo ""
  done

  echo "[ok] ${agent} merged and verified"
  echo ""
done

echo "========================================="
echo "  Sprint ${SPRINT_NUM} — All ${TOTAL} branches merged"
echo "========================================="
echo ""

# --- Optional: Generate Sprint Summary & Project Status ---
if [ "$GENERATE_SPRINT_REPORT" = "true" ]; then
  echo "=== Generating Sprint ${SPRINT_NUM} project status report ==="
  echo ""

  PREV_STATUS=$(ls -1 "${STATUS_DIR}/${STATUS_PREFIX}_"*.md 2>/dev/null | sort | tail -1)
  STATUS_FILE="${STATUS_DIR}/${STATUS_PREFIX}_$(date -u +%-m-%-d)-sprint${SPRINT_NUM}.md"

  REPORT_PROMPT="Generate the Sprint ${SPRINT_NUM} project status document.

You MUST follow the exact format and sections used in the previous status doc.
Read the previous status document, Sprint-Notes.md, and the SPRINT_BRIEF.md to understand what was done.
Then produce a comprehensive project status document.

Previous status doc: ${PREV_STATUS}
Sprint notes: ${SPRINT_NOTES_FILE}
Sprint brief: ${ROOT}/SPRINT_BRIEF.md

Save the report to: ${STATUS_FILE}
After saving, commit it with message: 'Add Sprint ${SPRINT_NUM} project status document'
Do NOT push — leave that for the user."

  unset CLAUDECODE
  if claude --dangerously-skip-permissions -p "$REPORT_PROMPT" 2>&1; then
    echo ""
    echo "[ok] Project status report generated: ${STATUS_FILE}"
  else
    echo ""
    echo "[warn] Report generation failed. Generate manually."
  fi
fi

echo ""
echo "========================================="
echo "  Sprint ${SPRINT_NUM} — Complete"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Review Sprint-Notes.md"
echo "  2. git push origin main"
