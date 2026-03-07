#!/usr/bin/env bash
# Sprint orchestration — centralized configuration.
# Source this file (via sprint-parse.sh) — do not execute directly.
#
# Override any variable before sourcing, or edit defaults here.
# All variables use ${VAR:-default} so they work without modification.

# Project slug — used to name the sibling worktree directory.
# Default: derived from the repo directory name.
SCRIPT_DIR_CFG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_CFG="$(cd "${SCRIPT_DIR_CFG}/.." && pwd -P)"
PROJECT_SLUG="${PROJECT_SLUG:-$(basename "$ROOT_CFG")}"

# Test command — run after agent work and after each merge.
# Default: safe no-op echo (override to your project's test runner).
DEFAULT_TEST_CMD="${DEFAULT_TEST_CMD:-echo 'No test command configured — set DEFAULT_TEST_CMD in sprint-config.sh'}"

# Sprint notes file — agent summaries are appended here.
SPRINT_NOTES_FILE="${SPRINT_NOTES_FILE:-${ROOT_CFG}/Sprint-Notes.md}"

# Ephemeral files — auto-resolved with --theirs during merge conflicts.
# Override by setting EPHEMERAL_FILES before sourcing, or edit this list.
if [ -z "${EPHEMERAL_FILES+x}" ]; then
  EPHEMERAL_FILES=(
    "AGENT_BRIEF.md"
    ".claude-output.txt"
    "docs/project-memory/.index/last-updated.txt"
  )
fi

# Sprint report generation (opt-in).
GENERATE_SPRINT_REPORT="${GENERATE_SPRINT_REPORT:-false}"

# Report output paths (only used when GENERATE_SPRINT_REPORT=true).
STATUS_DIR="${STATUS_DIR:-${ROOT_CFG}/docs}"
STATUS_PREFIX="${STATUS_PREFIX:-PROJECT_STATUS}"
