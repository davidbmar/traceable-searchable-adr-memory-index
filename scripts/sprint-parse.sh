#!/usr/bin/env bash
# Shared parsing logic for SPRINT_BRIEF.md
# Source this file — do not execute directly.
#
# After sourcing, these are available:
#   SPRINT_NUM      — integer sprint number
#   SPRINT_META     — goal/constraints text from the meta block
#   AGENTS          — array of agent names (from ## headings)
#   MERGE_ORDER     — array of agent names in merge order (from Merge Order section)
#   MERGE_VERIFY    — array of verification commands (from Merge Verification section)
#   BRIEF_FILE      — path to SPRINT_BRIEF.md
#
# Functions:
#   get_agent_brief <agent-name>  — prints that agent's brief content
#   get_sprint_meta               — prints the meta block

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"

# Source centralized configuration
# shellcheck source=./sprint-config.sh
source "${SCRIPT_DIR}/sprint-config.sh"

BRIEF_FILE="${ROOT}/SPRINT_BRIEF.md"

if [ ! -f "$BRIEF_FILE" ]; then
  echo "Error: SPRINT_BRIEF.md not found at ${BRIEF_FILE}"
  echo "Create it in the repo root before running sprint scripts."
  exit 1
fi

# Parse sprint number from first # heading
SPRINT_NUM=$(grep -m1 '^# Sprint ' "$BRIEF_FILE" | sed 's/^# Sprint //')
if [ -z "$SPRINT_NUM" ]; then
  echo "Error: Could not find '# Sprint <number>' heading in ${BRIEF_FILE}"
  exit 1
fi

# Parse agent names from ## headings
AGENTS=()
while IFS= read -r line; do
  agent_name=$(echo "$line" | sed 's/^## //')
  AGENTS+=("$agent_name")
done < <(grep '^## ' "$BRIEF_FILE")

if [ ${#AGENTS[@]} -eq 0 ]; then
  echo "Error: No agent sections (## headings) found in ${BRIEF_FILE}"
  exit 1
fi

# Derived paths — uses PROJECT_SLUG from sprint-config.sh
SPRINT_BASE="${SPRINT_BASE:-${ROOT}/../${PROJECT_SLUG}-agents-sprint${SPRINT_NUM}}"

# Extract the sprint meta block (everything between # Sprint N and the first ## heading)
get_sprint_meta() {
  awk '
    BEGIN { found=0 }
    /^# Sprint / { found=1; next }
    /^## / { exit }
    found { print }
  ' "$BRIEF_FILE"
}

SPRINT_META=$(get_sprint_meta)

# Extract only the agent-facing parts of the meta block (excludes Merge Order and Merge Verification)
get_agent_meta() {
  echo "$SPRINT_META" | awk '
    /^Merge Order/ { skip=1 }
    /^Merge Verification/ { skip=1 }
    /^[A-Z]/ && !/^Merge/ { skip=0 }
    !skip { print }
  '
}

AGENT_META=$(get_agent_meta)

# Parse merge order from the meta block (lines after "Merge Order" that start with a number)
MERGE_ORDER=()
while IFS= read -r line; do
  # Strip leading number, dot, and whitespace: "1. agentC-foo" -> "agentC-foo"
  agent_name=$(echo "$line" | sed 's/^[0-9][0-9]*\.[[:space:]]*//')
  MERGE_ORDER+=("$agent_name")
done < <(echo "$SPRINT_META" | awk '
  /^Merge Order/ { found=1; next }
  /^[A-Z]/ { if (found) exit }
  /^$/ { if (found) exit }
  found && /^[0-9]/ { print }
')

# If no merge order specified, fall back to agent order from ## headings
if [ ${#MERGE_ORDER[@]} -eq 0 ]; then
  MERGE_ORDER=("${AGENTS[@]}")
fi

# Parse merge verification commands (lines after "Merge Verification" that start with -)
MERGE_VERIFY=()
while IFS= read -r line; do
  cmd=$(echo "$line" | sed 's/^-[[:space:]]*//')
  MERGE_VERIFY+=("$cmd")
done < <(echo "$SPRINT_META" | awk '
  /^Merge Verification/ { found=1; next }
  /^[A-Z]/ { if (found) exit }
  /^$/ { if (found) exit }
  found && /^-/ { print }
')

# Default verification if none specified — uses DEFAULT_TEST_CMD from sprint-config.sh
if [ ${#MERGE_VERIFY[@]} -eq 0 ]; then
  MERGE_VERIFY=("$DEFAULT_TEST_CMD")
fi

# Extract the brief content for a given agent (everything between its ## and the next ## or EOF)
get_agent_brief() {
  local agent="$1"
  awk -v agent="$agent" '
    BEGIN { found=0 }
    /^## / {
      if (found) exit
      if ($0 == "## " agent) { found=1; next }
    }
    found { print }
  ' "$BRIEF_FILE"
}
