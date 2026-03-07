# Session

Session-ID: S-2026-03-07-sprint1-investigation-service
Title: Workstream A — Investigation Service (RAG + Citations)
Date: 2026-03-07
Author: Claude (parallel subagent)

## Goal

Build the Investigation Feed — let founders ask "Any new competitors?" and get an LLM-grounded answer with inline evidence citations.

## Context

The Investigation Feed (chat input) existed in the UI but did nothing. This was the #1 missing "product" feature from the master spec (S16/S17). ADR-0004 identified this as Workstream A with no dependencies.

## Plan

1. Add `POST /api/mission/investigate` endpoint
2. Evidence retrieval with ranked text search (word-hit scoring)
3. LLM-grounded answer via Claude Haiku with `[evidence:N]` citations
4. Graceful fallback when LLM unavailable
5. Wire Investigation Feed UI to call the endpoint
6. Render citations as clickable chips that open Evidence Drawer

## Changes Made

### Backend
- **server.py**: Added `POST /api/mission/investigate` endpoint (99 lines)
  - Ranked evidence search: scores each evidence item by word-hit count, takes top 8
  - Builds structured prompt with evidence block for LLM
  - Calls Claude Haiku for grounded answer with `[evidence:N]` notation
  - Returns `{answer, citations}` with source URLs and claims
  - Fallback: formatted bullet-point summary if LLM fails

### Frontend
- **DashboardView.tsx**: Replaced placeholder chat with full Investigation Feed
  - Shows results with inline citation chips (gold numbered badges)
  - Loading spinner during investigation
  - Input disabled while investigating
  - `InvestigationResultCard` component renders answer with clickable citations
- **types.ts**: Added `InvestigateResponse`, `InvestigationResult` interfaces
- **api.ts**: Added `investigate()` function
- **apiClient.ts**: Added mock/live wrapper with realistic mock response
- **store.ts**: Added `investigationResults`, `investigating` state + `investigate()` action

### Tests
- **tests/test_investigation.py**: 5 tests covering empty question, missing question, matching evidence, valid citation indices, fallback without LLM

## Decisions Made

- **Ranked search over AND logic**: Investigation uses word-hit scoring (more hits = higher rank) rather than strict AND matching. This ensures relevant results even with casual questions.
- **Top 8 evidence limit**: Balances context window usage with answer quality.
- **Claude Haiku model**: Fast + cheap for real-time Q&A, adequate for evidence summarization.
- **Inline citations**: `[evidence:N]` pattern in LLM output parsed into clickable UI chips.

## Open Questions

- Embedding-based retrieval could improve relevance for semantic queries
- Should investigation history persist across sessions?
- Rate limiting for LLM calls

## Links

Commits:
- `64fbccc` feat: Sprint 1 — Investigation Service + Insights Engine + Intelligence Graph

ADRs:
- ADR-0005 - Investigation Service Architecture
- ADR-0004 - Master Spec Workstream Breakdown (parent)
