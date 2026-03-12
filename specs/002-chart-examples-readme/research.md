# Research: Chart Examples and README Improvements

**Feature**: 002-chart-examples-readme  
**Date**: 2026-03-09

## Decisions

| Topic | Decision | Rationale |
|-------|----------|-----------|
| Scope (which charts) | Top-level chart directories under `charts/` only; nested subcharts out of scope | Clarification: parent README documents nested subcharts; avoids exploding task set. |
| Examples location | Repo-level `examples/<chart-name>/` for all charts; READMEs point here | Clarification: single standard; aligns with existing `examples/base/`. |
| Value documentation depth | README links to values.yaml (and comments) as source of truth; MAY include "key values" (3–5 options) | Clarification: maintainable; avoids duplicating full schema. |
| Library charts | Reduced README standard: one short paragraph (what it is, dependency, link to values/parent) | Clarification: proportional to use case. |
| Implementation order | No mandatory order; all 19 top-level charts equally in scope | Clarification: plan/tasks can batch or order by convenience. |

## Alternatives Considered

- **Include nested subcharts**: Rejected; would require README/examples for every Chart.yaml under charts/ (e.g. weave-scope subcharts); scope agreed as top-level only.
- **Allow examples inside chart dir**: Rejected; standardized on `examples/<chart-name>/` for consistency and discoverability.
- **Full value table in every README**: Rejected; link to values.yaml + optional key values reduces drift and maintenance.
- **Phased MVP (e.g. base first)**: Rejected; treat all charts equally; success = 100% of top-level charts.

## References

- Spec: `specs/002-chart-examples-readme/spec.md` (including Clarifications)
- Constitution: `.specify/memory/constitution.md` (Values Contract, Lint & Template)
- Existing examples: `examples/base/` (e.g. basic.yaml)
