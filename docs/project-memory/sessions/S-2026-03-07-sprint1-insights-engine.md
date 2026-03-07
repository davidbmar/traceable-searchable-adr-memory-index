# Session

Session-ID: S-2026-03-07-sprint1-insights-engine
Title: Workstream B — Strategic Insights Engine
Date: 2026-03-07
Author: Claude (parallel subagent)

## Goal

Transform raw signals into CEO-grade strategic insights: "Healthcare voice automation accelerating" backed by 3 funding + 2 adoption signals.

## Context

The Signal Engine (v1) detects individual signals across 7 categories. But founders need cross-signal pattern detection — clusters, trends, and strategic implications. ADR-0004 identified this as Workstream B, depending only on Signal Engine (done).

## Plan

1. Build `insight_engine.py` with pattern detection across signals
2. Detect 5 insight types: market_acceleration, competitor_cluster, tech_shift, regulatory_risk, opportunity_gap
3. Add `GET /api/mission/insights` endpoint
4. Create InsightsCard UI component
5. Wire into dashboard loadDashboard flow

## Changes Made

### Backend
- **voiceos/services/insight_engine.py**: New 280-line module
  - `detect_insights(signals, evidence)` — main entry point
  - Market acceleration: 3+ signals in same category within timeframe
  - Competitor cluster: 3+ entities appearing across multiple signals
  - Tech shift: funding + launch signals in same tech domain
  - Regulatory risk: regulatory signals with high confidence
  - Opportunity gap: categories with evidence but low signal count
  - Each insight gets: id, type, title, description, supporting_signal_ids, confidence, detected_at
- **server.py**: Added `GET /api/mission/insights` endpoint (26 lines)
  - Reuses cached signals when evidence count matches
  - Falls back to fresh signal detection

### Frontend
- **InsightsCard.tsx**: New component in right panel
  - Type-specific color coding (green/purple/blue/red/amber)
  - Expandable cards showing description on click
  - "No insights yet" empty state
- **types.ts**: Added `Insight`, `InsightsResponse` interfaces
- **api.ts/apiClient.ts**: Added `fetchInsights()` with mock fallback
- **store.ts**: Added `insightsData` state, loaded in `loadDashboard()`

### Tests
- **tests/test_insight_engine.py**: 12 tests covering all 5 insight types, edge cases, empty inputs, confidence scoring

## Decisions Made

- **5 insight types**: Covers the most actionable strategic patterns for founders without over-engineering
- **Signal-first approach**: Insights are derived from signals (not raw evidence), keeping the pipeline clean: evidence → signals → insights
- **Threshold-based detection**: e.g., 3+ signals for market_acceleration — simple, tunable, explainable

## Open Questions

- Temporal analysis: how to detect acceleration vs steady state
- Should insights trigger notifications?
- Cross-mission insight comparison

## Links

Commits:
- `64fbccc` feat: Sprint 1 — Investigation Service + Insights Engine + Intelligence Graph

ADRs:
- ADR-0006 - Strategic Insights Engine Architecture
- ADR-0004 - Master Spec Workstream Breakdown (parent)
