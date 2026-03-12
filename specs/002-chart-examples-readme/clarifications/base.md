# Clarifications: base chart (dasmeta/base)

**Chart**: `charts/base` (dasmeta/helm base chart)  
**Feature**: 002-chart-examples-readme  
**Date**: 2026-03-09

## Scope (clarified)

- **Top-level chart**: Yes. Base is a direct child of `charts/` and is in scope for FR-001 and FR-002.
- **README standard**: Full (application chart). README MUST describe the chart, install steps (`helm repo add dasmeta`), link to `values.yaml`, and link to `examples/base/`. Base has an optional **gateway-api** dependency (subchart); README MUST mention nested subcharts per FR-001 — already satisfied (Problems section and Gateway API examples).
- **Examples**: Must live in `examples/base/`. At least one example MUST pass `helm template test charts/base -f examples/base/<file>.yaml` and `helm lint charts/base`. Multiple examples (e.g. `basic.yaml`, Gateway API, Ingress) are allowed; each used in docs should validate or be documented if they have prerequisites.

## Decisions

| Topic | Decision |
|-------|----------|
| Example location | Repo-level `examples/base/` only; README points here. |
| Public values | README links to `values.yaml` as source of truth; key values (image, alias, name/version override) are documented in README. |
| Dependency (gateway-api) | Optional; enabled via `gatewayApi.enabled`. When enabled, base depends on gateway-api chart. Listener name truncation fix is in gateway-api (printf "%.63s"); one example (`with-istio-gateway-api-configure-aws-nlb.yaml`) documents that it may require updated gateway-api dependency. |
| Alias / name / version | Base supports use as dependency with optional alias and overrides; README documents this (Problems section). No extra clarification needed for 002. |

## Edge cases (base-specific)

- **Gateway API example**: `examples/base/with-istio-gateway-api-configure-aws-nlb.yaml` depends on gateway-api template fix (listener name ≤63 chars). If base’s dependency is not updated, `helm template` for that file can fail; the example file includes a comment with the requirement and validation command after `helm dependency update`.
- **Many examples**: Base has many example files (basic, ingress, gateway-api, TLS, etc.). All must pass `helm template` with the chart or be explicitly documented as having prerequisites (as for the NLB example).
- **Subcharts**: Base uses gateway-api as optional dependency. Parent README must mention nested subcharts — already done.

## Open questions

None. Base chart scope, README standard, example location, and the single documented exception (NLB example + gateway-api version) are clarified.

## Reference

- Spec: [spec.md](../spec.md)  
- Contract: [contracts/readme-and-examples.md](../contracts/readme-and-examples.md)  
- Chart README: [charts/base/README.md](../../charts/base/README.md)  
- Examples: [examples/base/](../../examples/base/)
