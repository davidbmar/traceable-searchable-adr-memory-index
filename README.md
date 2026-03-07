# Traceable Project Memory System

A **git-based documentation system** that makes every coding session, commit, and decision traceable and searchable. Perfect for AI-assisted development and team collaboration.

## 🎯 What Is This?

This is a **TEMPLATE REPOSITORY** for implementing traceable project memory in your codebase. Every coding session gets:
- ✅ A unique Session ID
- ✅ Structured documentation
- ✅ Searchable commit history
- ✅ Decision records (ADRs)
- ✅ Auto-generated searchable index

**You don't work in this repo directly** - you copy it into your actual projects.

---

## ⚡ Quick Start (For This Template Repo)

### 1. Clone This Repo

```bash
git clone https://github.com/your-username/traceable-project-memory.git
cd traceable-project-memory
```

### 2. Install Git Hooks

```bash
./scripts/setup-hooks.sh
```

✅ Done! The pre-commit hook will auto-rebuild the session index on every commit.

### 3. Test It Works

```bash
# Run the test suite
./scripts/test.sh

# Manually build the index
./scripts/build-index.sh
```

---

## 🚀 Integrating Into Your Project

Want to use this system in **your existing project**? Here's how:

### Step 1: Copy Files

From this repo, copy into your project:

```bash
# Required: Core documentation structure
cp -r docs/project-memory/ YOUR_PROJECT/docs/

# Required: Build scripts
cp -r scripts/ YOUR_PROJECT/scripts/

# Optional but recommended: PR template
cp -r .github/ YOUR_PROJECT/.github/
```

### Step 2: Install Hooks

```bash
cd YOUR_PROJECT
./scripts/setup-hooks.sh
```

This installs a pre-commit hook that:
- ✅ Rebuilds the session index automatically
- ✅ Auto-stages updated index files
- ✅ Runs tests (if you have them)

### Step 3: Merge CLAUDE.md Instructions

Copy sections from this repo's `CLAUDE.md` into your project's `CLAUDE.md`:

**Required sections:**
- Session ID Format
- Commit Message Format
- Session Documentation
- Searching Project Memory
- Semantic Search

**Customize to your needs:**
- Adapt the workflow to your team's process
- Add project-specific documentation requirements
- Keep the core Session ID and traceability requirements

### Step 4: Verify

```bash
# Test the build script
./scripts/build-index.sh

# Create a test session (HHMM is UTC)
cp docs/project-memory/sessions/_template.md \
   docs/project-memory/sessions/S-$(date -u +%Y-%m-%d-%H%M)-test.md

# Commit (should auto-rebuild index)
git add docs/project-memory/sessions/S-*-test.md
git commit -m "Test session tracking

Session: S-$(date -u +%Y-%m-%d-%H%M)-test"
```

---

## Multi-Agent Sprint Orchestration

Parallelize development across multiple Claude Code agents, each working in its own git worktree. Proven system architecture — just configure for your project.

### How It Works

1. **Write a sprint brief** — define agents and their tasks in `SPRINT_BRIEF.md`
2. **Initialize** — `./scripts/sprint-init.sh` creates worktrees + per-agent briefs
3. **Launch** — `./scripts/sprint-tmux.sh` opens tmux with one tab per agent
4. **Agents work autonomously** — implement, test, commit
5. **Merge** — `./scripts/sprint-merge.sh` merges branches in order with verification

### Setup

**1. Configure** — Edit `scripts/sprint-config.sh`:

| Variable | Default | Purpose |
|----------|---------|---------|
| `PROJECT_SLUG` | repo directory name | Names the worktree sibling directory |
| `DEFAULT_TEST_CMD` | safe no-op echo | Test command run by agents and during merge |
| `GENERATE_SPRINT_REPORT` | `false` | Opt-in post-merge report generation |
| `EPHEMERAL_FILES` | `AGENT_BRIEF.md`, `.claude-output.txt`, index files | Auto-resolved during merge conflicts |

**2. Write a sprint brief** — Use the template and spec:
- Template: `docs/project-memory/tools/SPRINT_BRIEF_TEMPLATE.md`
- Full spec: `docs/project-memory/tools/SPRINT_BRIEF_SPEC.md`

**3. Run the sprint:**

```bash
# Create worktrees
./scripts/sprint-init.sh

# Launch all agents in tmux
./scripts/sprint-tmux.sh

# After agents finish, merge into main
./scripts/sprint-merge.sh
```

