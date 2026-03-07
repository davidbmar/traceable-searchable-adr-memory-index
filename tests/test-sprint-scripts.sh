#!/bin/bash
# Test suite for sprint orchestration scripts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

echo "Running Sprint Script Tests..."
echo ""

# Helper functions
assert_equals() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local label="$1"
    local expected="$2"
    local actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓${NC} ${label}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} ${label}"
        echo "    expected: '${expected}'"
        echo "    actual:   '${actual}'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_contains() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local label="$1"
    local haystack="$2"
    local needle="$3"
    if echo "$haystack" | grep -qF "$needle"; then
        echo -e "${GREEN}✓${NC} ${label}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} ${label}"
        echo "    '${needle}' not found in output"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_file_exists() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local label="$1"
    local file="$2"
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} ${label}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} ${label}: ${file}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# --- Setup: create temp dir with mock repo structure ---
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Create mock repo structure
mkdir -p "$TMPDIR/repo/scripts"
cp scripts/sprint-config.sh "$TMPDIR/repo/scripts/"
cp scripts/sprint-parse.sh "$TMPDIR/repo/scripts/"

# ========================================
# Suite 1: sprint-config.sh
# ========================================
echo "--- Suite: sprint-config.sh ---"

assert_file_exists "sprint-config.sh exists" "scripts/sprint-config.sh"

