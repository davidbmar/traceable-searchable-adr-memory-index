# ADR-0004: Master Spec Workstream Breakdown

Date: 2026-03-06
Status: Proposed
Session: S-2026-03-06-2300-signal-categories-v1

## Context

The master spec (`docs/plans/master.md`) is a 20-section product spec for ResearchOps — a strategic intelligence system for founders/CEOs. We need to break it into parallelizable workstreams with clear dependencies, each tracked as a session + ADR.

## Status Audit (What's Built vs What Remains)

### DONE (shipped on main)
| Spec Section | Status | Notes |
|---|---|---|
| S1. Vision | DONE | Product direction established |
| S4. Core UX: 3-panel layout | DONE | DashboardView.tsx, 3-column layout |
| S4. Morning Brief pattern | DONE | MorningBriefCard + brief history nav |
| S4. Evidence Drawer | DONE | EvidenceDrawer with search, category filter, source type |
| S6.1 Mission data model | DONE | ResearchProject in research_project.py |
| S6.2-6.4 Pass/Query/Evidence | DONE | pass_log.json, evidence.json, queries |
| S7. Research Engine | DONE | Multi-pass runner, SerpAPI, extraction, dedupe |
| S8. Structured Intelligence (v0) | DONE | Entities/Events/Claims extraction |
| S9. Signal Engine (v1) | DONE | 7 categories: funding/startup/launch/partnership/adoption/talent/regulatory |
| S13. Daily CEO Brief | DONE | Brief generation + display + history |
| S14. Mission Templates | DONE | Template picker, 5 built-in templates |
| S16. APIs (core) | DONE | /mission/status, /brief, /evidence, /signals, /run, /briefs, /brief/{date} |
| S17. UI: Header | DONE | Title, status, Run Now, Pause (placeholder), Call |
| S17. UI: Radar | DONE | 7-category Radar with counts + signal cards |
| S17. UI: Run Health + Timeline | DONE | RunHealthCard, RunTimeline, PassLog |
| S17. UI: Mission Control | DONE | MissionControlCard with passes/evidence/schedule |
| S20. Acceptance: golden path | DONE | Create mission -> run -> see brief -> click evidence |

### NOT YET BUILT
| Spec Section | Priority | Complexity |
|---|---|---|
| S6.5-6.7 Entities/Events/Claims (full model) | Medium | Medium — v0 exists, needs canonical keys + graph edges |
| S6.8 SignalEvent (structured) | Medium | Low — currently regex-based, spec wants event-driven |
| S6.9 Insight | High | High — pattern detection across signals |
| S6.10 DailyBrief (full schema) | Medium | Low — current brief is close, needs voice_script + suggested_actions |
| S7.2-7.4 Top-down/bottom-up blend | Medium | Medium — current engine does this partially |
| S10. Intelligence Graph | High | High — entity relationships, graph queries |
| S11. Autonomous Research Brain | High | High — next-pass planning, validation queries |
| S12. Strategic Insight Generation | High | High — pattern detection, trend analysis |
| S15. Quality/Anti-Hallucination | Medium | Medium — confidence scoring, contradiction detection |
| S16. APIs: /investigate | High | Medium — RAG retrieval + grounded answers |
| S17. UI: Chat with citations | High | Medium — Investigation Feed needs backend |
| S4. Voice integration | Low | Medium — voice callbacks exist but not wired |

## Decision: Seven Workstreams

Break remaining work into 7 workstreams (A-G), ordered by value and dependency:

### Workstream A: Investigation Service (RAG + Citations)
**Why first:** The Investigation Feed (chat box) is already in the UI but does nothing. This is the #1 missing "product" feature — founders want to ask "Any new competitors?" and get a cited answer.

**Scope:**
- POST /mission/investigate endpoint
- Evidence retrieval (text search + optional embeddings)
- LLM-grounded answer with inline [evidence:id] citations
- Wire Investigation Feed in DashboardView to call the endpoint
- Render citations as clickable chips that open Evidence Drawer

**Files:** server.py, new investigation_service.py, DashboardView.tsx
**ADR:** 0005-investigation-service
**Depends on:** Nothing (uses existing evidence store)

### Workstream B: Strategic Insights Engine
**Why second:** Transforms raw signals into CEO-grade insights ("Healthcare voice automation accelerating" backed by 3 funding + 2 adoption signals).

