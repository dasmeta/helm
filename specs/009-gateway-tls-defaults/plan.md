# Implementation Plan: Gateway TLS Defaults for HTTPS Listeners

**Branch**: `009-gateway-tls-defaults` | **Date**: 2026-03-16 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `specs/009-gateway-tls-defaults/spec.md`

## Summary

The gateway-api Helm chart must default TLS for HTTPS listeners when `tls` is missing or effectively empty: render `mode: Terminate` and a single `certificateRefs` entry pointing to a Secret named `{gateway-name}-tls` (where `{gateway-name}` is the effective Gateway metadata name). When `tls` is non-empty, the chart must pass it through unchanged. Non-HTTTPS listeners must not receive any TLS block. Implementation is template-only in `charts/gateway-api/templates/gateway.yaml` (and optionally a small helper in `_helpers.tpl` for the effective gateway name). No new chart dependencies; validation via `helm lint` and `helm template` with existing and new example values.

## Technical Context

**Language/Version**: Helm 3, YAML (templates/values), Gateway API v1  
**Primary Dependencies**: Kubernetes Gateway API CRDs, Istio (optional at runtime); chart has no new dependencies  
**Storage**: N/A  
**Testing**: `helm lint charts/gateway-api`; `helm template <release> charts/gateway-api -f <values>` with default and example values; regression over existing `examples/gateway-api/*`  
**Target Platform**: Kubernetes (version per chart); Helm 3  
**Project Type**: helm-chart (gateway-api only)  
**Performance Goals**: N/A (render-time only)  
**Constraints**: Values-only configuration; no hardcoded env; default TLS only when `tls` absent or effectively empty (`{}`/null)  
**Scale/Scope**: Single chart change; multiple gateways/listeners already supported; TLS default applies per HTTPS listener

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Chart-First | Deliverable is the gateway-api chart under `charts/gateway-api/` | PASS |
| II. Values Contract | TLS defaulting driven by presence/absence of `tls` in values; no hardcoded env | PASS |
| III. Lint & Template | Chart MUST pass `helm lint` and `helm template` with default and examples | PASS |
| IV. Versioning & Compatibility | PATCH bump to `charts/gateway-api/Chart.yaml` on change | PASS |
| V. Simplicity & Defaults | Default TLS only when `tls` empty/null; explicit `tls` preserved | PASS |
| Example testing & regression | New/updated examples tested; existing examples re-run | PASS |
| Official documentation | Gateway API TLS listener spec used for `tls.mode`, `certificateRefs` | PASS |

No violations; Complexity Tracking left empty.

## Project Structure

### Documentation (this feature)

```text
specs/009-gateway-tls-defaults/
├── plan.md              # This file
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/            # Phase 1 (optional)
└── tasks.md             # Phase 2 (/speckit.tasks - not created by plan)
```

### Source Code (repository root)

```text
charts/
└── gateway-api/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── _helpers.tpl    # Optional: add gateway effective-name helper
        └── gateway.yaml    # Main change: TLS defaulting for HTTPS listeners

examples/
└── gateway-api/            # Add/update example with HTTPS listener without tls
```

**Structure Decision**: Single-chart change. All edits under `charts/gateway-api/`. Optional helper in `_helpers.tpl` for the effective Gateway name reused for `metadata.name` and default TLS Secret name `{gateway-name}-tls`. One or more example values files under `examples/gateway-api/` to demonstrate defaulted TLS and regression for explicit TLS.

## Complexity Tracking

No Constitution violations. Table not used.
