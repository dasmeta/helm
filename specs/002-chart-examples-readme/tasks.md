# Tasks: Chart Examples and README Improvements

**Input**: Design documents from `/specs/002-chart-examples-readme/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Not requested in spec. Validation is via helm lint/template and SC-002/SC-003.

**Organization**: Tasks grouped by user story. Paths: repo root = dasmeta/helm; charts under `charts/<name>/`; examples under `examples/<name>/`. Top-level charts only (19 total).

**Implementation status (2026-03-09)**: T001–T030 completed (T030 version bumps applied by /speckit.implement). T026 (optional new-user test) remains optional.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different charts/files)
- **[Story]**: US1 = Consumer can install from docs; US2 = Consistent documentation quality
- Include exact file paths in descriptions

## Path Conventions

- **Charts**: `charts/<chart-name>/` (top-level only)
- **Examples**: `examples/<chart-name>/` (repo root)
- **Spec/plan**: `specs/002-chart-examples-readme/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Canonical chart list and examples directory structure

- [x] T001 Produce canonical list of 19 top-level charts (from `charts/` direct children) and store or reference in specs/002-chart-examples-readme/ (e.g. in plan.md or a small checklist); ensure alignment with plan.md list.
- [x] T002 [P] Create missing `examples/<chart-name>/` directories for each top-level chart that does not yet have one (so each of the 19 charts has a target dir under examples/).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Know which charts get full vs reduced README standard; baseline validation

**⚠️ CRITICAL**: Per-chart README/example work (Phase 3) depends on this.

- [x] T003 Audit each top-level chart's `Chart.yaml` for `type` (application vs library); document which charts use reduced README standard (library/dependency-only) vs full standard in specs/002-chart-examples-readme/data-model.md or a short audit note.
- [x] T004 Run `helm lint charts/<name>` for each of the 19 charts from repo root; fix any failures or document known exceptions before adding/updating READMEs and examples.
- [x] T005 Confirm contracts/readme-and-examples.md and quickstart.md are present and understood (specs/002-chart-examples-readme/).

**Checkpoint**: Foundation ready—chart list, examples dirs, chart types, and lint baseline known; per-chart work can proceed in any order.

---

## Phase 3: User Story 1 - Consumer can install and configure from docs (Priority: P1) 🎯 MVP

**Goal**: Each top-level chart has a README and (where applicable) at least one working example so a consumer can install/configure from docs only.

**Independent Test**: Pick any chart; follow its README and example; complete helm template or install without external help.

### Implementation for User Story 1 (one task per chart; all [P])

- [x] T006 [P] [US1] Add or update `charts/base/README.md` per FR-001 (full or reduced per type); ensure link to values.yaml and to `examples/base/`. Add or update at least one file in `examples/base/`; validate with `helm template test charts/base -f examples/base/<file>.yaml` and `helm lint charts/base`.
- [x] T007 [P] [US1] Add or update `charts/base-cronjob/README.md` per FR-001; ensure `examples/base-cronjob/` has ≥1 valid example; validate with helm template and helm lint.
- [x] T008 [P] [US1] Add or update `charts/cloudwatch-agent-prometheus/README.md` per FR-001; ensure `examples/cloudwatch-agent-prometheus/` has ≥1 valid example; validate.
- [x] T009 [P] [US1] Add or update `charts/flagger-metrics-and-alerts/README.md` per FR-001; ensure `examples/flagger-metrics-and-alerts/` has ≥1 valid example; validate.
- [x] T010 [P] [US1] Add or update `charts/gateway-api/README.md` per FR-001; ensure `examples/gateway-api/` has ≥1 valid example; validate.
- [x] T011 [P] [US1] Add or update `charts/helm-chart-test/README.md` per FR-001; ensure `examples/helm-chart-test/` has ≥1 valid example; validate.
- [x] T012 [P] [US1] Add or update `charts/kafka-connect/README.md` per FR-001; ensure `examples/kafka-connect/` has ≥1 valid example; validate.
- [x] T013 [P] [US1] Add or update `charts/karpenter-nodes/README.md` per FR-001; ensure `examples/karpenter-nodes/` has ≥1 valid example; validate.
- [x] T014 [P] [US1] Add or update `charts/kubernetes-event-exporter-enriched/README.md` per FR-001; ensure `examples/kubernetes-event-exporter-enriched/` has ≥1 valid example; validate.
- [x] T015 [P] [US1] Add or update `charts/mongodb-bi-connector/README.md` per FR-001; ensure `examples/mongodb-bi-connector/` has ≥1 valid example; validate.
- [x] T016 [P] [US1] Add or update `charts/namespaces-and-docker-auth/README.md` per FR-001; ensure `examples/namespaces-and-docker-auth/` has ≥1 valid example; validate.
- [x] T017 [P] [US1] Add or update `charts/nfs-provisioner/README.md` per FR-001; ensure `examples/nfs-provisioner/` has ≥1 valid example; validate.
- [x] T018 [P] [US1] Add or update `charts/pgcat/README.md` per FR-001; ensure `examples/pgcat/` has ≥1 valid example; validate.
- [x] T019 [P] [US1] Add or update `charts/proxysql/README.md` per FR-001; ensure `examples/proxysql/` has ≥1 valid example; validate.
- [x] T020 [P] [US1] Add or update `charts/resource/README.md` per FR-001; ensure `examples/resource/` has ≥1 valid example; validate.
- [x] T021 [P] [US1] Add or update `charts/sentry-relay/README.md` per FR-001; ensure `examples/sentry-relay/` has ≥1 valid example; validate.
- [x] T022 [P] [US1] Add or update `charts/spqr-router/README.md` per FR-001; ensure `examples/spqr-router/` has ≥1 valid example; validate.
- [x] T023 [P] [US1] Add or update `charts/weave-scope/README.md` per FR-001 (mention nested subcharts if any); ensure `examples/weave-scope/` has ≥1 valid example; validate.

