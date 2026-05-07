# Tasks: Zero Trust Target Pod Labels

**Input**: Design documents from `/specs/012-zero-trust-target-pod-labels/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/render-contract.md`, `quickstart.md`

**Tests**: This feature requires Helm lint/template checks plus a focused render assertion.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm selector contracts and capture the failing behavior.

- [x] T001 Review Kubernetes NetworkPolicy and Istio AuthorizationPolicy selector field shapes; document findings in `specs/012-zero-trust-target-pod-labels/research.md`
- [x] T002 Add `charts/zero-trust-mesh/tests/target-pod-labels-values.yaml` with an `allowTo` service rule using `targetPodLabels`
- [x] T003 Add `charts/zero-trust-mesh/tests/render-target-pod-labels.sh` to assert custom target labels render and the old target selector is replaced for that service
- [x] T004 Run `./charts/zero-trust-mesh/tests/render-target-pod-labels.sh ./charts/zero-trust-mesh` before implementation and confirm it fails because custom labels are absent

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Centralize target selector rendering before applying it to policy templates.

- [x] T005 Add `ztm.targetPodLabels` helper in `charts/zero-trust-mesh/templates/_helpers.tpl`
- [x] T006 Ensure helper renders `.targetPodLabels` when present and falls back to `app.kubernetes.io/name: .service` otherwise

**Checkpoint**: Shared selector helper is available for both policy templates.

---

## Phase 3: User Story 1 - Select target workloads by custom pod labels (Priority: P1) 🎯 MVP

**Goal**: Render custom target labels into both generated target policy selectors.

**Independent Test**: `./charts/zero-trust-mesh/tests/render-target-pod-labels.sh ./charts/zero-trust-mesh`

- [x] T007 [US1] Update `charts/zero-trust-mesh/templates/networkpolicy-flows.yaml` to use `ztm.targetPodLabels` for `spec.podSelector.matchLabels`
- [x] T008 [US1] Update `charts/zero-trust-mesh/templates/istio-authorizations.yaml` to use `ztm.targetPodLabels` for `spec.selector.matchLabels`
- [x] T009 [US1] Re-run the focused render assertion and confirm it exits `0`

**Checkpoint**: Custom target labels render into both policy resources.

---

## Phase 4: User Story 2 - Preserve default selector behavior (Priority: P2)

**Goal**: Keep old behavior when consumers omit the new value.

**Independent Test**: `helm template ztm ./charts/zero-trust-mesh -n default` includes `app.kubernetes.io/name: backend`.

- [x] T010 [US2] Render default chart values and confirm fallback target selectors remain unchanged
- [x] T011 [US2] Ensure host-only `allowTo` entries still render ServiceEntry resources and do not use target pod selectors

**Checkpoint**: Existing consumers retain previous selector behavior.

---

## Phase 5: User Story 3 - Discover the new selector option (Priority: P3)

**Goal**: Document and demonstrate `targetPodLabels`.

**Independent Test**: A user can render the repo-level example command successfully.

- [x] T012 [US3] Document `targetPodLabels` in `charts/zero-trust-mesh/values.yaml`
- [x] T013 [US3] Document `targetPodLabels` in `charts/zero-trust-mesh/README.md`
- [x] T014 [US3] Add `examples/zero-trust-mesh/target-pod-labels.yaml` with a top-line runnable Helm command
- [x] T015 [US3] Render the new example with `helm template ztm-target-pod-labels ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/target-pod-labels.yaml`

**Checkpoint**: Documentation and example values show the new selector option.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final compliance, versioning, and release readiness.

- [x] T016 Add Speckit artifacts under `specs/012-zero-trust-target-pod-labels/`
- [x] T017 Bump `charts/zero-trust-mesh/Chart.yaml` patch version
- [x] T018 Run `helm lint ./charts/zero-trust-mesh`
- [x] T019 Run `helm template ztm ./charts/zero-trust-mesh -n default`
- [x] T020 Run existing example regressions from `specs/012-zero-trust-target-pod-labels/quickstart.md`
- [x] T021 Run `git diff --check`

## Dependencies & Execution Order

- Phase 1 precedes implementation because the render assertion must fail first.
- Phase 2 precedes US1 because both policy templates depend on the shared helper.
- US2 depends on US1 implementation to validate final fallback behavior.
- US3 depends on finalized values shape and render output.
- Phase 6 depends on all stories.

## Parallel Opportunities

- Documentation updates (`T012`, `T013`) can run after values shape is final.
- Example rendering and default rendering can run in parallel during verification.
- Speckit documentation can be reviewed independently of template code after behavior is finalized.

## Implementation Strategy

1. Prove current behavior fails the new target-label assertion.
2. Add a shared helper and wire both policy templates to it.
3. Confirm custom selector rendering.
4. Confirm default fallback rendering.
5. Add docs/example/version bump and run full Helm validation.
