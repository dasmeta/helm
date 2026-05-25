# Tasks: Service-Level Deny All

**Input**: Design documents from `/specs/016-service-deny-all/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/render-contract.md`, `quickstart.md`

**Tests**: This feature requires Helm lint/template checks plus a focused render assertion.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Capture the missing service-level deny-all behavior before implementation.

- [x] T001 Review existing namespace baseline deny-all templates and document behavior in `specs/016-service-deny-all/research.md`
- [x] T002 Add `charts/zero-trust-mesh/tests/service-deny-all-values.yaml` with service-level deny-all enabled for one workload
- [x] T003 Add `charts/zero-trust-mesh/tests/render-service-deny-all.sh` to assert workload-scoped NetworkPolicy and AuthorizationPolicy output
- [x] T004 Run `./charts/zero-trust-mesh/tests/render-service-deny-all.sh ./charts/zero-trust-mesh` before implementation and confirm it fails because service-level deny-all resources are absent

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add selector helper behavior needed by both service-level deny-all templates.

- [x] T005 Add a service deny-all pod-label helper in `charts/zero-trust-mesh/templates/_helpers.tpl`
- [x] T006 Ensure the helper defaults to `app.kubernetes.io/name: <workload>`
- [x] T007 Ensure the helper supports `serviceDenyAll.podLabels` override

**Checkpoint**: Shared workload selector behavior is available.

---

## Phase 3: User Story 1 - Isolate one service first (Priority: P1) MVP

**Goal**: Render deny-all resources for one selected workload.

**Independent Test**: `./charts/zero-trust-mesh/tests/render-service-deny-all.sh ./charts/zero-trust-mesh`

- [x] T008 [US1] Add `charts/zero-trust-mesh/templates/networkpolicy-service-deny-all.yaml`
- [x] T009 [US1] Add `charts/zero-trust-mesh/templates/istio-service-deny-all.yaml`
- [x] T010 [US1] Re-run the focused render assertion and confirm it exits `0`

**Checkpoint**: Service-level deny-all is rendered and independently verifiable.

---

## Phase 4: User Story 2 - Preserve existing allow rules (Priority: P2)

**Goal**: Keep existing service, host, and IP allow behavior valid.

**Independent Test**: Existing examples and render checks complete successfully.

- [x] T011 [US2] Render default chart values and confirm service-level deny-all is absent by default
- [x] T012 [US2] Render existing zero-trust-mesh examples from `specs/016-service-deny-all/quickstart.md`
- [x] T013 [US2] Confirm existing default-empty render assertion still exits `0`

**Checkpoint**: Existing consumers are not regressed.

---

## Phase 5: User Story 3 - Discover safe rollout values (Priority: P3)

**Goal**: Document and demonstrate service-level deny-all.

**Independent Test**: A user can render the repo-level example command successfully.

- [x] T014 [US3] Document `serviceDenyAll` in `charts/zero-trust-mesh/values.yaml`
- [x] T015 [US3] Document `serviceDenyAll` in `charts/zero-trust-mesh/README.md`
- [x] T016 [US3] Add `examples/zero-trust-mesh/service-deny-all.yaml` with a top-line runnable Helm command
- [x] T017 [US3] Render the new example with `helm template ztm-service-deny-all ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/service-deny-all.yaml`

**Checkpoint**: Documentation and example values show the new safe rollout option.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final compliance, versioning, and release readiness.

- [x] T018 Add Speckit artifacts under `specs/016-service-deny-all/`
- [x] T019 Bump `charts/zero-trust-mesh/Chart.yaml` patch version
- [x] T020 Run `helm lint ./charts/zero-trust-mesh`
- [x] T021 Run focused render assertion `./charts/zero-trust-mesh/tests/render-service-deny-all.sh ./charts/zero-trust-mesh`
- [x] T022 Run existing example regressions from `specs/016-service-deny-all/quickstart.md`
- [x] T023 Run `git diff --check`

## Dependencies & Execution Order

- Phase 1 precedes implementation because the render assertion must fail first.
- Phase 2 precedes US1 because both templates use the shared selector helper.
- US2 depends on final template output to validate regression behavior.
- US3 depends on finalized values shape and render output.
- Phase 6 depends on all stories.

## Parallel Opportunities

- Documentation updates (`T014`, `T015`) can run after values shape is final.
- Example rendering and default rendering can run in parallel during verification.
- Speckit documentation can be reviewed independently of template code after behavior is finalized.

## Implementation Strategy

1. Prove current behavior fails the new service-level deny-all assertion.
2. Add selector helper and deny-all templates.
3. Confirm focused service-level deny-all rendering.
4. Confirm existing zero-trust-mesh examples still render.
5. Add docs/example/version bump and run Helm validation.
