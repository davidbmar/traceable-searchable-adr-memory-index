# ADR-0008: Post-Sprint Review Process

Status: Accepted
Date: 2026-03-07
Session: S-2026-03-07-sprint1-review

## Context

After Sprint 1, we discovered 5 issues during live Playwright verification that weren't caught by unit tests. Without a formal review process, these gaps would accumulate and erode the product experience for founders. We need a repeatable process that catches business logic gaps after every sprint.

## Decision

After every sprint completes, execute a **Post-Sprint Review** before starting the next sprint:

### Step 1: Live UI Verification (Playwright)
- Restart both servers with fresh code
- Navigate to each new feature in the browser
- Test the happy path AND edge cases
- Take screenshots of each feature working (or failing)

### Step 2: Business Requirements Audit
- Re-read the master spec sections relevant to the sprint's workstreams
- For each requirement, score: **Pass** / **Partial** / **Fail**
- Document evidence (screenshot, API response, test result)
- Note any requirement that passes technically but fails the "would a founder find this useful?" test

### Step 3: Gap Identification
- List every issue found during verification
- Classify each as:
  - **Critical** — Breaks user trust or makes feature feel broken (e.g., stale briefs, misleading dates)
  - **Important** — Feature works but quality is low (e.g., monotonous insights, wrong graph edges)
  - **Minor** — Polish items (e.g., empty category counts, loading states)

### Step 4: Backlog Update
- Add all gaps to `docs/backlog.md` with severity, description, and suggested fix
- Link each item to the relevant spec section and ADR
- Critical items become **hotfix candidates** before next sprint
- Important items feed into the next sprint's workstream scope

### Step 5: Sprint Review Document
- Generate `docs/sprint{N}-review.html` with:
  - Key metrics (tests, endpoints, components, lines)
  - Executive summary
  - Per-workstream verification tables with Pass/Partial/Fail
  - Screenshots of each feature
  - Gaps & issues section
  - Master spec coverage table (before vs after)
  - Recommendations for next sprint
  - Sign-off with status

### Step 6: ADR + Session Updates
- Create session doc for the review itself
- Update ADR-0004 (workstream breakdown) with sprint completion status
- File new ADRs for any architectural decisions made during review

## Consequences

### Positive
- Catches business logic gaps that unit tests miss
- Creates an audit trail for stakeholders (the HTML review doc)
- Backlog ensures issues don't get lost between sprints
- Screenshots provide visual proof of feature delivery
- "Would a founder use this?" lens prevents shipping technically-correct-but-useless features

### Negative
- Adds ~30 minutes to each sprint cycle
- Review doc generation requires running servers + Playwright

### Neutral
- Process is the same regardless of sprint size
- Backlog grows over time — needs periodic grooming

## Evidence

Sprint 1 review caught 5 issues that would have gone unnoticed:
1. Event dates defaulting to "Jan 1" (misleading)
2. Brief never auto-regenerating (feels broken)
3. All 57 insights same type (low signal-to-noise)
4. Graph edge role confusion (incorrect relationships)
5. Adoption/Talent showing 0 (regex ordering issue)

## Links

Sessions:
- S-2026-03-07-sprint1-review

Commits:
- `64fbccc` feat: Sprint 1

Backlog:
- docs/backlog.md
