# Research: README values table (004)

**Feature**: 004-readme-values-table  
**Date**: 2026-03-09

## Findings

| Topic | Finding |
|-------|---------|
| Reference format | spqr-router README (lines 57–62): table with Key, Description, Default/Example; Key = dotted path (e.g. `routerConfig.listen_addr`). |
| Existing tables | spqr-router, pgcat have key-values tables; other charts mostly link to values.yaml only. |
| Scope | 19 top-level charts; nested subcharts out of scope (parent can link to subchart values). |
| Sync | Constitution now requires README table and values.yaml updated in same change. |
| Table size | Spec allows "key options" (3–10 rows) with link to values.yaml for full list, or full list if chart has few values. |

## Decisions

- Use spqr-router table format as the canonical example.
- Per-chart task: ensure README has at least one table; derive rows from that chart's values.yaml (top-level or section keys).
- No automated sync tool required for this feature; process rule (same PR) suffices.