# Test that config can be sourced
(
    source "$TMPDIR/repo/scripts/sprint-config.sh"
    # PROJECT_SLUG should be derived from directory name
    [ -n "$PROJECT_SLUG" ]
) && {
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${GREEN}✓${NC} sprint-config.sh sources without error"
    TESTS_PASSED=$((TESTS_PASSED + 1))
} || {
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${RED}✗${NC} sprint-config.sh sources without error"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Test PROJECT_SLUG default (derived from repo dir name)
SLUG=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-config.sh && echo "$PROJECT_SLUG"')
assert_equals "PROJECT_SLUG defaults to repo dir name" "repo" "$SLUG"

# Test PROJECT_SLUG override
SLUG_OVERRIDE=$(cd "$TMPDIR/repo" && bash -c 'PROJECT_SLUG=my-project; source scripts/sprint-config.sh && echo "$PROJECT_SLUG"')
assert_equals "PROJECT_SLUG can be overridden" "my-project" "$SLUG_OVERRIDE"

# Test DEFAULT_TEST_CMD default
TEST_CMD=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-config.sh && echo "$DEFAULT_TEST_CMD"')
assert_contains "DEFAULT_TEST_CMD has safe default" "$TEST_CMD" "No test command configured"

# Test DEFAULT_TEST_CMD override
TEST_CMD_OVERRIDE=$(cd "$TMPDIR/repo" && bash -c 'DEFAULT_TEST_CMD="pytest"; source scripts/sprint-config.sh && echo "$DEFAULT_TEST_CMD"')
assert_equals "DEFAULT_TEST_CMD can be overridden" "pytest" "$TEST_CMD_OVERRIDE"

# Test GENERATE_SPRINT_REPORT default
REPORT=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-config.sh && echo "$GENERATE_SPRINT_REPORT"')
assert_equals "GENERATE_SPRINT_REPORT defaults to false" "false" "$REPORT"

echo ""

# ========================================
# Suite 2: sprint-parse.sh
# ========================================
echo "--- Suite: sprint-parse.sh ---"

assert_file_exists "sprint-parse.sh exists" "scripts/sprint-parse.sh"

# Create a mock SPRINT_BRIEF.md
cat > "$TMPDIR/repo/SPRINT_BRIEF.md" << 'BRIEF'
# Sprint 5

Goal
- Build user authentication
- Add API documentation

Constraints
- Do not modify existing database schema
- All endpoints must include tests

Merge Order
1. agentC-add-docs
2. agentB-user-model
3. agentA-auth-endpoints

Merge Verification
- pytest
- mypy src/

## agentA-auth-endpoints

Objective
- Build JWT authentication endpoints

Tasks
- Create auth routes
- Add JWT utilities

Acceptance Criteria
- Login returns JWT token
- All tests pass

## agentB-user-model

Objective
- Create user database model

Tasks
- Add user migration
- Create user model

Acceptance Criteria
- CRUD operations work
- All tests pass

## agentC-add-docs

Objective
- Add OpenAPI documentation

Tasks
- Create openapi.yaml

Acceptance Criteria
- Docs load at /api/docs
BRIEF

# Initialize git repo so sprint-parse can work
(cd "$TMPDIR/repo" && git init -q && git add -A && git commit -q -m "init")

# Test SPRINT_NUM extraction
SPRINT_NUM=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-parse.sh && echo "$SPRINT_NUM"' 2>/dev/null)
assert_equals "SPRINT_NUM parsed correctly" "5" "$SPRINT_NUM"

# Test AGENTS array
AGENTS_STR=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-parse.sh && echo "${AGENTS[@]}"' 2>/dev/null)
assert_equals "AGENTS parsed correctly" "agentA-auth-endpoints agentB-user-model agentC-add-docs" "$AGENTS_STR"

# Test agent count
AGENT_COUNT=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-parse.sh && echo "${#AGENTS[@]}"' 2>/dev/null)
assert_equals "Agent count is 3" "3" "$AGENT_COUNT"

# Test MERGE_ORDER
MERGE_ORDER_STR=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-parse.sh && echo "${MERGE_ORDER[@]}"' 2>/dev/null)
assert_equals "MERGE_ORDER parsed correctly" "agentC-add-docs agentB-user-model agentA-auth-endpoints" "$MERGE_ORDER_STR"

# Test MERGE_VERIFY
MERGE_VERIFY_STR=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-parse.sh && echo "${MERGE_VERIFY[0]}"' 2>/dev/null)
assert_equals "MERGE_VERIFY[0] parsed correctly" "pytest" "$MERGE_VERIFY_STR"

MERGE_VERIFY_1=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-parse.sh && echo "${MERGE_VERIFY[1]}"' 2>/dev/null)
assert_equals "MERGE_VERIFY[1] parsed correctly" "mypy src/" "$MERGE_VERIFY_1"

# Test SPRINT_BASE uses PROJECT_SLUG
SPRINT_BASE=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-parse.sh && echo "$SPRINT_BASE"' 2>/dev/null)
assert_contains "SPRINT_BASE uses PROJECT_SLUG" "$SPRINT_BASE" "repo-agents-sprint5"

# Test get_agent_brief
AGENT_BRIEF=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-parse.sh && get_agent_brief "agentA-auth-endpoints"' 2>/dev/null)
assert_contains "get_agent_brief returns agent content" "$AGENT_BRIEF" "Build JWT authentication endpoints"

# Test AGENT_META excludes Merge Order
AGENT_META=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-parse.sh && echo "$AGENT_META"' 2>/dev/null)
assert_contains "AGENT_META includes Goal" "$AGENT_META" "Build user authentication"

# Verify Merge Order is NOT in AGENT_META
TESTS_RUN=$((TESTS_RUN + 1))
if echo "$AGENT_META" | grep -qF "Merge Order"; then
    echo -e "${RED}✗${NC} AGENT_META excludes Merge Order"
    TESTS_FAILED=$((TESTS_FAILED + 1))
else
    echo -e "${GREEN}✓${NC} AGENT_META excludes Merge Order"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

echo ""

# ========================================
# Suite 3: MERGE_VERIFY fallback
# ========================================
echo "--- Suite: MERGE_VERIFY fallback ---"

# Create a brief with no Merge Verification section
cat > "$TMPDIR/repo/SPRINT_BRIEF.md" << 'BRIEF'
# Sprint 1

Goal
- Test default behavior

## agentA-test

Objective
- Test

Tasks
- Test

Acceptance Criteria
- Tests pass
BRIEF

(cd "$TMPDIR/repo" && git add -A && git commit -q -m "update brief")

# Test that MERGE_VERIFY falls back to DEFAULT_TEST_CMD
VERIFY_FALLBACK=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-parse.sh && echo "${MERGE_VERIFY[0]}"' 2>/dev/null)
assert_contains "MERGE_VERIFY falls back to DEFAULT_TEST_CMD" "$VERIFY_FALLBACK" "No test command configured"

# Test MERGE_ORDER falls back to AGENTS when not specified
MERGE_ORDER_FALLBACK=$(cd "$TMPDIR/repo" && bash -c 'source scripts/sprint-parse.sh && echo "${MERGE_ORDER[@]}"' 2>/dev/null)
assert_equals "MERGE_ORDER falls back to AGENTS" "agentA-test" "$MERGE_ORDER_FALLBACK"

echo ""

# ========================================
# Suite 4: File existence checks
# ========================================
echo "--- Suite: File existence ---"

assert_file_exists "sprint-init.sh exists" "scripts/sprint-init.sh"
assert_file_exists "sprint-launch.sh exists" "scripts/sprint-launch.sh"
assert_file_exists "sprint-tmux.sh exists" "scripts/sprint-tmux.sh"
assert_file_exists "sprint-merge.sh exists" "scripts/sprint-merge.sh"
assert_file_exists "sprint-checkpoint.sh exists" "scripts/sprint-checkpoint.sh"
assert_file_exists "CLAUDE_RUN_PROMPT.txt exists" "scripts/CLAUDE_RUN_PROMPT.txt"
assert_file_exists "SPRINT_BRIEF_SPEC.md exists" "docs/project-memory/tools/SPRINT_BRIEF_SPEC.md"
assert_file_exists "SPRINT_BRIEF_TEMPLATE.md exists" "docs/project-memory/tools/SPRINT_BRIEF_TEMPLATE.md"

echo ""

# ========================================
# Results
# ========================================
echo "========================================="
echo "Sprint Script Tests: ${TESTS_RUN} run, ${TESTS_PASSED} passed, ${TESTS_FAILED} failed"
echo "========================================="

if [ "$TESTS_FAILED" -gt 0 ]; then
    exit 1
fi
