# Implementation Plan: Galust AI Layer Chart Sync

**Branch**: `019-galust-ai-layer-chart-sync` (git: `feat/galust-ai-layer-chart-sync-0.2.0`) | **Date**: 2026-07-31 | **Spec**: `/specs/019-galust-ai-layer-chart-sync/spec.md`  
**Input**: Feature specification from `/specs/019-galust-ai-layer-chart-sync/spec.md`

## Summary

In-place sync of `charts/galust-ai-layer` to current `ai-layer/*/helm` production-shaped values: drop `mcpUseCase`, add `orchestratorScheduler`, refresh env/ingress/HPA. Add native Service `sessionAffinity` / `sessionAffinityConfig` to `charts/base` 0.3.33 and consume it from mcp-products values so no post-install Service patch Job is required. CI cutover is out of scope.

## Technical Context

**Language/Version**: Helm 3 template DSL, YAML  
**Primary Dependencies**: `dasmeta/base`, TrueCharts `strapi` 18.9.0, Kubernetes Service `v1`  
**Storage**: N/A (Postgres via TrueCharts CNPG when enabled; Redis/Qdrant external)  
**Testing**: `helm lint`, `helm template`, focused `rg` assertions on rendered YAML  
**Target Platform**: Kubernetes / EKS with nginx ingress and cert-manager  
**Project Type**: Helm chart repository  
**Performance Goals**: N/A  
**Constraints**: No plaintext secrets in values; no `productsOpenapiServer`; no CI rewire; empty sessionAffinity must not render  
**Scale/Scope**: Two charts (`base`, `galust-ai-layer`), one base example, umbrella example overlay, Speckit artifacts under `specs/019-galust-ai-layer-chart-sync/`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Chart-First**: Work stays in `charts/base`, `charts/galust-ai-layer`, repo examples, and repo specs.
- [x] **Values Contract**: New Service affinity is values-driven; umbrella component toggles remain `<alias>.enabled`.
- [x] **Lint & Template**: Plan includes `helm lint` and `helm template` for base (new example + existing) and the umbrella (defaults, disable toggles, example overlay).
- [x] **Versioning & Compatibility**: `galust-ai-layer` 0.2.x (component-set change); `base` 0.3.33 (additive, backward compatible).
- [x] **Simplicity & Defaults**: sessionAffinity omitted by default on base; mcp-products opts in. No patch Job.
- [x] **Examples for new abilities**: `examples/base/with-session-affinity.yaml`; umbrella example overlay updated.
- [x] **Example testing and regression**: Template new base example and existing base examples; template umbrella defaults and `values.test.yaml`.
- [x] **Docs before implementation**: Kubernetes Service `sessionAffinity` / `sessionAffinityConfig` confirmed against v1 Service spec.

## Project Structure

### Documentation (this feature)

```text
specs/019-galust-ai-layer-chart-sync/
├── plan.md
├── spec.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── render-contract.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
charts/
├── base/
│   ├── Chart.yaml
│   ├── README.md
│   ├── values.yaml
│   └── templates/service.yaml
└── galust-ai-layer/
    ├── Chart.yaml
    ├── Chart.lock
    ├── README.md
    ├── values.yaml
    ├── templates/NOTES.txt
    └── charts/base-0.3.33.tgz

examples/
├── base/with-session-affinity.yaml
└── galust-ai-layer/values.test.yaml
```

**Structure Decision**: Keep affinity on the shared `base` Service template. Umbrella only sets mcp-products values; no extra umbrella templates for Service patching.

## Phase 0: Research Plan

- Confirm `ai-layer/*/helm` as source of truth (not docker-compose).
- Confirm `dasmeta/base` 0.3.31 Service template omitted `sessionAffinity`.
- Confirm Kubernetes Service ClientIP timeout default is 10800 seconds.
- Reject Helm hook Job once base can render the fields.

## Phase 1: Design & Contracts Plan

- Document component aliases, env/ingress keys, and Service affinity values in `data-model.md`.
- Define render assertions in `contracts/render-contract.md`.
- Provide lint/template commands in `quickstart.md`.

## Post-Design Constitution Check

- [x] No constitution violations remain.
- [x] Version bumps included (`base` 0.3.33, `galust-ai-layer` 0.2.1).
- [x] New public Service fields paired with README, values comments, and `examples/base/with-session-affinity.yaml`.

## Complexity Tracking

No constitution violations requiring justification.
