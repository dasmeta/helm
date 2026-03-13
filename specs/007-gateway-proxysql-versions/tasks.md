# Tasks: Base Chart Gateway-API and ProxySQL Version Updates

**Input**: Design documents from `specs/007-gateway-proxysql-versions/`  
**Prerequisites**: plan.md, spec.md, quickstart.md

**Tests**: No test tasks (not requested in spec).

**Organization**: Tasks grouped by user story for independent implementation and validation.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[US1/US2]**: User story (P1 = base chart, P2 = proxysql chart)
- Include exact file paths in descriptions

## Path Conventions

- **Charts**: `charts/base/`, `charts/proxysql/` at repository root
- **Specs**: `specs/007-gateway-proxysql-versions/`
- Run all `helm` commands from repository root (e.g. `/Users/tmuradyan/projects/dasmeta/helm` or `dasmeta/helm`)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm environment and branch before editing charts

- [x] T001 Verify current branch is `007-gateway-proxysql-versions` and working directory is repo root (e.g. `git branch --show-current` and `pwd`)
- [x] T002 Verify Helm 3 is available (run `helm version` and confirm v3.x)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: No shared infrastructure required for this feature.

**No foundational tasks** — chart edits only; proceed to User Story phases.

---

## Phase 3: User Story 1 — Base chart uses updated Gateway API dependency (Priority: P1) — MVP

**Goal**: Base chart declares gateway-api at 0.1.3; dependency metadata (Chart.lock and charts/base/charts) updated; chart version bumped; lint and template pass.

**Independent Test**: Inspect `charts/base/Chart.yaml` for gateway-api version 0.1.3; confirm `charts/base/Chart.lock` and `charts/base/charts/` reflect 0.1.3; run `helm lint charts/base` and `helm template test-base charts/base` — both succeed.

### Implementation for User Story 1

- [x] T003 [US1] Set gateway-api dependency version to 0.1.3 in charts/base/Chart.yaml (dependencies section; leave name, repository, alias, condition unchanged)
- [x] T004 [US1] Run `helm dependency update charts/base` from repo root so Chart.lock and charts/base/charts/ reflect gateway-api 0.1.3
- [x] T005 [US1] Bump base chart version (PATCH) in charts/base/Chart.yaml (e.g. 0.3.23 → 0.3.24)
- [x] T006 [US1] Run `helm lint charts/base` and `helm template test-base charts/base` from repo root; fix any failures
- [x] T007 [US1] Commit base chart changes: `git add charts/base/Chart.yaml charts/base/Chart.lock charts/base/charts/` and `git commit -m "chore(base): bump gateway-api dependency to 0.1.3 and chart version"`

**Checkpoint**: User Story 1 complete — base chart uses gateway-api 0.1.3 and passes lint/template.

---

## Phase 4: User Story 2 — ProxySQL chart advertises app version 3.0.6 (Priority: P2)

**Goal**: ProxySQL chart declares appVersion 3.0.6; chart version bumped (PATCH); lint and template pass.

**Independent Test**: Inspect `charts/proxysql/Chart.yaml` for `appVersion: "3.0.6"`; run `helm lint charts/proxysql` and `helm template test-proxysql charts/proxysql` — both succeed.

### Implementation for User Story 2

- [x] T008 [P] [US2] Set appVersion to "3.0.6" in charts/proxysql/Chart.yaml (replace "3.0.5")
- [x] T009 [US2] Bump proxysql chart version (PATCH) in charts/proxysql/Chart.yaml (e.g. 1.2.2 → 1.2.3)
- [x] T010 [US2] Run `helm lint charts/proxysql` and `helm template test-proxysql charts/proxysql` from repo root; if examples exist under examples/proxysql/, run template with one to check regression
- [x] T011 [US2] Commit proxysql chart changes: `git add charts/proxysql/Chart.yaml` and `git commit -m "chore(proxysql): set appVersion to 3.0.6 and bump chart version"`

**Checkpoint**: User Stories 1 and 2 complete — both charts updated and valid.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and success-criteria check (constitution: lint/template; spec SC-001–SC-004).

- [x] T012 Re-run `helm lint charts/base charts/proxysql` and `helm template test-base charts/base` and `helm template test-proxysql charts/proxysql` from repo root; all must succeed
- [x] T013 Run quickstart.md validation: follow steps in specs/007-gateway-proxysql-versions/quickstart.md from repo root and confirm both charts update and validate as described
- [x] T014 Confirm success criteria: SC-001 (base chart gateway-api 0.1.3 + dep update), SC-002 (proxysql appVersion 3.0.6), SC-003 (helm dependency update charts/base succeeded), SC-004 (no regressions — lint/template pass for both charts)
- [ ] T015 (optional) If upstream release notes for gateway-api 0.1.3 or ProxySQL 3.0.6 document breaking changes, add a brief note to implementation summary or the relevant chart README (per spec edge case).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — run first.
- **Phase 2 (Foundational)**: None for this feature.
- **Phase 3 (US1)**: Depends on Phase 1 — run T003–T007 in order.
- **Phase 4 (US2)**: Depends on Phase 1 only — can run in parallel with Phase 3 or after (T008–T011 in order).
- **Phase 5 (Polish)**: Depends on Phase 3 and Phase 4 — run T012–T014 last.

### User Story Dependencies

- **User Story 1 (P1)**: No dependency on US2. Complete T003–T007.
- **User Story 2 (P2)**: No dependency on US1. Complete T008–T011.
- US1 and US2 can be implemented in parallel by different implementers after Setup.

### Within Each User Story

- US1: T003 → T004 → T005 → T006 → T007 (edit Chart.yaml, dep update, version bump, validate, commit).
- US2: T008 → T009 → T010 → T011 (edit appVersion, version bump, validate, commit).

### Parallel Opportunities

- After Phase 1, **Phase 3 (US1)** and **Phase 4 (US2)** can be executed in parallel (different charts).
- T008 [P] is marked parallelizable within the overall task list (different file from US1).

---

## Parallel Example: User Story 2 (while US1 in progress)

```bash
# If implementing US2 while US1 is done (or in parallel):
# T008: Set appVersion in charts/proxysql/Chart.yaml
# T009: Bump version in charts/proxysql/Chart.yaml
# T010: helm lint / helm template for proxysql
# T011: Commit proxysql changes
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: T001–T002.
2. Complete Phase 3: T003–T007 (base chart gateway-api 0.1.3 + version bump + validate + commit).
3. **STOP and VALIDATE**: Run `helm lint charts/base` and `helm template test-base charts/base`; confirm Chart.lock and charts/base/charts show 0.1.3.
4. Optionally deploy or open PR with base chart only.

### Incremental Delivery

1. Phase 1 → Phase 3 (US1) → validate base chart (MVP).
2. Phase 4 (US2) → validate proxysql chart.
3. Phase 5 → final lint/template and quickstart → confirm SC-001–SC-004.

### Version Bump (Constitution)

- **Base chart**: T005 is the explicit version-bump task for charts/base (PATCH).
- **ProxySQL chart**: T009 is the explicit version-bump task for charts/proxysql (PATCH).
- Both must be completed before considering the feature implementation complete.

---

## Notes

- [P] tasks = different files, no cross-task dependencies.
- [US1]/[US2] map tasks to spec user stories for traceability.
- Each user story is independently testable via lint/template and metadata inspection.
- Commit after each story (T007, T011) or per task as preferred.
- Constitution: version bump on any chart change (T005, T009); lint and template required (T006, T010, T012).
- Edge case (spec): If release notes for gateway-api 0.1.3 or ProxySQL 3.0.6 mention breaking changes, document or call out per T015 (optional).
