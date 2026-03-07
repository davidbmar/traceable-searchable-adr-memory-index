#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sprint-parse.sh
source "${SCRIPT_DIR}/sprint-parse.sh"

echo "=== Sprint ${SPRINT_NUM} — Checkpoint ==="
git status
eval "$DEFAULT_TEST_CMD"
git diff --stat origin/main...HEAD
