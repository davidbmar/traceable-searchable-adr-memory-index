# Traceable Project Memory

A system for making every coding session, commit, and decision searchable and explainable with citations.

## Quick Start

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

## Important

**Read CLAUDE.md** - This file tells AI assistants (Claude, Copilot, etc) how to use the Project Memory system correctly. Update it when you change conventions.

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