### Requirements

- `tmux` (for parallel agent tabs)
- `claude` CLI (Claude Code)
- `bash` (standard)

---

## 📖 How It Works

### Session ID Format

Every coding session gets a unique ID:

```
S-YYYY-MM-DD-HHMM-<slug>
```

**HHMM is UTC** — always use `date -u +%Y-%m-%d-%H%M` to generate the timestamp.

Example: `S-2026-02-09-1530-add-auth`

### Commit Messages

Write a human-readable subject line. Put the Session ID in the commit body:

```bash
git commit -m "Implement JWT authentication

Session: S-2026-02-09-1530-add-auth"
```

### Session Documentation

Each session has a markdown document:

```
docs/project-memory/sessions/S-2026-02-09-1530-add-auth.md
```

Contains:
- **Title:** Short human-readable name for the session
- **Goal:** What you're trying to achieve
- **Context:** Why this work is needed
- **Plan:** How you'll do it
- **Changes Made:** What actually changed
- **Decisions Made:** Significant choices and rationale
- **Links:** Related commits, PRs, ADRs

### Auto-Index

The pre-commit hook automatically builds a searchable index:

```
docs/project-memory/.index/
├── keywords.json      # Inverted keyword → session ID index (for search)
├── metadata.json      # Per-session metadata (title, date, author, goal, keywords)
├── sessions.txt       # Plain text for grep
└── last-updated.txt   # Build timestamp
```

### Searching

**Find sessions by keyword:**
```bash
grep -r "authentication" docs/project-memory/sessions/
```

**Find commits for a session:**
```bash
git log --all --grep="S-2026-02-09-1530-add-auth"
```

**Find sessions by date:**
```bash
ls docs/project-memory/sessions/S-2026-02-09*
```

**Semantic search (AI-powered):**
```bash
# Use Claude/AI to search by concept, not just keywords
# See CLAUDE.md for instructions
```

---

## 💻 System Requirements

### Portability

This system works **everywhere** with minimal dependencies:

✅ **macOS, Linux, Unix, WSL**
✅ **SSH into remote servers**
✅ **No Node.js required**
✅ **No Python required**
✅ **No cloud dependencies**

### Dependencies

You need:
- `bash` (standard on all Unix systems)
- `jq` (JSON processor)

**Install jq:**
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq

# Alpine
apk add jq
```

---

## 🗂️ Repository Structure

```
.
├── docs/
│   └── project-memory/
│       ├── .index/              # Auto-generated search index (keywords, metadata, plaintext)
│       ├── adr/                 # Architecture Decision Records
│       ├── sessions/            # Session documentation
│       │   ├── _template.md     # Template for new sessions
│       │   └── S-*.md           # Session files
│       ├── architecture/        # Architecture docs
│       ├── runbooks/            # Operational guides
│       └── index.md             # Overview
├── scripts/
│   ├── build-index.sh           # Build search index (bash)
│   ├── setup-hooks.sh           # Install git hooks
│   └── test.sh                  # Run test suite
├── tests/
│   └── test-index-builder.sh    # Index builder tests
├── CLAUDE.md                    # AI assistant instructions
└── README.md                    # This file
```

---

## 🧪 Testing

Run the test suite:

```bash
./scripts/test.sh
```

Tests verify:
- ✅ Index builds correctly from sessions
- ✅ JSON output is valid
- ✅ Per-session field extraction (title, date, author, goal)
- ✅ Keyword extraction with stop-word filtering
- ✅ Inverted keyword index (shared keywords map to multiple sessions)
- ✅ Special characters handled
- ✅ Sessions sorted properly
- ✅ Empty directories handled gracefully
- ✅ Build timestamp (last-updated.txt)
- ✅ Title extraction and backward compatibility

**53 tests total** across 13 test suites - all must pass before committing changes to the system.

---

## 🔍 Example Workflow

### Starting Work

```bash
# 1. Create Session ID (HHMM is UTC)
SESSION_ID="S-$(date -u +%Y-%m-%d-%H%M)-add-login"

# 2. Create session doc
cp docs/project-memory/sessions/_template.md \
   docs/project-memory/sessions/$SESSION_ID.md

