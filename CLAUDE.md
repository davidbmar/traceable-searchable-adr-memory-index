# Claude Instructions

## Project Memory System

This repo uses a **Traceable Project Memory** system. Every coding session, commit, and decision must be documented and searchable.

---

## 🚀 Setting Up This System in a New Repo

**If you're cloning this repo as a template for your project:**

### 1. Copy the Structure

Copy these files/folders into your project:
```bash
# Copy documentation structure
cp -r docs/project-memory/ YOUR_PROJECT/docs/
cp -r scripts/ YOUR_PROJECT/scripts/

# Copy templates (optional but recommended)
cp -r .github/ YOUR_PROJECT/.github/
```

### 2. Install Git Hooks

From your project root, run:
```bash
./scripts/setup-hooks.sh
```

This installs a pre-commit hook that:
- ✅ Auto-rebuilds the session index before each commit
- ✅ Auto-stages updated index files
- ✅ Runs tests (if you have them)

### 3. Merge Instructions into Your CLAUDE.md

Copy the sections below into your existing `CLAUDE.md`:
- **You MUST Follow These Rules** (all 6 numbered sections)
- **Your Workflow**
- **Always Enforce**

Adapt them to fit your project's needs, but keep the core Session ID and documentation requirements.

### 4. Verify Setup

Test that everything works:
```bash
# Build the index manually (should work)
./scripts/build-index.sh

# Create a test session
cp docs/project-memory/sessions/_template.md \
   docs/project-memory/sessions/S-$(date +%Y-%m-%d-%H%M)-test.md

# Try to commit (hook should auto-rebuild index)
git add docs/project-memory/sessions/S-*-test.md
git commit -m "[S-$(date +%Y-%m-%d-%H%M)-test] Test session tracking"
```

### Requirements

**Portability:** This system uses only bash and standard Unix tools (grep, find, jq).
- ✅ Works on any Unix/Linux/macOS system
- ✅ No Node.js or dependencies required
- ✅ Perfect for SSH into remote servers

**What you need:**
- `bash` (standard on all systems)
- `jq` (for JSON generation - install via `brew install jq` or `apt-get install jq`)

---

### You MUST Follow These Rules

#### 1. Session ID Format

Every coding session gets a unique Session ID:
```
S-YYYY-MM-DD-HHMM-<slug>
```

Example: `S-2026-02-08-1430-mobile-audio`

#### 2. Commit Message Format

Every commit message MUST include the Session ID:
```
[S-YYYY-MM-DD-HHMM-slug] description of change
```

Example:
```
[S-2026-02-08-1430-mobile-audio] Add microphone permission check
```

#### 3. Session Documentation

When starting work:

1. **Check if a session exists** for this work:
   ```bash
   ls docs/project-memory/sessions/
   ```

2. **If no session exists, create one:**
   - Copy `docs/project-memory/sessions/_template.md`
   - Name it with the Session ID: `S-YYYY-MM-DD-HHMM-slug.md`
   - Fill in Goal, Context, Plan

3. **After making changes, update the session doc:**
   - Add what changed to "Changes Made"
   - Document decisions in "Decisions Made"
   - Link commits after you create them

#### 4. When to Create an ADR

Create an ADR in `docs/project-memory/adr/` when:
- Making significant architectural decisions
- Choosing between technical approaches
- Establishing patterns that will be followed
- Making decisions with long-term consequences

Use the ADR template: `docs/project-memory/adr/_template.md`

#### 5. Searching Project Memory

To find context for code:

**Search commits by Session ID:**
```bash
git log --all --grep="S-2026-02-08-1430-mobile-audio"
```

**Search session docs:**
```bash
grep -r "keyword" docs/project-memory/sessions/
```

**Search ADRs:**
```bash
grep -r "decision topic" docs/project-memory/adr/
```

**Find sessions by date:**
```bash
ls docs/project-memory/sessions/S-2026-02-08*
```

#### 6. Semantic Search (AI-Powered)

When users ask questions using **concepts** rather than exact keywords, you must do semantic search:

**User asks:** "Show me anything about mobile support"

**You should:**
1. Use Grep to read ALL session docs: `grep -r "" docs/project-memory/sessions/S-*.md`
2. Use Grep to read ALL ADRs: `grep -r "" docs/project-memory/adr/*.md`
3. Analyze content using your understanding to find matches
4. Match related concepts:
   - "mobile" → iPhone, responsive, viewport, touch, iOS
   - "authentication" → login, JWT, OAuth, auth, credentials
   - "performance" → optimization, speed, latency, memory
5. Return results with **explanation** of why they match

**Example:**

User: "What did we do about mobile?"

```bash
# 1. Read all sessions
grep -r "" docs/project-memory/sessions/S-*.md

# 2. Find S-2026-02-08-1430-migrate-project-memory
# 3. Notice it mentions "iPhone Chrome" and "responsive"
# 4. Return: "Found session S-2026-02-08-1430 because it discusses
#    iPhone Chrome optimizations and responsive design, which
#    relates to mobile support"
```

**Semantic search rules:**
- Always explain WHY results match (don't just keyword match)
- Find synonyms and related concepts
- Cross-reference between sessions, ADRs, and commits
- If no exact keyword matches, read files and understand semantically

### Your Workflow

1. **Start of work:** Create or identify Session ID
2. **Create session doc:** Use template, fill in Goal/Context/Plan
3. **Make changes:** Write code
4. **Commit with Session ID:** `[SessionID] description`
5. **Update session doc:** Add Changes Made, Decisions, Links
6. **Create ADR if needed:** For significant decisions
7. **Create PR:** Reference Session ID, link to session doc

### Example Workflow

```bash
# Starting work
# Session ID: S-2026-02-08-1645-auth-refactor

# Create session doc
cp docs/project-memory/sessions/_template.md \
   docs/project-memory/sessions/S-2026-02-08-1645-auth-refactor.md

# Make changes...
# Commit with Session ID
git commit -m "[S-2026-02-08-1645-auth-refactor] Extract auth logic to service"

# Update session doc with changes and link to commit
# Create ADR if you made a significant decision
# Create PR with Session ID
```

### Quick Reference

- **Session template:** `docs/project-memory/sessions/_template.md`
- **ADR template:** `docs/project-memory/adr/_template.md`
- **PR template:** `.github/PULL_REQUEST_TEMPLATE.md`
- **Overview:** `docs/project-memory/index.md`

## Always Enforce

- ✅ Every commit has `[SessionID]` prefix
- ✅ Every session has a markdown doc
- ✅ Significant decisions get ADRs
- ✅ PRs reference Session IDs
- ✅ Session docs link to commits, PRs, ADRs
