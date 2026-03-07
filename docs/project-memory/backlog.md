# ResearchOps Backlog

Last updated: 2026-03-07 (Sprint 1 Review)

## How This Works

After each sprint, the post-sprint review (ADR-0008) identifies gaps between what shipped and what the business requirements demand. Issues are added here with severity, linked to spec sections, and triaged into either hotfixes or future sprint scope.

**Severity levels:**
- **CRITICAL** — Breaks user trust or makes a feature feel broken. Must fix before next sprint.
- **IMPORTANT** — Feature works but quality is low. Feed into next sprint scope.
- **MINOR** — Polish items. Address when touching related code.

---

## Active Backlog

### CRITICAL

#### BL-001: Brief never auto-regenerates
- **Found:** Sprint 1 Review
- **Spec:** S6.10 (DailyBrief full schema), S13 (Daily CEO Brief)
- **Problem:** 17 research passes ran but only 1 brief exists (2026-03-06). Founders open the dashboard daily and see the same brief. Product feels stale/broken.
- **Fix:** Auto-generate brief after every N passes (e.g., 3) or on a daily schedule. The scheduler infrastructure exists (`voiceos/services/scheduler.py`), just needs a trigger rule.
- **Planned:** Workstream E (Enhanced Daily Brief) or hotfix before Sprint 2
- **Status:** OPEN

#### BL-002: Event Timeline dates default to "Jan 1"
- **Found:** Sprint 1 Review
- **Spec:** S8 (Structured Intelligence)
- **Problem:** 6 of 10 extracted events have `None` dates. UI renders these as "Jan 1" which misleads users into thinking data is old.
- **Fix (UI):** Show "Date unknown" or "~2024" for null/year-only dates in `EventTimelineCard.tsx`
- **Fix (Backend):** Update LLM extraction prompt in `research_collector.py` to enforce ISO date extraction with fallback to "unknown"
- **Status:** OPEN

### IMPORTANT

#### BL-003: Insight type monotony — all 57 are "market_acceleration"
- **Found:** Sprint 1 Review
- **Spec:** S12 (Strategic Insight Generation)
- **Problem:** The threshold of 3+ signals for market_acceleration is too low with 383 signals. Every entity with 3+ mentions triggers a separate insight. 57 identical-looking insights provide no value.
- **Fix:** Raise threshold to 5+ signals, add entity deduplication (group by sector not individual entity), ensure other insight types (competitor_cluster, tech_shift, etc.) have realistic triggers.
- **Files:** `voiceos/services/insight_engine.py`
- **Status:** OPEN

#### BL-004: Graph edge role confusion ("NVIDIA Builds Sequoia Capital")
- **Found:** Sprint 1 Review
- **Spec:** S10 (Intelligence Graph)
- **Problem:** In funding events, all `entities_involved` get the same edge type. A funding event with [NVIDIA, Sequoia Capital, 20VC] creates "Builds" edges from NVIDIA to Sequoia, which is incorrect. Sequoia is an investor, not something NVIDIA builds.
- **Fix:** Add entity role resolution to `graph_service.py`. For funding events: first entity = company (raised_funding), remaining = investors (invested_in). For partnership events: all entities get partnered_with. Requires updating the event extraction to include entity roles, or inferring from entity type (VC firm = investor).
- **Files:** `voiceos/services/graph_service.py`, possibly `research_collector.py` (extraction prompt)
- **Status:** OPEN

### MINOR

#### BL-005: Adoption and Talent signal categories showing 0
- **Found:** Sprint 1 Review
- **Spec:** S9 (Signal Engine v1)
- **Problem:** Radar shows Adoption: 0 and Talent: 0 despite evidence containing adoption/talent language ("15,000 agents in use", "laid off 60%"). The first-match-wins pattern may be classifying these as funding/startup/launch before adoption/talent regex gets a chance.
- **Fix:** Review CATEGORY_PATTERNS ordering in `signal_detector.py`. Consider whether adoption/talent should have higher priority for certain evidence, or add multi-category support.
- **Files:** `voiceos/services/signal_detector.py`
- **Status:** OPEN

---

## Resolved

(Items move here when fixed, with commit hash and date)

---

## Backlog by Sprint Source

| Sprint | Critical | Important | Minor | Total |
|--------|----------|-----------|-------|-------|
| Sprint 1 | 2 | 2 | 1 | 5 |
