# Implementation Plan: Chart Examples and README Improvements

**Branch**: `002-chart-examples-readme` | **Date**: 2026-03-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-chart-examples-readme/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Improve documentation for every top-level Helm chart: each chart MUST have a README that meets FR-001 (full standard for application charts; reduced standard for library/dependency-only charts), and SHOULD have at least one example values file in repo-level `examples/<chart-name>/` that passes `helm template`/`helm lint`. Nested subcharts are out of scope; parent READMEs mention them. Technical approach: audit all top-level charts (19 directories under `charts/`), add or update READMEs and examples per spec; validate with helm lint/template; no mandatory order—all charts in scope equally.

## Technical Context

**Language/Version**: YAML (Helm templates, values), Markdown (READMEs), Helm 3
**Primary Dependencies**: Helm 3.x, Kubernetes (version per chart in Chart.yaml / kubeVersion)
**Storage**: N/A (documentation and example values files only)
**Testing**: `helm lint charts/<chart-name>`, `helm template <release> charts/<chart-name> -f examples/<chart-name>/<file>.yaml`; manual "new user" test per SC-003
**Target Platform**: Kubernetes clusters; docs consumed by humans and CI
**Project Type**: helm-chart-repository (documentation improvement feature)
**Performance Goals**: N/A
**Constraints**: Top-level charts only; examples in `examples/<chart-name>/`; no hardcoded env-specific values in READMEs/examples; constitution (Values Contract, Lint & Template) applies
**Scale/Scope**: 19 top-level charts (base, base-cronjob, cloudwatch-agent-prometheus, flagger-metrics-and-alerts, gateway-api, helm-chart-test, kafka-connect, karpenter-nodes, kubernetes-event-exporter-enriched, mongodb-bi-connector, namespaces-and-docker-auth, nfs-provisioner, pgcat, proxysql, resource, sentry-relay, spqr-router, weave-scope); no nested subcharts in scope

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Chart-First | No new charts; only README and example files for existing charts under `charts/<chart-name>/` and `examples/<chart-name>/` | PASS |
| II. Values Contract | README links to values.yaml; examples are values overrides only; no hardcoded env-specific values | PASS |
| III. Lint & Template | Every chart (and example used with it) MUST pass helm lint and helm template; validation in tasks | PASS |
| IV. Versioning & Compatibility | No chart code/template changes; version bumps only if values or chart metadata change per existing workflow | PASS |
| V. Simplicity & Defaults | Examples demonstrate valid config; optional "key values" in README limited to 3–5 | PASS |

No violations. Complexity Tracking table left empty.

## Project Structure

### Documentation (this feature)

```text
specs/002-chart-examples-readme/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Repository (charts + examples)

```text
charts/                  # Top-level chart directories only (in scope)
├── base/
├── base-cronjob/
├── cloudwatch-agent-prometheus/
├── flagger-metrics-and-alerts/
├── gateway-api/
├── helm-chart-test/
├── kafka-connect/
├── karpenter-nodes/
├── kubernetes-event-exporter-enriched/
├── mongodb-bi-connector/
├── namespaces-and-docker-auth/
├── nfs-provisioner/
├── pgcat/
├── proxysql/
├── resource/
├── sentry-relay/
├── spqr-router/
└── weave-scope/

examples/                # Repo-level example values per chart (standardized location)
├── base/                # existing
├── <chart-name>/        # one dir per top-level chart; YAML values files
...
```

**Structure Decision**: Helm chart repository. This feature adds or updates only READMEs under `charts/<chart-name>/` and example values under `examples/<chart-name>/`. No new chart code; nested subcharts (e.g. under `charts/weave-scope/charts/`) are out of scope—parent README mentions them.

**Implement / version bumps**: Per FR-005 (spec and contract), any change under a chart directory (including README or examples) requires a PATCH version bump in that chart's `Chart.yaml`. The implement phase MUST include a final step (or task) that increments `version` for every modified chart; base's gateway-api dependency MUST be updated if gateway-api was bumped.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

(No violations.)