**Scope:**
- Insight types: market_trend, cluster, tech_shift, regulatory_risk, opportunity_gap
- Pattern detection: cross-signal analysis (multiple funding signals in same sector = trend)
- InsightCard UI component in the Morning Brief
- /mission/insights endpoint

**Files:** new insight_engine.py, MorningBriefCard.tsx, server.py
**ADR:** 0006-strategic-insights
**Depends on:** Signal Engine (done)

### Workstream C: Intelligence Graph (v1)
**Why third:** Enables "show me all companies in healthcare voice AI" and relationship-based queries.

**Scope:**
- Graph edges: company -> operates_in -> market, competes_with, builds, raised, partnered_with
- Build graph from existing entities + events
- /mission/graph endpoint (nodes + edges)
- EntityMapCard upgrade: clickable relationship view

**Files:** new graph_service.py, EntityMapCard.tsx, server.py
**ADR:** 0007-intelligence-graph
**Depends on:** Structured Intelligence (done)

### Workstream D: Autonomous Research Brain
**Why fourth:** Makes research passes smarter over time — coverage-aware query planning, validation queries, deep-dives on high-signal entities.

**Scope:**
- Pass intent system: exploration, validation, deep_dive, synthesis
- Coverage map tracking (dimensions explored vs gaps)
- Next-pass query planner using coverage + signals + contradictions
- Top-down/bottom-up blend ratio (70/30 -> 50/50 as passes increase)

**Files:** research_brain.py, research_collector.py modifications
**ADR:** 0008-autonomous-research-brain
**Depends on:** Intelligence Graph (for entity-aware queries)

### Workstream E: Enhanced Daily Brief
**Why fifth:** Upgrades brief to full spec format with voice script, suggested actions, and what-changed diff.

**Scope:**
- Voice script generation (60s summary)
- Suggested actions (buttons -> chat commands)
- What-changed diff (new signals since last brief)
- Strategic implications section
- Evidence highlights (most important citations)

**Files:** research_briefing.py, MorningBriefCard.tsx
**ADR:** 0009-enhanced-daily-brief
**Depends on:** Insights Engine (for strategic implications)

### Workstream F: Quality & Anti-Hallucination
**Why sixth:** Trust layer — contradiction detection, multi-source confirmation, source credibility scoring.

**Scope:**
- Contradiction detection between evidence items
- Multi-source confirmation scoring
- Source credibility ranking (reuters > random blog)
- Confidence recalculation: structured_conf formula from spec
- UI: uncertainty indicators on low-confidence claims

**Files:** quality_service.py, signal_detector.py, EvidenceDrawer.tsx
**ADR:** 0010-quality-anti-hallucination
**Depends on:** Investigation Service (for grounded answers)

### Workstream G: Voice Integration
**Why last:** Voice is the premium interface but the visual product must work first.

**Scope:**
- "Give me today's brief" -> voice playback of brief voice_script
- "Any new startups?" -> voice answer from Investigation Service
- Voice status integration in DashboardHeader

**Files:** voice integration layer, DashboardView.tsx
**ADR:** 0011-voice-integration
**Depends on:** Investigation Service + Enhanced Brief (for voice script)

## Parallelization Map

```
                    ┌─── A: Investigation ───┐
                    │                        │
        (existing)──┤                        ├─── F: Quality
                    │                        │
                    ├─── B: Insights ─────────┼─── E: Enhanced Brief ─── G: Voice
                    │                        │
                    └─── C: Graph ────────────┘
                              │
                              └─── D: Research Brain
```

**Can run in parallel:**
- A (Investigation) + B (Insights) + C (Graph) — no dependencies between them
- E (Enhanced Brief) after B completes
- D (Research Brain) after C completes
- F (Quality) after A completes
- G (Voice) after A + E complete

## Execution Recommendation

**Sprint 1 (parallel):** A + B + C (3 subagents)
**Sprint 2 (parallel):** D + E + F (3 subagents, after Sprint 1)
**Sprint 3:** G (voice, after Sprint 2)

Each workstream gets its own:
- Session doc in `docs/project-memory/sessions/`
- ADR in `docs/project-memory/adr/`
- Git branch
- Test suite

## Consequences

- 7 workstreams with clear boundaries enables parallel subagent execution
- Each workstream is 1-2 day scope for a focused agent
- Dependencies are explicit — no circular deps
- ADRs provide decision trail for each architectural choice
- Session docs track what actually happened vs plan
