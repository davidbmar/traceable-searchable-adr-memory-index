#!/bin/bash
# Test suite for Project Memory index builder

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

echo "Running Project Memory Index Builder Tests..."
echo "Test directory: $TEST_DIR"
echo ""

# Helper functions
assert_file_exists() {
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} File exists: $1"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} File missing: $1"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_contains() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local file="$1"
    local pattern="$2"
    local description="$3"

    if grep -q "$pattern" "$file"; then
        echo -e "${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $description (pattern not found: $pattern)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_json_valid() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local file="$1"

    if jq empty "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Valid JSON: $file"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} Invalid JSON: $file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_equals() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local expected="$1"
    local actual="$2"
    local description="$3"

    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓${NC} $description (expected: $expected, got: $actual)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $description (expected: $expected, got: $actual)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Test 1: Build index with sample sessions
test_build_with_sessions() {
    echo -e "\n${YELLOW}Test 1: Build index with sample sessions${NC}"

    local TEST_DIR=$(mktemp -d)
    trap "rm -rf $TEST_DIR" RETURN

    mkdir -p "$TEST_DIR/docs/project-memory/sessions"
    mkdir -p "$TEST_DIR/docs/project-memory/.index"

    # Create test session files
    cat > "$TEST_DIR/docs/project-memory/sessions/S-2026-01-01-1000-test-one.md" << 'EOF'
# Session: S-2026-01-01-1000-test-one

**Date:** 2026-01-01
**Status:** Complete

## Goal
Test authentication system

## Context
Adding OAuth support to the application

## Changes Made
- Implemented JWT tokens
- Added login endpoint
EOF

    cat > "$TEST_DIR/docs/project-memory/sessions/S-2026-01-02-1400-test-two.md" << 'EOF'
# Session: S-2026-01-02-1400-test-two

**Date:** 2026-01-02
**Status:** In Progress

## Goal
Improve database performance

## Context
Users experiencing slow query times

## Changes Made
- Added indexes to user table
- Optimized JOIN queries
EOF

    # Run build script
    cd "$TEST_DIR"
    bash "$OLDPWD/scripts/build-index.sh" > /dev/null 2>&1

    # Assertions
    assert_file_exists "$TEST_DIR/docs/project-memory/.index/keywords.json"
    assert_file_exists "$TEST_DIR/docs/project-memory/.index/metadata.json"
    assert_file_exists "$TEST_DIR/docs/project-memory/.index/sessions.txt"

    assert_json_valid "$TEST_DIR/docs/project-memory/.index/keywords.json"
    assert_json_valid "$TEST_DIR/docs/project-memory/.index/metadata.json"

    # Check session count
    local session_count=$(jq '.sessionCount' "$TEST_DIR/docs/project-memory/.index/metadata.json")
    assert_equals "2" "$session_count" "Metadata shows correct session count"

    # Check keywords.json contains session IDs
    assert_contains "$TEST_DIR/docs/project-memory/.index/keywords.json" "S-2026-01-01-1000-test-one" "Keywords contains first session ID"
    assert_contains "$TEST_DIR/docs/project-memory/.index/keywords.json" "S-2026-01-02-1400-test-two" "Keywords contains second session ID"

    # Check keywords.json contains content
    assert_contains "$TEST_DIR/docs/project-memory/.index/keywords.json" "authentication" "Keywords contains session content (authentication)"
    assert_contains "$TEST_DIR/docs/project-memory/.index/keywords.json" "database" "Keywords contains session content (database)"

    # Check sessions.txt contains full content
    assert_contains "$TEST_DIR/docs/project-memory/.index/sessions.txt" "OAuth support" "Sessions.txt contains full session text"
    assert_contains "$TEST_DIR/docs/project-memory/.index/sessions.txt" "JWT tokens" "Sessions.txt contains implementation details"

    cd "$OLDPWD"
}

# Test 2: Build index with no sessions
test_build_empty() {
    echo -e "\n${YELLOW}Test 2: Build index with no sessions${NC}"

    local TEST_DIR=$(mktemp -d)
    trap "rm -rf $TEST_DIR" RETURN

    mkdir -p "$TEST_DIR/docs/project-memory/sessions"
    mkdir -p "$TEST_DIR/docs/project-memory/.index"

    # Run build script (should handle empty gracefully)
    cd "$TEST_DIR"
    bash "$OLDPWD/scripts/build-index.sh" > /dev/null 2>&1 || true

    # Check files were created
    assert_file_exists "$TEST_DIR/docs/project-memory/.index/metadata.json"

    # Check session count is 0
    local session_count=$(jq '.sessionCount' "$TEST_DIR/docs/project-memory/.index/metadata.json" 2>/dev/null || echo "0")
    assert_equals "0" "$session_count" "Empty directory shows 0 sessions"

    cd "$OLDPWD"
}

# Test 3: Index contains proper metadata
test_metadata_format() {
    echo -e "\n${YELLOW}Test 3: Verify metadata format${NC}"

    local TEST_DIR=$(mktemp -d)
    trap "rm -rf $TEST_DIR" RETURN

    mkdir -p "$TEST_DIR/docs/project-memory/sessions"
    mkdir -p "$TEST_DIR/docs/project-memory/.index"

    cat > "$TEST_DIR/docs/project-memory/sessions/S-2026-01-15-0900-metadata-test.md" << 'EOF'
# Session: S-2026-01-15-0900-metadata-test

Test session
EOF

    cd "$TEST_DIR"
    bash "$OLDPWD/scripts/build-index.sh" > /dev/null 2>&1

    # Check metadata has required fields
    local has_built=$(jq 'has("built")' "$TEST_DIR/docs/project-memory/.index/metadata.json")
    local has_count=$(jq 'has("sessionCount")' "$TEST_DIR/docs/project-memory/.index/metadata.json")

    assert_equals "true" "$has_built" "Metadata contains 'built' timestamp"
    assert_equals "true" "$has_count" "Metadata contains 'sessionCount'"

    # Verify timestamp format (ISO 8601)
    assert_contains "$TEST_DIR/docs/project-memory/.index/metadata.json" '"built": "20[0-9][0-9]-' "Timestamp is ISO 8601 format"

    cd "$OLDPWD"
}

