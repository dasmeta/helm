# Tasks: Zero Trust Mesh Empty Default Allow Rules

**Input**: Design documents from `/specs/015-zero-trust-mesh/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/render-contract.md`, `quickstart.md`

**Tests**: This feature requires Helm lint/template checks plus focused render assertions for standalone zero-trust-mesh and base.

**Organization**: Tasks are grouped by user story to keep standalone chart behavior and base chart behavior independently verifiable.

## Phase 1: Setup

**Purpose**: Capture the unsafe default behavior before changing values.

- [x] T001 Render default `charts/zero-trust-mesh` and confirm sample `backend`, `api.stripe.com`, and `192.0.2.10` resources are emitted
- [x] T002 Add `charts/zero-trust-mesh/tests/render-default-empty.sh` to assert default sample allow resources are absent
- [x] T003 Run `charts/zero-trust-mesh/tests/render-default-empty.sh ./charts/zero-trust-mesh` before implementation and confirm it fails on sample resources
- [x] T004 Add `charts/base/tests/render-zero-trust-default-empty.sh` to assert enabling base zeroTrustMesh does not render sample allow resources
- [x] T005 Run `charts/base/tests/render-zero-trust-default-empty.sh ./charts/base` before implementation and confirm it fails on sample resources

---

## Phase 2: User Story 1 - Default zero-trust-mesh renders no sample allow rules (Priority: P1)

**Goal**: Make sample allow rules documentation-only.

**Independent Test**: `charts/zero-trust-mesh/tests/render-default-empty.sh ./charts/zero-trust-mesh`

- [x] T006 Update `charts/zero-trust-mesh/values.yaml` so active `allowTo` defaults to `[]`
- [x] T007 Preserve service, host, and IP `allowTo` examples as commented documentation
- [x] T008 Re-run the focused zero-trust-mesh render assertion and confirm it exits `0`

**Checkpoint**: Standalone chart defaults do not render sample allow resources.

---

## Phase 3: User Story 2 - Base chart enabling zeroTrustMesh does not inherit sample allow rules (Priority: P1)

**Goal**: Protect base consumers from packaged subchart sample defaults.

**Independent Test**: `charts/base/tests/render-zero-trust-default-empty.sh ./charts/base`

- [x] T009 Add `zeroTrustMesh.allowTo: []` to `charts/base/values.yaml`
- [x] T010 Re-run the focused base render assertion and confirm it exits `0`
- [x] T011 Render `charts/base` with an explicit zeroTrustMesh example values file and confirm explicit allow rules still render

**Checkpoint**: Base can enable zeroTrustMesh without implicit sample allow rules, while explicit allow rules still work.

---

## Phase 4: User Story 3 - Consumers can still discover the allowTo shape (Priority: P2)

**Goal**: Keep the values contract discoverable after emptying defaults.

- [x] T012 Update `charts/zero-trust-mesh/README.md` to document `allowTo` default as `[]`
- [x] T013 Confirm `charts/zero-trust-mesh/values.yaml` keeps commented service, host, and IP examples

**Checkpoint**: Empty defaults are documented and examples remain available.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final compliance, versioning, and release readiness.

- [x] T014 Bump `charts/zero-trust-mesh/Chart.yaml` patch version
- [x] T015 Bump `charts/base/Chart.yaml` patch version
- [x] T016 Run `helm lint ./charts/zero-trust-mesh`
- [x] T017 Run `helm lint ./charts/base`
- [x] T018 Run `helm template ztm-default ./charts/zero-trust-mesh -n default`
- [x] T019 Run `helm template base-enabled ./charts/base -n default --set zeroTrustMesh.enabled=true`
- [x] T020 Run explicit allowTo example renders
- [x] T021 Add Speckit artifacts under `specs/015-zero-trust-mesh/`

## Dependencies & Execution Order

- Phase 1 precedes values changes because the render assertions must prove the old behavior.
- Phase 2 can proceed once the standalone assertion exists.
- Phase 3 depends on understanding the base dependency alias and packaged chart behavior.
- Phase 4 depends on the final values shape.
- Phase 5 depends on all behavior changes.

## Parallel Opportunities

- Standalone and base render assertions can run in parallel.
- Lint checks can run in parallel after values updates.
- Speckit documentation can be reviewed independently of chart code after behavior is fixed.

## Implementation Strategy

1. Prove sample resources render by default.
2. Add focused assertions for standalone and base charts.
3. Empty standalone `allowTo` default and add base parent override.
4. Preserve examples as comments/docs.
5. Run lint, default renders, and explicit-value render checks.
