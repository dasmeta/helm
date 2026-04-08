# Tasks: Gateway Direct Response Configuration

**Input**: Design documents from `/specs/010-gateway-direct-response/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/direct-response-values-contract.md`

**Tests**: Validation tasks use `helm lint` and `helm template` per constitution requirements.

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: `US1`, `US2`, `US3`
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Align chart docs/examples and implementation workspace for the feature.

- [x] T001 [P] [US1] Review current gateway chart inputs in `charts/gateway-api/values.yaml` and `charts/gateway-api/README.md` against `specs/010-gateway-direct-response/contracts/direct-response-values-contract.md`.
- [x] T002 [P] [US1] Review existing gateway template structure in `charts/gateway-api/templates/` to select insertion point for EnvoyFilter rendering without altering existing 403 AuthorizationPolicy templates.
- [x] T003 [P] [US1] Confirm example files affected in `examples/gateway-api/` and prepare target direct-response example file with top runnable command comment.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define shared values contract and rendering scaffolding required by all user stories.

**⚠️ CRITICAL**: No user story implementation should begin before this phase is complete.

- [x] T004 [US1] Add/extend direct-response value schema in `charts/gateway-api/values.yaml` with status, optional body, match conditions, and enable/disable semantics.
- [x] T005 [US1] Document public values in `charts/gateway-api/README.md` (Key/Description/Default) and keep table synchronized with `values.yaml`.
- [x] T006 [US1] Add or update EnvoyFilter rendering template in `charts/gateway-api/templates/` to support direct responses from chart values.
- [x] T007 [US2] Add validation guards in chart templates/helpers under `charts/gateway-api/templates/` for status range `200-599` and required match semantics for active rules.

**Checkpoint**: Foundation complete; user stories can be implemented/verified independently.

---

## Phase 3: User Story 1 - Configure Custom Direct Responses (Priority: P1) 🎯 MVP

**Goal**: Enable non-403 direct responses with configurable status/body, defaulting body to empty string.

**Independent Test**: Render chart with direct-response example and verify EnvoyFilter output has configured non-403 status and expected body handling.

### Implementation for User Story 1

- [x] T008 [US1] Implement status/body mapping into rendered EnvoyFilter in `charts/gateway-api/templates/` for configured rules.
- [x] T009 [US1] Implement default body behavior (`""` when omitted) in `charts/gateway-api/templates/`.
- [x] T010 [US1] Add/update example values for direct-response behavior in `examples/gateway-api/` including explicit status/body and omitted-body cases.
- [x] T011 [US1] Update `charts/gateway-api/README.md` usage section with direct-response examples and expected behavior.

**Checkpoint**: US1 delivers working non-403 direct-response support and is independently verifiable.

---

## Phase 4: User Story 2 - Preserve Existing 403 Authorization Behavior (Priority: P2)

**Goal**: Ensure existing AuthorizationPolicy-based 403 behavior is unchanged and authoritative on overlap.

**Independent Test**: Render chart with prior 403 configuration and confirm no change; render overlap configuration and confirm 403 precedence remains with AuthorizationPolicy.

### Implementation for User Story 2

- [x] T012 [US2] Ensure direct-response rendering path does not modify existing 403 AuthorizationPolicy templates in `charts/gateway-api/templates/`.
- [x] T013 [US2] Implement/confirm precedence logic so 403 AuthorizationPolicy behavior remains authoritative when overlap can occur.
- [x] T014 [US2] Update contract notes in `specs/010-gateway-direct-response/contracts/direct-response-values-contract.md` if template behavior naming/fields require clarification after implementation.
- [x] T015 [US2] Add or update example demonstrating coexistence with existing 403 flow in `examples/gateway-api/`.

**Checkpoint**: US2 confirms backward compatibility of existing 403 behavior.

---

## Phase 5: User Story 3 - Apply Feature Selectively (Priority: P3)

**Goal**: Keep feature opt-in so deployments without new config remain unchanged.

**Independent Test**: Render with default values and confirm no new direct-response resources/behavior are introduced.

### Implementation for User Story 3

- [x] T016 [US3] Ensure direct-response templates are conditionally rendered only when explicitly enabled/configured in `charts/gateway-api/templates/`.
- [x] T017 [US3] Validate defaults in `charts/gateway-api/values.yaml` keep direct-response disabled/unconfigured.
- [x] T018 [US3] Add default/no-config behavior note in `charts/gateway-api/README.md`.

**Checkpoint**: US3 confirms safe incremental adoption with unchanged default behavior.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Constitution-required validation, docs alignment, and release readiness.

- [x] T019 [P] Validate chart syntax and rendering defaults: run `helm lint ./charts/gateway-api` and `helm template gateway-api ./charts/gateway-api`.
- [x] T020 [P] Validate new/updated direct-response example(s): run `helm template gateway-api ./charts/gateway-api -f ./examples/gateway-api/<direct-response-example>.yaml`.
- [x] T021 [P] Run regression rendering for existing gateway examples in `examples/gateway-api/` (`gateway-api-all-routes.values.yaml`, `infrastructure-parameters.yaml`, `minimal.yaml`, `multiple-httproutes.values.yaml`).
- [x] T022 Verify all modified/new `examples/gateway-api/*.yaml` files include top runnable command comment.
- [x] T023 Check official Istio/EnvoyFilter docs for any fields used in `charts/gateway-api/templates/` and adjust manifests if required.
- [x] T024 Ensure `charts/gateway-api/README.md` values table remains synchronized with `charts/gateway-api/values.yaml` after final edits.
- [x] T025 Run the feature quickstart verification steps in `specs/010-gateway-direct-response/quickstart.md`.
- [x] T026 Update `charts/gateway-api/Chart.yaml` with at least a PATCH `version` bump (constitution-required for chart modifications).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies.
- **Phase 2 (Foundational)**: Depends on Phase 1; blocks story work.
- **Phases 3-5 (User Stories)**: Depend on Phase 2 completion.
- **Phase 6 (Polish)**: Depends on completion of desired user stories.

### User Story Dependencies

- **US1 (P1)**: Starts after Foundational; no dependency on US2/US3.
- **US2 (P2)**: Starts after Foundational; integrates with US1 output but remains independently testable.
- **US3 (P3)**: Starts after Foundational; can run after or in parallel with US2 depending on staffing.

### Parallel Opportunities

- T001, T002, T003 can run in parallel.
- T019, T020, T021 can run in parallel.
- Documentation sync tasks (T022, T024) can run in parallel once implementation stabilizes.

---

## Implementation Strategy

### MVP First (US1)

1. Complete Setup + Foundational (T001-T007).
2. Complete US1 tasks (T008-T011).
3. Run focused validation (T019, T020).
4. Demo non-403 direct-response behavior.

### Incremental Delivery

1. Add US2 compatibility protections and overlap behavior (T012-T015).
2. Add US3 opt-in/default safety checks (T016-T018).
3. Complete cross-cutting validation and release steps (T019-T026).

---

## Notes

- Preserve existing 403 AuthorizationPolicy implementation path unchanged.
- Treat status range `200-599` and empty-body default as hard requirements.
- Do not finalize implementation without chart version bump task `T026`.
