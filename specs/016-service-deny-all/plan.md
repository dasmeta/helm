# Implementation Plan: Service-Level Deny All

**Branch**: `016-service-deny-all` | **Date**: 2026-05-21 | **Spec**: `/specs/016-service-deny-all/spec.md`  
**Input**: Feature specification from `/specs/016-service-deny-all/spec.md`

## Summary

Add a disabled-by-default service-level deny-all option to `charts/zero-trust-mesh`. When enabled, it renders workload-scoped Kubernetes NetworkPolicy default deny for both ingress and egress, plus workload-scoped Istio AuthorizationPolicy default deny for inbound mesh traffic. Namespace baseline behavior and existing `allowTo` rules remain unchanged.

## Technical Context

**Language/Version**: Helm template DSL, YAML manifests  
**Primary Dependencies**: Helm 3 CLI, Kubernetes NetworkPolicy `networking.k8s.io/v1`, Istio AuthorizationPolicy `security.istio.io/v1`  
**Storage**: N/A  
**Testing**: `helm lint`, `helm template`, focused shell render assertion  
**Target Platform**: Kubernetes clusters with a NetworkPolicy provider and Istio sidecar traffic management  
**Project Type**: Helm chart repository  
**Performance Goals**: Render behavior remains constant for the deny-all option and linear for existing `allowTo` entries  
**Constraints**: Disabled by default; service/workload scoped only; no namespace-wide behavior changes; compatible with later explicit allow rules  
**Scale/Scope**: One chart (`zero-trust-mesh`), one example under `examples/zero-trust-mesh/`, focused tests, and Speckit artifacts under `specs/016-service-deny-all/`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Chart-First**: Work stays inside `charts/zero-trust-mesh`, repo examples, and repo specs.
- [x] **Values Contract**: New consumer-facing behavior is exposed via values as a disabled-by-default service deny-all block.
- [x] **Lint & Template**: Plan includes `helm lint` and `helm template` with focused and existing examples.
- [x] **Versioning & Compatibility**: Change is backward-compatible and includes a patch version bump.
- [x] **Simplicity & Defaults**: New behavior is opt-in and defaults to no rendered resources.
- [x] **Examples for new abilities**: Plan includes `examples/zero-trust-mesh/service-deny-all.yaml`.
- [x] **Example testing and regression**: Plan includes rendering the new example and existing zero-trust-mesh examples.
- [x] **Docs before implementation**: Kubernetes NetworkPolicy and Istio AuthorizationPolicy shapes are confirmed against existing repo usage and documented in research.

## Project Structure

### Documentation (this feature)

```text
specs/016-service-deny-all/
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
└── zero-trust-mesh/
    ├── Chart.yaml
    ├── README.md
    ├── values.yaml
    ├── templates/
    │   ├── _helpers.tpl
    │   ├── istio-service-deny-all.yaml
    │   └── networkpolicy-service-deny-all.yaml
    └── tests/
        ├── service-deny-all-values.yaml
        └── render-service-deny-all.sh

examples/
└── zero-trust-mesh/
    └── service-deny-all.yaml
```

**Structure Decision**: Keep service-level deny-all in dedicated templates so namespace baseline default-deny templates remain unchanged and the new option stays visibly service scoped.

## Phase 0: Research Plan

- Confirm current namespace-level deny-all resources and avoid modifying those templates.
- Confirm service-level selector behavior follows existing `workload` and override patterns.
- Confirm additive Kubernetes NetworkPolicy behavior supports opening explicit allow rules later.
- Confirm Istio default-deny behavior should use an ALLOW policy with no rules, not an action DENY policy.

## Phase 1: Design & Contracts Plan

- Document the service deny-all option, workload selector, NetworkPolicy, and AuthorizationPolicy in `data-model.md`.
- Define render contract for the new resources, selector override, disabled defaults, and regression behavior in `contracts/render-contract.md`.
- Provide quickstart commands for focused render assertions, chart linting, default rendering, and example rendering.
- Re-check constitution compliance after artifact generation.

## Post-Design Constitution Check

- [x] No constitution violations remain in the planned implementation.
- [x] Chart version bump is included in tasks.
- [x] New public value is paired with README/values documentation and a runnable example.

## Complexity Tracking

No constitution violations requiring justification.
