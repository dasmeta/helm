# Implementation Plan: Gateway Direct Response Configuration

**Branch**: `010-gateway-direct-response` | **Date**: 2026-04-08 | **Spec**: `/Users/tmuradyan/projects/dasmeta/helm/specs/010-gateway-direct-response/spec.md`  
**Input**: Feature specification from `/specs/010-gateway-direct-response/spec.md`

## Summary

Extend the `gateway-api` chart so operators can define direct responses for non-403 statuses with optional custom body (default empty string), while preserving existing AuthorizationPolicy-based 403 behavior unchanged. The technical approach introduces a dedicated EnvoyFilter rendering path controlled through chart values and explicit precedence guardrails documented in examples and contracts.

## Technical Context

**Language/Version**: Helm template/YAML for Kubernetes and Istio resources  
**Primary Dependencies**: Helm 3, Kubernetes Gateway API resources, Istio EnvoyFilter and AuthorizationPolicy  
**Storage**: N/A  
**Testing**: `helm lint` and `helm template` with default and example values  
**Target Platform**: Kubernetes clusters using Istio + Gateway API  
**Project Type**: Helm chart  
**Performance Goals**: No measurable latency regression; response behavior correctness for configured routes  
**Constraints**: Keep existing 403 authorization flow unchanged; allow direct-response status only in 200-599; default body must be empty string when omitted  
**Scale/Scope**: Single chart feature in `charts/gateway-api` with accompanying examples and docs updates

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Chart-First**: PASS — change is within existing `charts/gateway-api`.
- **Values Contract**: PASS — behavior is configured through values contract only.
- **Lint & Template**: PASS (planned) — run `helm lint` and `helm template` for defaults and examples before implementation complete.
- **Versioning & Compatibility**: PASS (planned) — update chart version if chart files change; keep compatibility notes in README/examples.
- **Simplicity & Defaults**: PASS — feature is opt-in; default install unchanged.
- **Examples for new abilities**: PASS (planned) — add/update example values showing direct-response status/body usage.
- **Example testing and regression**: PASS (planned) — render new/updated examples and existing gateway-api examples.
- **Official documentation before implementation**: PASS (planned) — confirm EnvoyFilter field support and structure against Istio docs.

Post-Phase-1 Re-check: PASS (design artifacts preserve all gate requirements; no violations introduced).

## Project Structure

### Documentation (this feature)

```text
specs/010-gateway-direct-response/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── direct-response-values-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
charts/gateway-api/
├── Chart.yaml
├── README.md
├── values.yaml
└── templates/
    ├── ... existing manifests ...
    └── (new or updated template for EnvoyFilter rendering)

examples/gateway-api/
├── gateway-api-all-routes.values.yaml
├── infrastructure-parameters.yaml
├── ... existing examples ...
└── (new or updated direct-response example values file)
```

**Structure Decision**: Keep all implementation changes localized to `charts/gateway-api` and `examples/gateway-api`; planning artifacts remain under `specs/010-gateway-direct-response`.

## Phase 0: Research Plan

Research tasks derived from technical context and integrations:

1. Validate EnvoyFilter direct_response capabilities relevant to gateway route matching and response body behavior.
2. Define values schema constraints for status range (200-599), default body handling, and precedence rules with existing 403 behavior.
3. Collect Helm chart best practices for optional feature flags and backwards-compatible defaults in existing charts.

Output: `research.md` with decisions, rationale, alternatives.

## Phase 1: Design Plan

1. Extract entities and validation rules into `data-model.md`.
2. Define consumer-facing values contract in `contracts/direct-response-values-contract.md`.
3. Write `quickstart.md` with validation flow (lint/template/default+examples/regression).
4. Skip agent context update (not explicitly requested).

Outputs: `data-model.md`, `contracts/direct-response-values-contract.md`, `quickstart.md`.

## Phase 2: Implementation Planning Stop

Planning artifacts end here; task decomposition is delegated to `/speckit.tasks`.

## Complexity Tracking

No constitution violations requiring justification.
