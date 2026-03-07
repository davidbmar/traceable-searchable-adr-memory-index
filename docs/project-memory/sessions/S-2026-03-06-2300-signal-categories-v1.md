# Session

Session-ID: S-2026-03-06-2300-signal-categories-v1
Title: Signal Categories v1 — Talent, Adoption, AND search, Brief History
Date: 2026-03-06
Author: David Mar + Claude

## Goal

Expand the CEO Radar from 5 signal categories to 7 (add Talent + Adoption), fix evidence search to use AND logic, and add historical brief navigation.

## Context

The Radar currently detects: funding, startup, launch, partnership, regulatory. Two high-value categories are missing:

1. **Talent** — Layoffs signal distress, hiring sprees signal growth, exec departures signal instability. Founders need this to assess competitor health.
2. **Adoption** — Who is actually using the technology. "Stripe using AI voice agents" is a stronger signal than "Stripe raised $X" because it proves product-market fit and real demand.

Additionally:
- Evidence search used OR logic (`any`), so "Jasper laid off 60%" returned 34 results because "60%" and "off" matched independently. Fixed to AND logic (`all`).
- Morning briefs were ephemeral in the UI — only latest shown. Added date navigation (prev/next arrows) and backend endpoints for brief history.

## Plan

### Signal Categories (ordered by priority for first-match-wins)
1. funding (existing)
2. startup (existing)
3. launch (existing)
4. partnership (existing)
5. adoption (NEW)
6. talent (NEW)
7. regulatory (existing)

### Adoption detection patterns
- deploy/deploying, adopt/adopting, using, rolled out, implemented
- Context: enterprise, customers, companies, hospitals, banks, retailers
- Examples: "Amazon deploying AI voice agents", "500 companies using Retell"

### Talent detection patterns
- Layoffs: laid off, cut X% of staff, headcount reduction, restructuring, downsizing
- Key hires: hired, appointed, named CTO/CEO, joined as
- Exec departures: resigned, stepped down, departed
- Hiring: hiring X people, opened Y roles, growing team

### Pattern ordering rationale
- Adoption after partnership: "Microsoft partners with OpenAI to deploy" = partnership (primary)
- Talent after adoption: "ElevenLabs raised $180M and hired 200" = funding (primary)
- Regulatory stays last: least common, most specific patterns

### Other fixes in this session
- Evidence search: OR -> AND logic (all words must match)
- Brief history: GET /api/mission/briefs (list dates), GET /api/mission/brief/{date}
- MorningBriefCard: prev/next date navigation with "Back to latest" chip
- First-match-wins category filter fix (from prior session, committed here)

## Changes Made

### Backend
- **`voiceos/services/signal_detector.py`** — Added `_ADOPTION_RE` and `_TALENT_RE` regexes; updated `CATEGORY_PATTERNS` order to 7 categories
- **`server.py`** — AND logic for text search; added `/api/mission/briefs` and `/api/mission/brief/{date}` endpoints
- **`voiceos/services/research_project.py`** — Added `get_report_by_date()` method

### Frontend
- **`web/research/src/components/dashboard/RadarCard.tsx`** — Added adoption and talent to `CATEGORY_META`
- **`web/research/src/types.ts`** — Extended `Signal.category` union and `SignalTotals` interface
- **`web/research/src/components/dashboard/MorningBriefCard.tsx`** — Date navigation (prev/next arrows, date counter, "Back to latest" chip)
- **`web/research/src/store.ts`** — Added `briefDates`, `briefDateIndex`, `navigateBrief()`, `goToLatestBrief()`
- **`web/research/src/api.ts`** + **`apiClient.ts`** — Added `fetchBriefDates()`, `fetchBriefByDate()`

### Tests
- **`tests/test_signal_cache_invalidation.py`** — Added AND logic tests, single-word search test (22 total)

## Decisions Made

1. **AND logic for evidence search** — Multi-word searches should require ALL words to match. This is what founders expect ("Jasper laid off 60%" = only items about Jasper's layoffs). Single-word searches unaffected (AND of 1 = OR of 1).
2. **Adoption before Talent in pattern order** — "Company deploying X" is adoption; "Company hiring for X" is talent. Adoption is a stronger market signal so it gets priority in first-match-wins.
3. **Talent is flat (no sub-categories in v0)** — Layoffs vs hires could be sub-typed later, but v0 just detects the category. Sentiment (bullish/bearish) deferred.
4. **7 categories total for v1** — funding, startup, launch, partnership, adoption, talent, regulatory. This gives founders the complete strategic picture: money, players, products, alliances, usage, people, rules.
5. **Brief history via inline navigation** — No separate history page. Prev/next arrows in the MorningBriefCard header. Keeps context tight, like reading email.

## Open Questions

- Should Adoption signals include numeric thresholds ("500 companies using X") as structured data?
- Should Talent signals carry sentiment (bullish=hiring, bearish=layoffs)?
- Market Narrative / Sentiment Shift as an 8th category — "AI voice agents replacing call centers" captures industry perception. Deferred to v2.
- Should signal categories be configurable per-mission (some founders care about regulatory, others don't)?

## Links

Commits:
- `5fe5c72` fix: use first-match-wins category filter for evidence endpoint
- (pending) feat: add Talent + Adoption signal categories, AND search, brief history

PRs:
- Branch: `mission-templates-v0`

ADRs:
- ADR-0003 — Signal category architecture v1
