# Session

Session-ID: S-2026-03-06-0146-ceo-dashboard
Title: CEO Dashboard — Research Engine Productization
Date: 2026-03-06
Author: David Mar + Claude

## Goal

Add 4 REST endpoints (`/api/mission/`) and a CEO Dashboard frontend view so overnight research engine results are visible in the browser, end-to-end.

## Context

The overnight research engine is running (research_collector every 2h, research_briefing daily at 8am). It accumulates evidence in `data/research_projects/{id}/evidence.json`, logs passes in `pass_log.json`, and generates morning reports in `reports/{date}.json`. But there was no UI to see results — only raw JSON files on disk.

Existing pieces reused:
- `ResearchProjectService` (`voiceos/services/research_project.py`) — CRUD, evidence, pass logs, report save
- `SchedulerService` (`voiceos/services/scheduler.py`) — `run_now()` for manual triggers
- Existing research endpoints at `/api/research/projects/` in `server.py`
- Research wizard UI with Zustand store, LeftRail nav, dark theme (gold/teal)

## Plan

12-task plan:
1. Add `list_reports()` and `get_latest_report()` to ResearchProjectService
2. Add 4 `/api/mission/` endpoints to server.py (run, status, brief, evidence)
3. Add Dashboard types to `types.ts`
4. Add Dashboard API functions to `api.ts`
5. Extend Zustand store with dashboard state
6. Create MorningBriefCard component
7. Create RunTimeline component
8. Create EvidenceDrawer component
9. Create DashboardView component
10. Wire LeftRail view switching
11. Update AppLayout for view switching
12. Build + verify

## Changes Made

### Backend
- **`voiceos/services/research_project.py`** — Added `list_reports()` (returns sorted report filenames) and `get_latest_report()` (loads most recent report JSON)
- **`server.py`** — Added `_get_first_active_project_id()` helper and 4 endpoints:
  - `POST /api/mission/run` — Triggers collection pass via `asyncio.create_task` (fire-and-forget)
  - `GET /api/mission/status` — Returns project status, pass count, evidence total, full pass_log
  - `GET /api/mission/brief` — Returns latest morning briefing report
  - `GET /api/mission/evidence` — Paginated evidence with server-side search (case-insensitive on claim + source_title)

### Frontend
- **`web/research/src/types.ts`** — Added `ViewId`, `MissionStatus`, `PassLogEntry`, `MorningBrief`, `EvidenceItem`, `EvidenceResponse`
- **`web/research/src/api.ts`** — Added `authHeaders()` helper using `VITE_ADMIN_TOKEN`, plus 4 fetch functions: `fetchMissionStatus`, `fetchMorningBrief`, `fetchEvidence`, `triggerMissionRun`
- **`web/research/src/store.ts`** — Added `activeView`, `missionStatus`, `morningBrief`, `dashboardLoading`, `runningMission` state; `setActiveView()`, `loadDashboard()` (parallel fetch via Promise.allSettled), `triggerRun()`
- **`web/research/src/components/dashboard/MorningBriefCard.tsx`** — Executive summary card with key findings as gold Chips, Run Now button (gold-glow, spinner), View Evidence button with count badge
- **`web/research/src/components/dashboard/RunTimeline.tsx`** — Vertical timeline (most recent first), gold pass-number dots, teal claim badges, relative timestamps
- **`web/research/src/components/dashboard/EvidenceDrawer.tsx`** — Slide-out overlay with 300ms debounced search, paginated list, confidence badges (gold >=0.8, teal >=0.5, default), clickable source links
- **`web/research/src/components/dashboard/DashboardView.tsx`** — Top bar (title + status badge + pass count), two-column layout (brief card + timeline), loading/empty states
- **`web/research/src/components/LeftRail.tsx`** — "Runs" renamed to "Dashboard", active state driven by store's `activeView`, History/Settings remain disabled
- **`web/research/src/components/AppLayout.tsx`** — Conditional rendering: DashboardView vs wizard grid based on `activeView`
- **`web/research/.env`** — Created with `VITE_ADMIN_TOKEN` for Bearer auth on dashboard API calls

## Decisions Made

1. **All mission endpoints use first active project** — MVP shortcut via `_get_first_active_project_id()`. Avoids requiring project selection when there's typically one active project.
2. **Fire-and-forget for run trigger** — `asyncio.create_task()` returns immediately with pass number. Avoids long HTTP timeout while collection runs.
3. **Promise.allSettled for dashboard loading** — Status and brief fetched in parallel. If brief 404s (no reports yet), status still renders. Partial data is better than total failure.
4. **Bearer token via VITE_ADMIN_TOKEN** — Frontend sends admin token from `.env`. Suitable for single-user internal tool. `.env` is gitignored.
5. **Server-side evidence filtering** — Search and pagination handled by the backend, not client-side, to support large evidence sets.
6. **Reused existing Chip component** — Gold variant for key findings, maintaining visual consistency with wizard.

## Open Questions

- Should the dashboard auto-poll for status updates while a run is in progress?
- Should evidence drawer support infinite scroll instead of "load more" button?
- Multi-project support: when would we need a project selector?

## Links

Commits:
- (pending commit)

PRs:
- (pending PR on branch `tool-research-ops-voice`)

ADRs:
- ADR-0002 — CEO Dashboard architecture
