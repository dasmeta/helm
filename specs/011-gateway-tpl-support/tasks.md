# Tasks: Gateway API tpl Support

**Input**: Design documents from `/specs/011-gateway-tpl-support/`  
**Prerequisites**: `plan.md` (required), `spec.md` (required for user stories), `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: This feature explicitly requires tests/checks. Include `helm lint` plus `helm template` for updated and regression examples.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Capture expected object fields, baseline current rendering, and prepare spec-linked implementation context.

- [x] T001 Review and confirm target field contracts in `specs/011-gateway-tpl-support/contracts/render-contract.md` against `charts/gateway-api/templates/httproute.yaml`, `charts/gateway-api/templates/istio/authorizationpolicy.yaml`, and `charts/gateway-api/templates/istio/envoyfilter.yaml`
- [x] T002 Run baseline render capture for `examples/gateway-api/with-istio-envoyfilter-direct-response.yaml` and record notes in `specs/011-gateway-tpl-support/research.md`
- [x] T003 [P] Validate official field shape expectations for HTTPRoute hostnames, AuthorizationPolicy rules, and EnvoyFilter configPatches; document references in `specs/011-gateway-tpl-support/research.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Ensure shared template behavior and examples command conventions are aligned before story implementation.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T004 Standardize serialized tpl rendering style in `charts/gateway-api/templates/httproute.yaml`, `charts/gateway-api/templates/istio/authorizationpolicy.yaml`, and `charts/gateway-api/templates/istio/envoyfilter.yaml` using `tpl (toYaml ...)` with correct indentation
- [x] T005 [P] Ensure example command-header comments are present and accurate in `examples/gateway-api/with-istio-envoyfilter-direct-response.yaml` and `examples/base/with-istio-gateway-api-http-route-only.yaml`
- [x] T006 [P] Align feature docs language for templating capability in `charts/gateway-api/README.md` and `specs/011-gateway-tpl-support/quickstart.md`

**Checkpoint**: Shared templating and documentation foundations are ready for story-by-story delivery.

---

## Phase 3: User Story 1 - Render templated route and policy values (Priority: P1) 🎯 MVP

**Goal**: Support templated values for HTTPRoute hostnames, AuthorizationPolicy rules, and EnvoyFilter config patches.

**Independent Test**: `helm template gateway ./charts/gateway-api -f ./examples/gateway-api/with-istio-envoyfilter-direct-response.yaml` renders resolved values in all three target sections.

### Tests & Checks for User Story 1

- [x] T007 [P] [US1] Run `helm lint` for `./charts/gateway-api` and address template or values issues in `charts/gateway-api/`
- [x] T008 [US1] Run template verification for `examples/gateway-api/with-istio-envoyfilter-direct-response.yaml` and record expected resolved snippets in `specs/011-gateway-tpl-support/quickstart.md`

### Implementation for User Story 1

- [x] T009 [US1] Implement/confirm tpl rendering for HTTPRoute hostnames in `charts/gateway-api/templates/httproute.yaml`
- [x] T010 [US1] Implement/confirm tpl rendering for AuthorizationPolicy rules in `charts/gateway-api/templates/istio/authorizationpolicy.yaml`
- [x] T011 [US1] Implement/confirm tpl rendering for EnvoyFilter config patches in `charts/gateway-api/templates/istio/envoyfilter.yaml`
- [x] T012 [P] [US1] Update templated example values in `examples/gateway-api/with-istio-envoyfilter-direct-response.yaml` to demonstrate all three supported tpl fields
- [x] T013 [US1] Update user guidance for supported tpl fields in `charts/gateway-api/README.md`

**Checkpoint**: User Story 1 manifests render with resolved templated values for all required fields.

---

## Phase 4: User Story 2 - Preserve existing static behavior (Priority: P2)

**Goal**: Keep existing static-value behavior unchanged while tpl support is added.

**Independent Test**: Existing static example renders successfully with no regressions in affected objects.

### Tests & Checks for User Story 2

- [x] T014 [US2] Run regression render for `examples/base/with-istio-gateway-api-http-route-only.yaml` against `./charts/base`
- [x] T015 [P] [US2] Run additional regression render for `examples/gateway-api/minimal.yaml` against `./charts/gateway-api`

### Implementation for User Story 2

- [x] T016 [US2] Adjust template guards/default handling for static values in `charts/gateway-api/templates/httproute.yaml` if regressions are found
- [x] T017 [US2] Adjust template guards/default handling for static values in `charts/gateway-api/templates/istio/authorizationpolicy.yaml` and `charts/gateway-api/templates/istio/envoyfilter.yaml` if regressions are found
- [x] T018 [US2] Update regression verification notes in `specs/011-gateway-tpl-support/quickstart.md`

