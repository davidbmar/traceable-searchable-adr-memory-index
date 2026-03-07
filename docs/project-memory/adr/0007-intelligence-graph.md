# ADR-0007: Intelligence Graph v1

Status: Accepted
Date: 2026-03-07
Session: S-2026-03-07-sprint1-intelligence-graph

## Context

Structured Intelligence v0 extracts entities, events, and claims as flat lists. But understanding "which companies compete in healthcare voice AI" requires relationships between entities. Master spec S10 describes the Intelligence Graph.

## Decision

Build `voiceos/services/graph_service.py` with `build_graph()` that infers edges from three sources:

1. **Event-based edges** (high confidence 0.6-0.9):
   - funding → `funded_by`
   - partnership → `partnered_with`
   - acquisition → `acquired_by`
   - launch/product → `builds`

2. **Co-occurrence edges** (confidence 0.4):
   - Entities sharing the same `evidence_refs` get `related_to` edges

3. **Sector inference** (confidence 0.5):
   - Match entity names against sector keywords → `operates_in` edges
   - Sectors: voice AI, healthcare, finance, education, etc.
   - Sector nodes created dynamically, not predefined

**Graph is computed on-demand**, not persisted. Always fresh, no sync issues.

## Consequences

### Positive
- Enables relationship-based queries ("who competes with X?")
- Three edge sources provide good coverage without manual curation
- Cluster detection surfaces entity groupings automatically
- No graph database needed — pure Python, no infrastructure

### Negative
- On-demand computation may be slow with 1000+ entities (currently <100ms)
- No entity resolution — "OpenAI" and "Open AI" remain separate nodes
- Co-occurrence is weak signal, may produce noisy edges
- No persistent graph means no incremental updates

### Neutral
- Edge deduplication merges confidence and evidence refs cleanly
- 13 tests across 6 test classes provide thorough coverage
- GraphCard shows top entities by connection count — simple but effective

## Evidence

- 13 tests passing covering all edge types, clusters, sorting, empty inputs
- Event-type → edge-type mapping is deterministic and auditable
- Co-occurrence confidence (0.4) empirically separates weak from strong relationships

## Links

Sessions:
- S-2026-03-07-sprint1-intelligence-graph

Commits:
- `64fbccc` feat: Sprint 1 — Investigation Service + Insights Engine + Intelligence Graph