# Test 4: Handle special characters in content
test_special_characters() {
    echo -e "\n${YELLOW}Test 4: Handle special characters${NC}"

    local TEST_DIR=$(mktemp -d)
    trap "rm -rf $TEST_DIR" RETURN

    mkdir -p "$TEST_DIR/docs/project-memory/sessions"
    mkdir -p "$TEST_DIR/docs/project-memory/.index"

    cat > "$TEST_DIR/docs/project-memory/sessions/S-2026-01-20-1200-special-chars.md" << 'EOF'
# Session: S-2026-01-20-1200-special-chars

## Goal
Test special characters: "quotes", 'apostrophes', & ampersands, <tags>, $variables

## Code
```javascript
const config = { "api": "https://example.com/api?key=123&token=xyz" };
```
EOF

    cd "$TEST_DIR"
    bash "$OLDPWD/scripts/build-index.sh" > /dev/null 2>&1

    # Should still produce valid JSON
    assert_json_valid "$TEST_DIR/docs/project-memory/.index/keywords.json"
    assert_contains "$TEST_DIR/docs/project-memory/.index/keywords.json" "special characters" "Content with special chars indexed"

    cd "$OLDPWD"
}

# Test 5: Session ID extraction
test_session_id_extraction() {
    echo -e "\n${YELLOW}Test 5: Session ID extraction${NC}"

    local TEST_DIR=$(mktemp -d)
    trap "rm -rf $TEST_DIR" RETURN

    mkdir -p "$TEST_DIR/docs/project-memory/sessions"
    mkdir -p "$TEST_DIR/docs/project-memory/.index"

    cat > "$TEST_DIR/docs/project-memory/sessions/S-2026-02-09-1530-id-test.md" << 'EOF'
# Session: S-2026-02-09-1530-id-test

Test content
EOF

    cd "$TEST_DIR"
    bash "$OLDPWD/scripts/build-index.sh" > /dev/null 2>&1

    # Check that session ID appears in the index
    local session_id=$(jq -r '.sessions[0].id' "$TEST_DIR/docs/project-memory/.index/keywords.json")
    assert_equals "S-2026-02-09-1530-id-test" "$session_id" "Session ID correctly extracted from filename"

    cd "$OLDPWD"
}

# Test 6: Multiple sessions sorted correctly
test_session_sorting() {
    echo -e "\n${YELLOW}Test 6: Sessions sorted by filename${NC}"

    local TEST_DIR=$(mktemp -d)
    trap "rm -rf $TEST_DIR" RETURN

    mkdir -p "$TEST_DIR/docs/project-memory/sessions"
    mkdir -p "$TEST_DIR/docs/project-memory/.index"

    # Create sessions in reverse order
    echo "# Session C" > "$TEST_DIR/docs/project-memory/sessions/S-2026-03-01-0000-charlie.md"
    echo "# Session A" > "$TEST_DIR/docs/project-memory/sessions/S-2026-01-01-0000-alpha.md"
    echo "# Session B" > "$TEST_DIR/docs/project-memory/sessions/S-2026-02-01-0000-bravo.md"

    cd "$TEST_DIR"
    bash "$OLDPWD/scripts/build-index.sh" > /dev/null 2>&1

    # Check order in keywords.json
    local first_id=$(jq -r '.sessions[0].id' "$TEST_DIR/docs/project-memory/.index/keywords.json")
    local second_id=$(jq -r '.sessions[1].id' "$TEST_DIR/docs/project-memory/.index/keywords.json")
    local third_id=$(jq -r '.sessions[2].id' "$TEST_DIR/docs/project-memory/.index/keywords.json")

    assert_equals "S-2026-01-01-0000-alpha" "$first_id" "First session is alpha"
    assert_equals "S-2026-02-01-0000-bravo" "$second_id" "Second session is bravo"
    assert_equals "S-2026-03-01-0000-charlie" "$third_id" "Third session is charlie"

    cd "$OLDPWD"
}

# Test 7: Real project sessions
test_real_project_sessions() {
    echo -e "\n${YELLOW}Test 7: Build index from real project sessions${NC}"

    # Use actual project directory
    bash scripts/build-index.sh > /dev/null 2>&1

    assert_file_exists "docs/project-memory/.index/keywords.json"
    assert_file_exists "docs/project-memory/.index/metadata.json"
    assert_file_exists "docs/project-memory/.index/sessions.txt"

    assert_json_valid "docs/project-memory/.index/keywords.json"
    assert_json_valid "docs/project-memory/.index/metadata.json"

    # Verify actual sessions are indexed
    local session_count=$(jq '.sessionCount' "docs/project-memory/.index/metadata.json")
    echo "  Real project has $session_count sessions"

    if [ "$session_count" -gt 0 ]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        echo -e "${GREEN}✓${NC} Real project sessions indexed (count: $session_count)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
}

# Run all tests
test_build_with_sessions
test_build_empty
test_metadata_format
test_special_characters
test_session_id_extraction
test_session_sorting
test_real_project_sessions

# Print summary
echo ""
echo "================================"
echo "Test Summary"
echo "================================"
echo -e "Total tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