**Checkpoint**: Static examples continue to render successfully after tpl support changes.

---

## Phase 5: User Story 3 - Discover and adopt new capability (Priority: P3)

**Goal**: Provide clear examples/docs so users can apply tpl support without trial-and-error.

**Independent Test**: A reviewer follows docs/examples and renders expected manifests within one pass.

### Tests & Checks for User Story 3

- [x] T019 [US3] Validate documented commands in `charts/gateway-api/README.md` and `examples/gateway-api/with-istio-envoyfilter-direct-response.yaml` execute successfully as written

### Implementation for User Story 3

- [x] T020 [US3] Expand `charts/gateway-api/README.md` with explicit tpl-support notes and field-specific examples for hostnames, rules, and config patches
- [x] T021 [P] [US3] Update `specs/011-gateway-tpl-support/quickstart.md` with a concise “how to verify resolved output” checklist
- [x] T022 [US3] Ensure example commentary in `examples/gateway-api/with-istio-envoyfilter-direct-response.yaml` clearly identifies tpl-driven values

**Checkpoint**: Documentation and examples are clear enough for first-attempt success.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final compliance, versioning, and release-readiness checks across all stories.

- [x] T023 [P] Run final `helm lint ./charts/gateway-api` and final template renders for updated/regression examples from `specs/011-gateway-tpl-support/quickstart.md`
- [x] T024 Update `charts/gateway-api/Chart.yaml` version (semver patch or higher) for chart template/doc/example behavior change
- [x] T025 Update `charts/base/Chart.yaml` version (semver patch or higher) if base chart/example-linked behavior changed in this feature
- [x] T026 Re-run all quickstart verification commands from `specs/011-gateway-tpl-support/quickstart.md` and capture final pass notes in `specs/011-gateway-tpl-support/research.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies; starts immediately.
- **Phase 2 (Foundational)**: Depends on Phase 1; blocks all user stories.
- **Phase 3 (US1)**: Depends on Phase 2; MVP delivery phase.
- **Phase 4 (US2)**: Depends on Phase 3 completion to validate non-regression of final US1 behavior.
- **Phase 5 (US3)**: Depends on stable US1/US2 outputs for accurate documentation.
- **Phase 6 (Polish)**: Depends on all user story phases.

### User Story Dependencies

- **US1 (P1)**: No dependency on other stories after Foundational.
- **US2 (P2)**: Depends on US1 implementation presence to validate static non-regression against changed templates.
- **US3 (P3)**: Depends on US1/US2 finalized behavior for accurate docs/examples.

### Within Each User Story

- Run checks first, then apply/adjust implementation, then re-run verification.
- Keep template edits scoped to their target files to minimize cross-story coupling.

### Parallel Opportunities

- `T003`, `T005`, `T006` can run in parallel in early phases.
- `T007` and `T012` can run in parallel after template edits are drafted.
- `T014` and `T015` can run in parallel for regression coverage.
- `T021` can run in parallel with `T020` once behavior is finalized.
- `T023` can run in parallel with release-note preparation while waiting for version bumps.

---

## Parallel Example: User Story 1

```bash
# Parallel checks and example prep for US1:
Task: "T007 [US1] Run helm lint for ./charts/gateway-api"
Task: "T012 [US1] Update templated example values in examples/gateway-api/with-istio-envoyfilter-direct-response.yaml"

# Then sequential template implementation:
Task: "T009 [US1] Update httproute tpl rendering"
Task: "T010 [US1] Update authorizationpolicy tpl rendering"
Task: "T011 [US1] Update envoyfilter tpl rendering"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete US1 (`T007`-`T013`).
3. Validate the US1 independent test command.
4. Demo/verify resolved output snippets.

### Incremental Delivery

1. Deliver US1 (tpl capability).
2. Deliver US2 (non-regression on static values).
3. Deliver US3 (docs/examples adoption clarity).
4. Run final polish checks and version bumps.

### Parallel Team Strategy

1. One engineer handles template logic (`T009`-`T011`).
2. One engineer handles examples/docs (`T012`, `T013`, `T020`, `T022`).
3. One engineer handles verification passes (`T007`, `T014`, `T015`, `T023`, `T026`).

---

## Notes

- All tasks use explicit file paths and execution order.
- Version bump tasks are explicitly included for chart compliance.
- Keep commits scoped by phase or by completed user-story checkpoint.
