# Implementation Plan: Zero Trust IP Egress

**Branch**: `013-zero-trust-ip-egress` | **Date**: 2026-05-08 | **Spec**: `/specs/013-zero-trust-ip-egress/spec.md`  
**Input**: Feature specification from `/specs/013-zero-trust-ip-egress/spec.md`

## Summary

Add `allowTo[].ips` to the zero-trust-mesh chart so workloads that call external destination IPs directly can be allowed through both Istio and Kubernetes network policy. Render IP rules as Istio ServiceEntries with `addresses` and `resolution: NONE`, plus source-workload egress NetworkPolicies using `ipBlock`.

## Technical Context

**Language/Version**: Helm template DSL, YAML manifests  
**Primary Dependencies**: Helm 3 CLI, Kubernetes NetworkPolicy `networking.k8s.io/v1`, Istio ServiceEntry `networking.istio.io/v1`  
**Storage**: N/A  
**Testing**: `helm lint`, `helm template`, focused shell render assertion  
**Target Platform**: Kubernetes clusters with a NetworkPolicy provider and Istio sidecar traffic management  
**Project Type**: Helm chart repository  
**Performance Goals**: Render behavior remains linear in `allowTo` entry count and configured IP count  
**Constraints**: Preserve existing service and host rule behavior; expose behavior only through values; add a runnable example for the new public values surface  
**Scale/Scope**: One chart (`zero-trust-mesh`), one example under `examples/zero-trust-mesh/`, and Speckit artifacts under `specs/013-zero-trust-ip-egress/`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Chart-First**: Work stays inside `charts/zero-trust-mesh`, repo examples, and repo specs.
- [x] **Values Contract**: New consumer-facing behavior is exposed via `values.yaml` as `allowTo[].ips`.
- [x] **Lint & Template**: Plan includes `helm lint` and `helm template` with default, focused test, and example values.
- [x] **Versioning & Compatibility**: Change is backward-compatible and includes a patch version bump.
- [x] **Simplicity & Defaults**: IP support is opt-in and defaults to `443/TCP` only for IP rules.
- [x] **Examples for new abilities**: Plan includes `examples/zero-trust-mesh/ip-egress.yaml`.
- [x] **Example testing and regression**: Plan includes rendering the new example and existing zero-trust-mesh examples.
- [x] **Official documentation before implementation**: Kubernetes NetworkPolicy and Istio ServiceEntry field shapes are checked in official docs.

## Project Structure

### Documentation (this feature)

```text
specs/013-zero-trust-ip-egress/
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
    │   ├── istio-serviceentries.yaml
    │   └── networkpolicy-ip-egress.yaml
    └── tests/
        ├── ip-egress-values.yaml
        └── render-ip-egress.sh

examples/
└── zero-trust-mesh/
    └── ip-egress.yaml
```

**Structure Decision**: Keep IP egress in a dedicated NetworkPolicy template because it is an egress rule for source workloads, while existing `networkpolicy-flows.yaml` handles service ingress allows. Extend the existing ServiceEntry template so DNS hosts and direct IP entries remain in the same Istio registry-rendering location.

## Phase 0: Research Plan

- Confirm Istio ServiceEntry supports `addresses` for VIP/IP matching and `resolution: NONE` for direct IP connections.
- Confirm Kubernetes NetworkPolicy `ipBlock.cidr` supports CIDR egress destinations.
- Confirm existing chart values documentation and test conventions.

## Phase 1: Design & Contracts Plan

- Document `IpEgressRule`, `IpPort`, and `NormalizedIpBlock` in `data-model.md`.
- Define render contract for IP ServiceEntry, IP egress NetworkPolicy, default port, and regression cases in `contracts/render-contract.md`.
- Provide quickstart commands for focused render assertions, chart linting, default rendering, and example rendering.
- Re-check constitution compliance after artifact generation.

## Post-Design Constitution Check

- [x] No constitution violations remain in the planned implementation.
- [x] Chart version bump is included in tasks.
- [x] New public value is paired with README/values documentation and a runnable example.

## Complexity Tracking

No constitution violations requiring justification.
