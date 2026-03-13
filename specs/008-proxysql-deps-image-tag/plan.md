# Implementation Plan: ProxySQL Chart — Dependencies and Image Tag Update

**Branch**: `008-proxysql-deps-image-tag` | **Date**: 2025-03-13 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `specs/008-proxysql-deps-image-tag/spec.md`

## Summary

- **P1:** Update the proxysql chart’s base and base-cronjob dependency versions to the latest available from the configured Helm repository (https://dasmeta.github.io/helm) at implementation time; run `helm dependency update` and ensure lint/template pass.
- **P2:** Set the default image tag in the proxysql chart’s values (`proxysql.image.tag`) to 3.0.6 so it matches the chart’s appVersion (constitution: app version and image tag sync).
- Bump the proxysql chart version (PATCH) after changes; no new examples or README table changes required (only dependency and default value updates).

## Technical Context

**Language/Version**: YAML (Helm Chart.yaml, values.yaml), Helm 3  
**Primary Dependencies**: Helm 3.x, Kubernetes (per chart)  
**Storage**: N/A  
**Testing**: `helm lint charts/proxysql`, `helm template <release> charts/proxysql` (default and existing examples)  
**Target Platform**: Kubernetes  
**Project Type**: helm-chart-repository  
**Constraints**: Charts under `charts/`; version bump on change; lint/template MUST pass; app version and default image tag MUST match (constitution).  
**Scale/Scope**: Single chart (proxysql); only Chart.yaml dependencies, values.yaml default image tag, and chart version.

## Constitution Check

*GATE: Must pass before Phase 0. Re-check after Phase 1.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Chart-First | Deliverables are Helm charts under `charts/`; installable via helm | OK — no new charts |
| II. Values Contract | Config only via values; no hardcoded env-specific values | OK — only default value change |
| III. Lint & Template | Every chart MUST pass `helm lint` and `helm template` | Run for proxysql |
| IV. Versioning & Compatibility | Chart version + app version in Chart.yaml; bump on change | Bump proxysql PATCH |
| V. Simplicity & Defaults | Defaults produce working install | OK — image tag aligns with appVersion |
| App version and image tag sync | Default image tag in values MUST match appVersion | Set proxysql.image.tag to 3.0.6 |
| Example testing & regression | New/updated examples tested; existing examples re-run | N/A — no example file changes |
| Official documentation | Check upstream for object/resource fields | N/A — version metadata and default value only |

No violations; Complexity Tracking left empty.

## Project Structure

### Documentation (this feature)

```text
specs/008-proxysql-deps-image-tag/
├── plan.md              # This file
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/           # Phase 1 (optional; chart values contract if needed)
└── tasks.md             # Phase 2 (/speckit.tasks)
```

### Source (repository root)

```text
charts/
└── proxysql/
    ├── Chart.yaml       # Modify: dependencies (base, base-cronjob versions), version (PATCH)
    └── values.yaml      # Modify: proxysql.image.tag → 3.0.6
```

**Structure decision:** Only the existing proxysql chart is modified; no new charts or examples. Dependency update refreshes Chart.lock and charts/proxysql/charts/ if present.

## Complexity Tracking

None. All constitution gates pass.
