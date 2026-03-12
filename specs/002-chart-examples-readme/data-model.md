# Data Model: Chart Examples and README Improvements

**Feature**: 002-chart-examples-readme  
**Date**: 2026-03-09

No application database. Structural entities for this feature:

## Top-level chart (in scope)

| Attribute | Description | Validation |
|-----------|-------------|------------|
| name | Chart directory name (direct child of `charts/`) | One of the 19 top-level chart names |
| README | File `charts/<name>/README.md` | Must satisfy FR-001 (full or reduced standard per chart type) |
| type | From Chart.yaml `type` | `application` → full README standard; `library` or dependency-only → reduced README |
| nested subcharts | Directories under `charts/<name>/charts/` | Out of scope; parent README MUST mention them |

## README content (full standard)

- Description (what the chart does)
- Install steps (including `helm repo add dasmeta`, install command)
- Link to `values.yaml` (and its comments) for public values
- Optional: short "key values" subsection (3–5 main options)
- If chart has nested subcharts: mention and briefly describe them
- Prerequisites if any (CRDs, secrets)—document, no literal secrets

## README content (reduced standard, library/dependency charts)

- One short paragraph: what the chart is, that it's used as a dependency
- Link to values.yaml or parent chart

## Example values

| Attribute | Description | Validation |
|-----------|-------------|------------|
| location | `examples/<chart-name>/` (repo root) | All examples for a chart live here |
| file | YAML file(s) (e.g. `basic.yaml`, `with-feature-x.yaml`) | Usable with `helm template <release> charts/<chart-name> -f examples/<chart-name>/<file>.yaml` |
| content | Values overrides only; no env-specific literals | Placeholders or safe defaults; document substitution where needed |

## Audit: chart type (T003)

All 19 top-level charts have `type: application` in Chart.yaml (or omit type; Helm default is application). **No library/dependency-only charts** in the top-level list → all use **full README standard** (description, install, link to values.yaml, optional key values, mention nested subcharts where present).

## Out of scope

- Nested subchart directories (e.g. `charts/weave-scope/charts/weave-scope-frontend/`)
- Examples inside `charts/<chart-name>/` for new or updated examples in this feature
