# ADR-0006: Strategic Insights Engine

Status: Accepted
Date: 2026-03-07
Session: S-2026-03-07-sprint1-insights-engine

## Context

The Signal Engine (v1) detects individual signals across 7 categories (funding, startup, launch, etc.). But CEOs need higher-order patterns: "Healthcare voice AI is accelerating" backed by multiple correlated signals. Master spec S12 describes this as Strategic Insight Generation.

## Decision

Build `voiceos/services/insight_engine.py` with 5 insight types, derived from signals (not raw evidence):

| Type | Trigger | Example |
|------|---------|---------|
| `market_acceleration` | 3+ signals in same category | "Voice AI funding accelerating — 4 rounds in 30 days" |
| `competitor_cluster` | 3+ entities across multiple signals | "Emerging cluster: OpenAI, ElevenLabs, Deepgram" |
| `tech_shift` | Funding + launch signals in same domain | "Healthcare voice — funded AND shipping" |
| `regulatory_risk` | High-confidence regulatory signals | "EU AI Act compliance deadline approaching" |
| `opportunity_gap` | Evidence exists but few signals detected | "IoT voice: evidence present but underexplored" |

Pipeline: `evidence → signals → insights` — each layer builds on the previous.

## Consequences

### Positive
- Transforms noise into actionable CEO-grade intelligence
- 5 types cover the most strategic patterns without over-engineering
- Threshold-based detection is simple, tunable, and explainable
- Clean layered architecture: insights never bypass signals

### Negative
- Threshold tuning may need iteration (currently hardcoded)
- No temporal analysis yet — can't distinguish acceleration from steady state
- Pattern detection is rule-based, not ML

### Neutral
- 12 tests provide good coverage of all insight types
- Computed on-demand (no caching) — acceptable for current scale

## Evidence

- 12 tests passing across all 5 insight types + edge cases
- Signal-first approach prevents duplicate logic between signal detection and insight generation

## Links

Sessions:
- S-2026-03-07-sprint1-insights-engine

Commits:
- `64fbccc` feat: Sprint 1 — Investigation Service + Insights Engine + Intelligence Graph
