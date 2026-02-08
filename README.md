# Traceable Project Memory

A system for making every coding session, commit, and decision searchable and explainable with citations.

## 🎯 What is This?

This is a **TEMPLATE REPOSITORY** for the Project Memory system. You don't work in this repo directly - you copy it into your actual projects.

**How it works:**
1. **This repo** = Template, documentation, reference implementation
2. **Your project repos** = Where you actually use the system to track work

## 🚀 Getting Started

### Step 1: Copy to Your Project

```bash
# Option 1: Manual copy
cd your-project/
cp -r /path/to/traceable-searchable-adr-memory-index/docs/project-memory docs/
cp /path/to/traceable-searchable-adr-memory-index/CLAUDE.md .
cp /path/to/traceable-searchable-adr-memory-index/.github/PULL_REQUEST_TEMPLATE.md .github/

# Option 2: Use as GitHub template (recommended)
# Click "Use this template" on GitHub
# Or clone and remove .git
git clone https://github.com/davidbmar/traceable-searchable-adr-memory-index my-new-project
cd my-new-project
rm -rf .git
git init
```

### Step 2: In Your Project

```bash
# 1. Read the docs
cat CLAUDE.md
cat docs/project-memory/index.md

# 2. Start a session
cp docs/project-memory/sessions/_template.md \
   docs/project-memory/sessions/S-2026-02-08-1430-my-feature.md

# 3. Make commits with Session IDs
git commit -m "[S-2026-02-08-1430-my-feature] Add feature X"

# 4. Update session docs with changes and decisions
```

## 📂 Template vs Project Repos

| Repo Type | Purpose | Examples |
|-----------|---------|----------|
| **Template** (this one) | Reference docs, examples, templates | traceable-searchable-adr-memory-index |
| **Project** (your code) | Actual work with Project Memory integrated | browser_question_loop, your-api, your-frontend |

**You work in your project repos, not this template.**

## 💡 Quick Start (In Your Project)

After copying the system to your project:

1. **Read CLAUDE.md** - Instructions for AI on how to use this system
2. **Read docs/project-memory/index.md** - Overview of Project Memory system
3. **Start a session** - Copy `docs/project-memory/sessions/_template.md`
4. **Make commits** - Use format: `[SessionID] description`
5. **Document decisions** - Create ADRs for significant choices

## Why This Exists

No more "why did we do this?" Looking at code months later with full context of what, why, when, and who decided it.

## Session ID Format

```
S-YYYY-MM-DD-HHMM-<slug>
```

Every commit must include the Session ID:
```
[S-2026-02-08-1430-mobile-audio] Add feature X
```

## How to Search

```bash
# Find commits by session
git log --all --grep="S-2026-02-08-1430-mobile-audio"

# Find session docs
ls docs/project-memory/sessions/S-2026-02-08*

# Search decisions
grep -r "keyword" docs/project-memory/adr/
```

## 🤖 AI Integration

**CLAUDE.md is critical!** This file tells AI assistants (Claude, Copilot, etc) how to use the Project Memory system correctly.

- Copy CLAUDE.md to your project repo
- AI will automatically enforce Session IDs in commits
- AI will create session docs and ADRs for you
- AI will search semantically through your project history

## 🔍 Example: Real Usage

See **browser_question_loop** for a real project using this system:
- Active sessions in `docs/project-memory/sessions/`
- Real ADRs tracking decisions
- Every commit has a Session ID
- Searchable history with full context

## ⚠️ Important

## Structure

```
docs/project-memory/
  index.md              # System overview
  sessions/             # Coding session logs
    _template.md
  adr/                  # Architecture Decision Records
    _template.md
  runbooks/             # Operational procedures
  architecture/         # System design docs
```

## Learn More

See `docs/project-memory/index.md` for full documentation.
