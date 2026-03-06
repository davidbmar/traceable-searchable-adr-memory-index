# ADR-0002: CEO Dashboard Architecture

Status: Accepted
Date: 2026-03-06

## Context

The FSM-generic research engine runs overnight, accumulating evidence and generating morning briefing reports as JSON files on disk. There was no way to view results without reading raw files. We needed a browser UI for the CEO to see research status, read briefings, trigger runs, and browse evidence.

Existing infrastructure:
- `ResearchProjectService` with CRUD, evidence, pass logs, report persistence
- `SchedulerService` with `run_now()` for manual triggers
- Research wizard frontend (React + Zustand + Tailwind, dark theme with gold/teal)
- Auth middleware (`require_admin_token` with Bearer scheme)

## Decision

### Backend: 4 new `/api/mission/` REST endpoints

Separate from existing `/api/research/projects/` CRUD endpoints. The mission endpoints are dashboard-focused (status summary, latest brief, paginated evidence, trigger run) while research endpoints are management-focused (create/update/delete projects).

All endpoints default to the first active project via `_get_first_active_project_id()` — avoids project selection UI for the MVP.

### Frontend: View switching in existing app

Added `activeView` to Zustand store (`'wizard' | 'dashboard'`). LeftRail buttons toggle the view. AppLayout conditionally renders DashboardView or the wizard grid. No routing library needed — single-page with view toggle.

Dashboard components:
- `DashboardView` — layout shell (top bar + two-column)
- `MorningBriefCard` — executive summary, key findings, action buttons
- `RunTimeline` — vertical timeline of collection passes
- `EvidenceDrawer` — slide-out overlay with search + pagination

### Auth: Bearer token from Vite env var

Frontend reads `VITE_ADMIN_TOKEN` from `web/research/.env` and sends it as `Authorization: Bearer` header on all dashboard API calls. The `.env` file is gitignored.

## Consequences

### Positive
- End-to-end visibility into research results without touching JSON files
- Reuses existing service layer, auth, and UI framework — minimal new code
- Dashboard loads lazily (only on first click) — no impact on wizard performance
- `Promise.allSettled` means partial data (status without brief) still renders

### Negative
- Single-project assumption — `_get_first_active_project_id()` won't scale to multi-project
- Token in `.env` file is a single-user pattern, not suitable for multi-user deployment
- No real-time updates — user must manually refresh or click Run Now

### Neutral
- Evidence search is server-side (suitable for large datasets, but adds backend load)
- Fire-and-forget run trigger means no direct completion feedback — dashboard reloads after 3s delay

## Evidence

- 328 existing tests pass with no regressions
- Frontend builds cleanly (66 modules, 234KB JS gzipped to 74KB)
- Service methods verified with isolated tempdir unit test

## Links

Sessions:
- S-2026-03-06-0146-ceo-dashboard

PRs:
- (pending PR on branch `tool-research-ops-voice`)

Commits:
- (pending commit)
