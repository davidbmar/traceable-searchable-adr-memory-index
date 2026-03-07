# ADR-0005: Investigation Service (RAG + Citations)

Status: Accepted
Date: 2026-03-07
Session: S-2026-03-07-sprint1-investigation-service

## Context

The Investigation Feed UI existed as a placeholder — a text input that did nothing. Founders need to ask questions like "Any new competitors?" and get grounded, cited answers from collected evidence. This is the #1 missing product feature (master spec S16, S17).

## Decision

Build a single `POST /api/mission/investigate` endpoint that:

1. **Ranked text search**: Score evidence by word-hit count (not strict AND/OR), return top 8
2. **LLM-grounded answer**: Send matched evidence to Claude Haiku with citation prompt
3. **Citation format**: `[evidence:N]` notation in LLM output, parsed into clickable UI chips
4. **Graceful fallback**: Bullet-point summary if LLM call fails

No separate `investigation_service.py` — logic is inline in server.py (~99 lines) since it's primarily an orchestration endpoint, not a reusable service.

## Consequences

### Positive
- Founders can interrogate their evidence in natural language
- Citations provide trust and traceability
- Fallback ensures the feature never completely breaks
- Fast: Claude Haiku keeps response time under 3s

### Negative
- Text search is keyword-based, not semantic — may miss relevant evidence with different phrasing
- No conversation memory — each question is independent
- LLM cost per question (~$0.001 with Haiku)

### Neutral
- Top-8 evidence limit balances quality vs context window
- Investigation results are ephemeral (in-memory, not persisted)

## Evidence

- 5 tests passing covering error handling, search matching, citation validation, and LLM fallback
- Ranked search outperforms strict AND for natural language questions (AND too restrictive, OR too noisy)

## Links

Sessions:
- S-2026-03-07-sprint1-investigation-service

Commits:
- `64fbccc` feat: Sprint 1 — Investigation Service + Insights Engine + Intelligence Graph
