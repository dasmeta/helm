# Implementation Plan: Zero Trust Mesh Empty Default Allow Rules

**Branch**: `015-zero-trust-mesh` | **Date**: 2026-05-12 | **Spec**: `/specs/015-zero-trust-mesh/spec.md`  
**Input**: Feature specification from `/specs/015-zero-trust-mesh/spec.md`

## Summary

Change zero-trust-mesh so the default `allowTo` list is empty and sample rules are documentation-only. Add a base chart parent override for `zeroTrustMesh.allowTo: []` so enabling the aliased subchart from base does not inherit sample allow rules from the currently packaged dependency.

## Technical Context

**Language/Version**: Helm template DSL, YAML manifests  
**Primary Dependencies**: Helm 3 CLI, zero-trust-mesh chart, base chart dependency alias `zeroTrustMesh`  
**Storage**: N/A  
**Testing**: `helm lint`, `helm template`, focused shell render assertions  
**Target Platform**: Kubernetes clusters using the dasmeta base and zero-trust-mesh Helm charts  
**Project Type**: Helm chart repository  
**Performance Goals**: No rendering performance change  
**Constraints**: Keep explicit `allowTo` behavior intact; avoid changing zero-trust-mesh templates unnecessarily  
**Scale/Scope**: `charts/zero-trust-mesh`, `charts/base`, focused tests, README, and Speckit artifacts under `specs/015-zero-trust-mesh/`

## Constitution Check

*GATE: Must pass before implementation. Re-check after design artifacts.*

- [x] **Chart-First**: Work stays inside chart values, chart docs, chart tests, and repo specs.
- [x] **Values Contract**: The consumer-facing behavior is represented in `values.yaml` as `allowTo: []` and `zeroTrustMesh.allowTo: []`.
- [x] **Lint & Template**: Plan includes `helm lint` and `helm template` checks for standalone and base renders.
- [x] **Versioning & Compatibility**: Change is backward-compatible for explicit values and includes patch version bumps.
- [x] **Simplicity & Defaults**: Fix changes defaults only; template logic remains unchanged.
- [x] **Examples for abilities**: Examples remain in comments and existing example files.
- [x] **Regression testing**: Plan includes render assertions that detect accidental sample allow resources.

## Project Structure

### Documentation (this feature)

```text
specs/015-zero-trust-mesh/
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
├── base/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── tests/
│       └── render-zero-trust-default-empty.sh
└── zero-trust-mesh/
    ├── Chart.yaml
    ├── README.md
    ├── values.yaml
    └── tests/
        └── render-default-empty.sh
```

**Structure Decision**: Keep the behavioral change in values files. The existing templates already guard allow resources behind `.Values.allowTo`, so an empty list is enough to suppress sample resources.

## Phase 0: Research Plan

- Confirm current default render emits sample backend, Stripe, and IP resources.
- Confirm templates are already conditional on `.Values.allowTo`.
- Confirm base must override `zeroTrustMesh.allowTo` because it vendors a packaged dependency.

## Phase 1: Design & Contracts Plan

- Define render contract for empty default behavior in `contracts/render-contract.md`.
- Document `AllowToDefault` and base override behavior in `data-model.md`.
- Provide quickstart commands for focused assertions, chart linting, and explicit-value examples.
- Re-check constitution compliance after artifact generation.

## Post-Design Constitution Check

- [x] No constitution violations remain in the planned implementation.
- [x] Chart version bumps are included in tasks.
- [x] Focused assertions cover standalone and base render behavior.

## Complexity Tracking

No constitution violations requiring justification.