# 3. Edit session doc: fill in Title, Goal, Context, Plan
vim docs/project-memory/sessions/$SESSION_ID.md
```

### Making Changes

```bash
# 4. Write code
vim src/auth/login.js

# 5. Commit with human-readable subject, Session ID in body
git add src/auth/login.js
git commit -m "Implement login endpoint

Session: $SESSION_ID"

# Pre-commit hook auto-rebuilds index ✨
```

### Finishing Up

```bash
# 6. Update session doc with Changes Made
vim docs/project-memory/sessions/$SESSION_ID.md

# 7. Commit session doc
git add docs/project-memory/sessions/$SESSION_ID.md
git commit -m "Document login implementation

Session: $SESSION_ID"

# 8. Create PR (reference Session ID)
gh pr create --title "Add login endpoint" \
  --body "Session: $SESSION_ID

  See docs/project-memory/sessions/$SESSION_ID.md"
```

---

## 📋 When to Create an ADR

Create an Architecture Decision Record (ADR) when:

- Making significant architectural decisions
- Choosing between technical approaches
- Establishing patterns that will be followed
- Making decisions with long-term consequences

Example:
```bash
cp docs/project-memory/adr/_template.md \
   docs/project-memory/adr/0042-use-jwt-for-auth.md
```

---

## 🤖 AI-Assisted Development

This system is designed for **AI pair programming**. The `CLAUDE.md` file contains:

- **Session ID enforcement** - AI creates Session IDs automatically
- **Semantic search** - AI understands concepts, not just keywords
- **Context retrieval** - AI can find related work from past sessions
- **Documentation prompts** - AI documents decisions as they're made

**Works with:**
- Claude Code (CLI)
- Claude.ai (Web)
- Any AI assistant (adapt CLAUDE.md)

---

## 🎓 Why Use This System?

### Problem

In typical projects:
- ❌ Code changes lack context
- ❌ Decisions are forgotten
- ❌ Past work is hard to find
- ❌ AI assistants start from scratch every session
- ❌ Onboarding takes weeks

### Solution

With traceable project memory:
- ✅ Every change is documented
- ✅ Decisions are searchable
- ✅ Context is preserved
- ✅ AI assistants leverage past work
- ✅ Onboarding takes hours

### Benefits

**For Solo Developers:**
- Remember why you made decisions
- Pick up where you left off
- Search your past work instantly

**For Teams:**
- Shared context across developers
- Consistent documentation
- Faster code review
- Better onboarding

**For AI Pair Programming:**
- AI learns from past sessions
- Better suggestions based on context
- Consistent patterns
- Reduced hallucinations

---

## 🙋 FAQ

### Q: Is this overkill for small projects?

**A:** Start simple. Even just Session IDs in commits helps. Add more structure as you grow.

### Q: What if I forget to document a session?

**A:** The pre-commit hook will still build the index. Document when you can, but don't let it block work.

### Q: Can I use this without AI?

**A:** Absolutely! The system works great for manual documentation and searching.

### Q: Do I need to use the exact Session ID format?

**A:** The format is recommended but adapt to your needs. Keep it consistent and greppable.

### Q: What about private/proprietary projects?

**A:** This system is entirely local. No cloud, no external dependencies. Your docs stay in your git repo.

### Q: Does the pre-commit hook slow down commits?

**A:** Index building adds ~1 second. Tests (if enabled) take longer but can be skipped with `--no-verify` in emergencies.

---

## 📂 Template vs Project Repos

| Repo Type | Purpose | Examples |
|-----------|---------|----------|
| **Template** (this one) | Reference docs, examples, templates | traceable-project-memory |
| **Project** (your code) | Actual work with Project Memory integrated | your-api, your-frontend, your-app |

**You work in your project repos, not this template.**

---

## 📝 License

MIT License - feel free to use this in any project (personal or commercial).

---

## 🤝 Contributing

This is a template repo. Fork it, adapt it, make it yours!

**Improvements welcome:**
- Open issues for bugs or suggestions
- Submit PRs for enhancements
- Share your adaptations

---

## 📚 Learn More

- **Full documentation:** `docs/project-memory/index.md`
- **AI instructions:** `CLAUDE.md`
- **ADR template:** `docs/project-memory/adr/_template.md`
- **Session template:** `docs/project-memory/sessions/_template.md`

---

**Built for developers who want to work faster, remember better, and leverage AI effectively.**

⭐ Star this repo if you find it useful!