**Checkpoint**: All 19 top-level charts have README and (where applicable) validated example; consumer can install from docs.

---

## Phase 4: User Story 2 - Consistent documentation quality (Priority: P2)

**Goal**: Audit confirms 100% README coverage and all examples validate; optional new-user test.

**Independent Test**: Audit all charts; each has README meeting FR-001; each chart with an example has that example passing helm template.

- [x] T024 [US2] Audit: verify 100% of top-level charts have README at `charts/<name>/README.md` satisfying FR-001 (full or reduced per T003); fix any gaps.
- [x] T025 [US2] Validate every example file: for each `examples/<name>/*.yaml`, run `helm template test charts/<name> -f examples/<name>/<file>.yaml` from repo root; fix or document any failures.
- [ ] T026 [US2] Optional: run new-user test (SC-003) for at least one chart—install or template using only README + example in under 10 minutes; document result or adjust README/example if blocked.
- [x] T027 [US2] Verify no README or example introduces literal environment-specific secrets or cluster names (SC-004); use placeholders or docs only.

**Checkpoint**: SC-001, SC-002, SC-004 satisfied; repo is consistent.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Repo-level docs, final checks, and version bumps (FR-005)

- [x] T028 [P] If repo root README does not already point to `./charts` and mention that chart docs and examples live in each chart's README and `examples/<chart-name>/`, add a short sentence.
- [x] T029 Validate specs/002-chart-examples-readme/quickstart.md steps (consumer + implementer) against current state; update if needed.
- [x] T030 [FR-005] **Version bump (required before implement complete)**: For every chart that was modified in this feature (README, examples, or any file under the chart), increment `version` in `charts/<name>/Chart.yaml` (at least PATCH). If gateway-api was bumped, update base's gateway-api dependency in `charts/base/Chart.yaml` to match. Per spec FR-005 and constitution; do this step when running /speckit.implement.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies.
- **Phase 2 (Foundational)**: Depends on Phase 1 (chart list, examples dirs).
- **Phase 3 (US1)**: Depends on Phase 2 (chart types, lint baseline). All 19 tasks [P]—can run in parallel.
- **Phase 4 (US2)**: Depends on Phase 3 (all charts have README + example).
- **Phase 5 (Polish)**: Depends on Phase 4.

### Parallel Opportunities

- T002: create examples dirs in parallel if scripted.
- T006–T023: all per-chart tasks can run in parallel (different charts).
- T028 and T029 can run in parallel.

---

## Implementation Strategy

- Complete Phase 1 and 2, then Phase 3 (all 19 charts in any order or in parallel). Then Phase 4 validation and Phase 5 polish.
- Per-chart work: update README first, then add/update example(s), then run helm lint and helm template with that example.

---

## Notes

- Library/dependency-only charts: use reduced README (one short paragraph); examples may be minimal or N/A if not installable standalone—document in README.
- Nested subcharts: out of scope; parent chart README (e.g. weave-scope) MUST mention them.
- Commit after each chart or logical group to keep history clear.
