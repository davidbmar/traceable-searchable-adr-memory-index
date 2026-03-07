# Session

Session-ID: S-2026-03-07-sprint1-intelligence-graph
Title: Workstream C — Intelligence Graph v1
Date: 2026-03-07
Author: Claude (parallel subagent)

## Goal

Build a graph of entity relationships from extracted entities and events, enabling queries like "show me all companies in healthcare voice AI" and visual relationship exploration.

## Context

Structured Intelligence v0 extracts entities, events, and claims. But they exist as flat lists — no relationships between them. ADR-0004 identified Intelligence Graph as Workstream C, depending only on Structured Intelligence (done).

## Plan

1. Build `graph_service.py` with `build_graph()` function
2. Infer edges from events (funded_by, partnered_with, competes_with, builds)
3. Detect co-occurrence edges from shared evidence refs
4. Infer sector edges (operates_in) from keyword matching
5. Cluster detection for connected components
6. Add `GET /api/mission/graph` endpoint
7. Create GraphCard relationship explorer UI

## Changes Made

### Backend
- **voiceos/services/graph_service.py**: New 290-line module
  - **Event-based edges**: Maps event types to relationship types
    - funding → `funded_by`
    - partnership → `partnered_with`
    - acquisition → `acquired_by`
    - launch → `builds`
  - **Co-occurrence edges**: Entities sharing `evidence_refs` get `related_to` edges (confidence 0.4)
  - **Sector inference**: Matches entity names against sector keywords (voice AI, healthcare, finance, etc.), creates `operates_in` edges to dynamically-added sector nodes
  - **Edge deduplication**: Merges by (source, target, relation), keeps highest confidence, unions evidence refs
  - **Cluster detection**: Connected components sharing 2+ edges
  - Returns `{nodes: GraphNode[], edges: GraphEdge[], clusters: GraphCluster[]}`
- **server.py**: Added `GET /api/mission/graph` endpoint (19 lines)

### Frontend
- **GraphCard.tsx**: "Relationship Explorer" in left panel
  - Shows top entities by connection count
  - Click to expand: shows edges with color-coded relation badges
  - Counterpart name, evidence ref count, confidence dot
- **types.ts**: Added `GraphNode`, `GraphEdge`, `GraphCluster`, `GraphResponse`
- **api.ts/apiClient.ts**: Added `fetchGraph()` with mock fixture
- **store.ts**: Added `graphData` state, loaded in `loadDashboard()`
- **fixtures/graph.sample.json**: Mock data for development

### Tests
- **tests/test_graph_service.py**: 13 tests across 6 test classes
  - Event-based edge inference (funding, partnership)
  - Co-occurrence edges
  - Sector inference
  - Cluster detection
  - Connection counts and sorting
  - Empty input handling

## Decisions Made

- **Event-type → edge-type mapping**: Simple, deterministic, auditable. Each event type maps to exactly one relationship type.
- **Co-occurrence confidence 0.4**: Lower than event-derived edges (0.6-0.9) since co-occurrence is weaker signal
- **Dynamic sector nodes**: Sectors like "voice AI" are created on-the-fly when entities match keywords, not predefined
- **No persistent graph storage**: Graph is computed on-demand from entities/events. Keeps it always fresh, avoids sync issues.

## Open Questions

- Graph persistence/caching for large entity sets
- Interactive graph visualization (force-directed layout)
- Entity resolution: merging "OpenAI" and "Open AI" into one node
- Weighted graph queries: "strongest path between entity A and B"

## Links

Commits:
- `64fbccc` feat: Sprint 1 — Investigation Service + Insights Engine + Intelligence Graph

ADRs:
- ADR-0007 - Intelligence Graph Architecture
- ADR-0004 - Master Spec Workstream Breakdown (parent)
