# ADR-0003: Signal Category Architecture v1

Date: 2026-03-06
Status: Accepted
Session: S-2026-03-06-2300-signal-categories-v1

## Context

The CEO Radar detects high-confidence signals from research evidence using regex pattern matching. The original 5 categories (funding, startup, launch, partnership, regulatory) missed two high-value signal types that founders need for strategic decision-making.

## Decision

Expand to 7 signal categories with a specific ordering for first-match-wins classification:

```
CATEGORY_PATTERNS order:
1. funding      — $X raised, funding round, Series A/B/C, valuation, ARR, revenue
2. startup      — startup, stealth, new company, emerging player, new entrant
3. launch       — launched, released, unveiled, announced, rolled out, deployed (product)
4. partnership  — partnered, collaborated, teamed up, joint venture, alliance, integrated with
5. adoption     — deploying, adopting, using, implemented, customers, enterprise adoption
6. talent       — laid off, hired, appointed, resigned, restructuring, headcount, growing team
7. regulatory   — EU, FTC, regulation, compliance, AI Act, legislation, executive order
```

### Why this order?

First-match-wins means an evidence item is classified by whichever pattern matches first. Order resolves ambiguity:

- "ElevenLabs raised $180M and hired 200 engineers" -> funding (money is primary signal)
- "Microsoft partners with OpenAI to deploy voice AI" -> partnership (alliance is primary)
- "Amazon deploying AI voice agents in warehouses" -> adoption (usage is primary)
- "Jasper laid off 60% of staff" -> talent (workforce is primary)
- "EU regulating AI voice synthesis" -> regulatory (policy is primary)

### Why Adoption?

Adoption signals answer "Is this actually being used?" — a stronger indicator of product-market fit than funding. Examples:
- "500 companies now using Retell voice platform"
- "Healthcare providers adopting voice documentation AI"
- "Stripe using AI voice agents for customer support"

### Why Talent?

Talent signals reveal company health and market direction:
- Layoffs = distress or pivot
- Hiring sprees = growth and confidence
- Exec departures = instability
- Key hires = strategic moves

## Consequences

- Signal cache auto-invalidates when evidence count changes (existing mechanism)
- Existing evidence will be re-classified on next dashboard load
- RadarCard UI needs 2 new category entries (adoption, talent)
- SignalTotals type extends with 2 new fields
- Tests must verify first-match-wins ordering for ambiguous evidence items
- Future: sub-types (talent.layoff vs talent.hire) and sentiment (bullish/bearish) deferred to v2
