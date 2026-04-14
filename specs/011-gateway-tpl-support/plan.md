# Implementation Plan: Gateway API tpl Support

**Branch**: `011-gateway-tpl-support` | **Date**: 2026-04-14 | **Spec**: `/specs/011-gateway-tpl-support/spec.md`  
**Input**: Feature specification from `/specs/011-gateway-tpl-support/spec.md`

## Summary

Add templating support parity for Gateway API and Istio sections by allowing resolved template expressions in HTTPRoute hostnames, AuthorizationPolicy rules, and EnvoyFilter config patches. Deliver the change with chart/example validation, no regression to static values, and updated examples/documentation that show end-user usage.

## Technical Context

**Language/Version**: Helm template DSL (Go templates via `tpl`), YAML manifests  
**Primary Dependencies**: Helm 3 CLI, Gateway API resources, Istio resources, chart values schema  
**Storage**: N/A (render-time configuration only)  
**Testing**: `helm lint`, `helm template` for changed/new examples, regression templates for existing examples  
**Target Platform**: Kubernetes clusters consuming rendered Helm manifests  
**Project Type**: Helm chart repository  
**Performance Goals**: Render succeeds for all affected examples in a single run without manual post-processing  
**Constraints**: Preserve existing static behavior; maintain valid YAML indentation and object structure; keep chart consumer-facing values contract stable  
**Scale/Scope**: One chart (`gateway-api`) with related base chart dependency and examples/docs updates

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Chart-First**: Work remains within existing Helm charts under `charts/`.
- [x] **Values Contract**: New behavior is template evaluation of user-provided values; no environment hardcoding introduced.
- [x] **Lint & Template**: Plan includes mandatory `helm lint` and `helm template` validation for changed chart and examples.
- [x] **Examples for new abilities**: Plan includes updates to `examples/gateway-api/` and regression checks for existing examples.
- [x] **Example testing and regression**: Plan includes rendering updated example and additional existing examples.
- [x] **Official documentation before implementation**: Plan includes validation against Gateway API and Istio field expectations for target sections.
- [x] **Versioning & compatibility**: Plan includes chart version bump for modified charts before completion.

## Project Structure

### Documentation (this feature)

```text
specs/011-gateway-tpl-support/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── render-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
charts/
├── gateway-api/
│   ├── Chart.yaml
│   └── templates/
│       ├── httproute.yaml
│       └── istio/
│           ├── authorizationpolicy.yaml
│           └── envoyfilter.yaml
└── base/
    └── Chart.yaml

examples/
├── gateway-api/
│   └── with-istio-envoyfilter-direct-response.yaml
└── base/
    └── with-istio-gateway-api-http-route-only.yaml
```

**Structure Decision**: Keep all changes inside existing chart templates, chart metadata versions, and example values files. No new runtime components are introduced.

## Phase 0: Research Plan

- Confirm render behavior and indentation guarantees when using `tpl (toYaml ...)` in list/object fields.
- Confirm expected field shapes for:
  - HTTPRoute `hostnames`
  - AuthorizationPolicy `rules`
  - EnvoyFilter `configPatches`
- Confirm validation commands and representative examples for non-regression coverage.

## Phase 1: Design & Contracts Plan

- Document value entities and render transformations in `data-model.md`.
- Define render-time contract (inputs, outputs, and failure semantics) in `contracts/render-contract.md`.
- Provide operator execution and verification flow in `quickstart.md`.
- Re-check constitution compliance after artifact generation.

## Post-Design Constitution Check

- [x] No constitution violations introduced by planned approach.
- [x] Plan explicitly includes example updates and regression rendering.
- [x] Plan explicitly includes chart version bump expectations.

## Complexity Tracking

No constitution violations requiring justification.
