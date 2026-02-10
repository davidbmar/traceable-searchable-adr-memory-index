#!/bin/bash
# Build Project Memory index from session files
# Pure bash implementation - no dependencies

set -e

INDEX_DIR="docs/project-memory/.index"
SESSIONS_DIR="docs/project-memory/sessions"

# Create index directory if it doesn't exist
mkdir -p "$INDEX_DIR"

echo "Building Project Memory index..."

# Count session files
SESSION_COUNT=$(find "$SESSIONS_DIR" -name "S-*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "Found $SESSION_COUNT session files"

# Build keywords.json
echo "{" > "$INDEX_DIR/keywords.json"
echo "  \"sessions\": [" >> "$INDEX_DIR/keywords.json"

FIRST=true
find "$SESSIONS_DIR" -name "S-*.md" | sort | while read -r file; do
    SESSION_ID=$(basename "$file" .md)

    # Extract text content (remove markdown headers)
    CONTENT=$(cat "$file" | grep -v "^#" | tr '\n' ' ' | tr -s ' ')

    # Add comma for all but first entry
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo "," >> "$INDEX_DIR/keywords.json"
    fi

    # Write session entry
    echo "    {" >> "$INDEX_DIR/keywords.json"
    echo "      \"id\": \"$SESSION_ID\"," >> "$INDEX_DIR/keywords.json"
    echo "      \"file\": \"$file\"," >> "$INDEX_DIR/keywords.json"
    echo "      \"content\": $(echo "$CONTENT" | jq -Rs .)" >> "$INDEX_DIR/keywords.json"
    echo -n "    }" >> "$INDEX_DIR/keywords.json"
done

echo "" >> "$INDEX_DIR/keywords.json"
echo "  ]" >> "$INDEX_DIR/keywords.json"
echo "}" >> "$INDEX_DIR/keywords.json"

# Build metadata.json
echo "{" > "$INDEX_DIR/metadata.json"
echo "  \"built\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"," >> "$INDEX_DIR/metadata.json"
echo "  \"sessionCount\": $SESSION_COUNT" >> "$INDEX_DIR/metadata.json"
echo "}" >> "$INDEX_DIR/metadata.json"

# Build simple text index for quick grep
find "$SESSIONS_DIR" -name "S-*.md" | sort | while read -r file; do
    SESSION_ID=$(basename "$file" .md)
    echo "=== $SESSION_ID ===" >> "$INDEX_DIR/sessions.txt"
    cat "$file" >> "$INDEX_DIR/sessions.txt"
    echo "" >> "$INDEX_DIR/sessions.txt"
done

echo "✓ Index built successfully!"
echo "  - keywords.json: Session content indexed"
echo "  - metadata.json: Build metadata"
echo "  - sessions.txt: Plaintext search index"
