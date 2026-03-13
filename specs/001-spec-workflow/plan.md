# Implementation Plan: Spec Workflow

**Branch**: `001-spec-workflow` | **Date**: 2026-03-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-spec-workflow/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Establish the spec-driven workflow for dasmeta/helm: feature specs under `specs/<###-feature-name>/`, implementation plans with Constitution Check gates, and Phase 0/1 artifacts (research, data-model, quickstart, contracts). All deliverables remain Helm charts under `charts/`; no new application code—only chart YAML, values, and templates. Technical approach: use existing constitution principles as plan gates; document chart layout and values contract as the primary "data model" and contracts.

## Technical Context

**Language/Version**: YAML (Helm templates), Helm 3
**Primary Dependencies**: Helm 3.x, Kubernetes (version per chart in Chart.yaml / kubeVersion)
**Storage**: N/A (charts are declarative manifests; no runtime storage)
**Testing**: `helm lint`, `helm template` with default values (per constitution); optional chart-testing or CI
**Target Platform**: Kubernetes clusters (version documented per chart)
**Project Type**: helm-chart-repository
**Performance Goals**: N/A (chart rendering and install performance are tooling concerns)
**Constraints**: Charts under `charts/`; configuration only via values.yaml and overrides; lint/template MUST pass
**Scale/Scope**: Multiple charts in one repo (e.g. base, base-cronjob, karpenter-nodes, proxysql, etc.); each chart one directory

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Chart-First | All deliverables are Helm charts under `charts/<chart-name>/`; installable via `helm upgrade --install` or as dependency | PASS |
| II. Values Contract | Configuration only via values.yaml and `--set`/`-f`; no hardcoded env-specific values; public values documented in README/values.yaml | PASS |
| III. Lint & Template | Every chart MUST pass `helm lint` and `helm template` with default values before merge; CI SHOULD enforce | PASS |
| IV. Versioning & Compatibility | Chart and app version in Chart.yaml; semver; breaking value changes = MAJOR bump; document kubeVersion/Helm min | PASS |
| V. Simplicity & Defaults | Default values produce working install for primary use case; optional features behind explicit flags (YAGNI) | PASS |

No violations. Complexity Tracking table left empty.

## Project Structure

### Documentation (this feature)

```text
specs/001-spec-workflow/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Repository (charts only)

```text
charts/
├── base/
├── base-cronjob/
├── karpenter-nodes/
├── proxysql/
├── gateway-api/
├── resource/
├── ... (other chart directories)
├── examples/            # if present: example values files
githooks/                # pre-commit hooks (optional)
.specify/                # speckit workflow (constitution, templates, scripts)
```

**Structure Decision**: Helm chart repository. No `src/` or application code; all deliverables are charts under `charts/`. Spec workflow artifacts live under `specs/<branch>/`. Per constitution, chart naming is lowercase, hyphen-separated.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

(No violations.)
