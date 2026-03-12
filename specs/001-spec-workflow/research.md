# Research: Spec Workflow for dasmeta/helm

**Feature**: 001-spec-workflow  
**Date**: 2026-03-09

## Decisions

| Topic | Decision | Rationale |
|-------|----------|-----------|
| Workflow placement | Specs under `specs/<###-feature-name>/`; plan gates from `.specify/memory/constitution.md` | Matches speckit convention; constitution is single source of truth for chart rules. |
| Technical context | Helm 3, YAML, charts-only repo; no application language | This repo only ships Helm charts; no backend/frontend code. |
| Constitution Check | Five principles as explicit gates in plan.md; no exceptions for this feature | Ensures every plan phase validates against Chart-First, Values Contract, Lint & Template, Versioning, Simplicity. |
| Phase 1 artifacts | data-model = chart/values structure; contracts = values schema or chart “API”; quickstart = add repo + install | Adapted for chart repos: “data” is chart metadata and values shape; “contracts” are how consumers use the chart. |

## Alternatives Considered

- **Generic plan template (src/, tests/)**: Rejected for this repo; would not reflect charts-only layout.
- **Skipping data-model/contracts**: Kept with chart-specific meaning so future features (e.g. new chart) have a pattern for documenting values and usage.
- **Separate constitution check file**: Kept inside plan.md so one artifact holds both technical context and gates; constitution file remains authoritative.

## References

- `.specify/memory/constitution.md` (Dasmeta Helm Charts Constitution)
- [Helm docs](https://helm.sh/docs/) (chart structure, values, lint/template)
- Repo README: `helm repo add dasmeta https://dasmeta.github.io/helm`, charts under `./charts`
