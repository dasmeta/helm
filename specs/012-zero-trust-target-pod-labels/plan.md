# Implementation Plan: Zero Trust Target Pod Labels

**Branch**: `012-zero-trust-target-pod-labels` | **Date**: 2026-05-07 | **Spec**: `/specs/012-zero-trust-target-pod-labels/spec.md`  
**Input**: Feature specification from `/specs/012-zero-trust-target-pod-labels/spec.md`

## Summary

Add optional `allowTo[].targetPodLabels` to the zero-trust-mesh chart so generated NetworkPolicy and AuthorizationPolicy target selectors can match the real labels on destination pods. Keep the existing `app.kubernetes.io/name: <service>` selector as the backward-compatible fallback, add examples/docs, and validate with Helm render checks.

## Technical Context

**Language/Version**: Helm template DSL, YAML manifests  
**Primary Dependencies**: Helm 3 CLI, Kubernetes NetworkPolicy `networking.k8s.io/v1`, Istio AuthorizationPolicy `security.istio.io/v1`  
**Storage**: N/A  
**Testing**: `helm lint`, `helm template`, focused shell render assertion  
**Target Platform**: Kubernetes clusters with a NetworkPolicy provider and Istio policy support  
**Project Type**: Helm chart repository  
**Performance Goals**: Render behavior remains constant-time relative to existing allow rule count  
**Constraints**: Preserve existing values compatibility; keep selectors label-map based; no new chart dependencies  
**Scale/Scope**: One chart (`zero-trust-mesh`) plus one example under `examples/zero-trust-mesh/`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Chart-First**: Work stays inside `charts/zero-trust-mesh` and repo examples/specs.
- [x] **Values Contract**: New consumer-facing behavior is exposed via `values.yaml` as `allowTo[].targetPodLabels`.
- [x] **Lint & Template**: Plan includes `helm lint` and `helm template` with default and example values.
- [x] **Versioning & Compatibility**: Backward-compatible fallback is preserved; plan includes a chart patch version bump.
- [x] **Simplicity & Defaults**: Default values remain unchanged and continue to render the existing selector.
- [x] **Examples for new abilities**: Plan includes `examples/zero-trust-mesh/target-pod-labels.yaml`.
- [x] **Example testing and regression**: Plan includes rendering the new example and existing zero-trust-mesh examples.
- [x] **Official documentation before implementation**: Kubernetes and Istio selector field shapes are checked in official docs before finalizing the plan.

## Project Structure

### Documentation (this feature)

```text
specs/012-zero-trust-target-pod-labels/
├── plan.md
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
    │   ├── istio-authorizations.yaml
    │   └── networkpolicy-flows.yaml
    └── tests/
        ├── render-target-pod-labels.sh
        └── target-pod-labels-values.yaml

examples/
└── zero-trust-mesh/
    └── target-pod-labels.yaml
```

**Structure Decision**: Use one shared Helm helper for target selector labels so Istio and Kubernetes policy templates cannot drift. Keep the render assertion local to the chart and the runnable user example in the repo-level examples directory.

## Phase 0: Research Plan

- Confirm Kubernetes NetworkPolicy `spec.podSelector.matchLabels` accepts label maps for selecting affected pods.
- Confirm Istio AuthorizationPolicy `spec.selector.matchLabels` accepts label maps for selecting target workloads in the policy namespace.
- Confirm existing chart selector usage and values documentation conventions.

## Phase 1: Design & Contracts Plan

- Document `ServiceAllowRule` and `TargetPodLabels` in `data-model.md`.
- Define render contract for custom-label and fallback-label cases in `contracts/render-contract.md`.
- Provide quickstart commands for chart linting and rendering default, new example, and regression examples.
- Re-check constitution compliance after artifact generation.

## Post-Design Constitution Check

- [x] No constitution violations remain in the planned implementation.
- [x] Chart version bump is included in tasks.
- [x] New public value is paired with README/values documentation and a runnable example.

## Complexity Tracking

No constitution violations requiring justification.
