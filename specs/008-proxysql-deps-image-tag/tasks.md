# Tasks: ProxySQL Chart — Dependencies and Image Tag Update

**Input**: Design documents from `specs/008-proxysql-deps-image-tag/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: No test tasks (not requested in spec).

**Organization**: Tasks grouped by user story for independent implementation and validation.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[US1/US2]**: User story (P1 = dependencies, P2 = image tag)
- Include exact file paths in descriptions

## Path Conventions

- **Charts**: `charts/proxysql/` at repository root
- **Specs**: `specs/008-proxysql-deps-image-tag/`
- Run all `helm` commands from repository root (e.g. `/Users/tmuradyan/projects/dasmeta/helm` or `dasmeta/helm`)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm environment and branch before editing charts

- [x] T001 Verify current branch is `008-proxysql-deps-image-tag` and working directory is repo root (e.g. `git branch --show-current` and `pwd`)
- [x] T002 Verify Helm 3 is available (run `helm version` and confirm v3.x)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: No shared infrastructure required for this feature.

**No foundational tasks** — chart edits only; proceed to User Story phases.

---

## Phase 3: User Story 1 — ProxySQL chart uses updated base and base-cronjob dependencies (Priority: P1) — MVP

**Goal**: Proxysql chart declares updated base and base-cronjob dependency versions (latest from Helm repo at implementation time); dependency update runs; chart remains valid.

**Independent Test**: Inspect `charts/proxysql/Chart.yaml` for updated base and base-cronjob versions; run `helm dependency update charts/proxysql` and `helm template test-proxysql charts/proxysql` — both succeed.

### Implementation for User Story 1

- [x] T003 [US1] Resolve latest base and base-cronjob versions (e.g. from this repo’s `charts/base/Chart.yaml` and `charts/base-cronjob/Chart.yaml` version fields, or from Helm repo index per research.md) and note them for T004
- [x] T004 [US1] Update base and base-cronjob dependency versions in charts/proxysql/Chart.yaml (dependencies section) to the versions resolved in T003
- [x] T005 [US1] Run `helm dependency update charts/proxysql` from repo root so Chart.lock and charts/proxysql/charts/ reflect the new dependency versions
- [x] T006 [US1] Run `helm lint charts/proxysql` and `helm template test-proxysql charts/proxysql` from repo root; fix any failures

**Checkpoint**: User Story 1 complete — proxysql chart has updated dependencies and passes lint/template.

---

## Phase 4: User Story 2 — ProxySQL default image tag matches app version 3.0.6 (Priority: P2)

**Goal**: Default image tag in values is 3.0.6 so it matches Chart.yaml appVersion (constitution: app version and image tag sync).

**Independent Test**: Inspect `charts/proxysql/values.yaml` for `proxysql.image.tag: 3.0.6`; run `helm template test-proxysql charts/proxysql` and confirm rendered image tag is 3.0.6.

### Implementation for User Story 2

- [x] T007 [P] [US2] Set `proxysql.image.tag` to `3.0.6` in charts/proxysql/values.yaml (replace current value, e.g. 3.0.5)
- [x] T008 [US2] Run `helm lint charts/proxysql` and `helm template test-proxysql charts/proxysql` from repo root; if examples exist under examples/proxysql/, run template with one to check regression

**Checkpoint**: User Stories 1 and 2 complete — dependencies updated and default image tag 3.0.6.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Version bump (constitution), final validation, and success-criteria check.

- [x] T009 Bump proxysql chart version (PATCH) in charts/proxysql/Chart.yaml (e.g. 1.2.3 → 1.2.4) after all edits; per constitution, version bump required for any chart change
- [x] T010 Re-run `helm lint charts/proxysql` and `helm template test-proxysql charts/proxysql` from repo root; all must succeed
- [x] T011 Run quickstart.md validation: follow steps in specs/008-proxysql-deps-image-tag/quickstart.md from repo root and confirm the chart updates and validates as described
- [x] T012 Confirm success criteria: SC-001 (updated base and base-cronjob deps + dependency update), SC-002 (proxysql.image.tag 3.0.6), SC-003 (lint/template pass), SC-004 (no regressions)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — run first.
- **Phase 2 (Foundational)**: None for this feature.
- **Phase 3 (US1)**: Depends on Phase 1 — run T003–T006 in order.
- **Phase 4 (US2)**: Depends on Phase 1 only — T007 can run in parallel with Phase 3 or after; T008 after T007.
- **Phase 5 (Polish)**: Depends on Phase 3 and Phase 4 — run T009–T012 last.

### User Story Dependencies

- **User Story 1 (P1)**: T003 → T004 → T005 → T006 (resolve versions, update Chart.yaml, dependency update, validate).
- **User Story 2 (P2)**: T007 → T008 (set image tag, validate). T007 [P] is parallelizable with other work on different files.
- Version bump (T009) is done once after both US1 and US2 changes.

### Parallel Opportunities

- After Phase 1, T007 [US2] can be done in parallel with T003–T006 (different file: values.yaml vs Chart.yaml).
- T009 must run after all chart edits (Chart.yaml and values.yaml).

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: T001–T002.
2. Complete Phase 3: T003–T006 (resolve versions, update deps, dependency update, validate).
3. **STOP and VALIDATE**: Chart has updated dependencies and passes lint/template.
4. Optionally proceed to US2 and Polish, or open PR with deps-only.

### Full Feature

1. Phase 1 → Phase 3 (US1) → Phase 4 (US2) → Phase 5 (version bump T009, validate T010–T012).

### Version Bump (Constitution)

- **Proxysql chart**: T009 is the explicit version-bump task (PATCH). Must be executed after all changes to the chart; implement is not complete until T009 is done.

---

## Notes

- [P] tasks = different files, no cross-task dependencies.
- [US1]/[US2] map tasks to spec user stories for traceability.
- Dependency versions: use latest from Helm repo at implementation time (research.md: this repo’s charts/base and charts/base-cronjob version fields, or Helm repo index).
- Constitution: version bump on any chart change (T009); lint and template required (T006, T008, T010); app version and image tag sync (T007).
