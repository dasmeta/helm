# Tasks: Galust AI Layer Chart Sync

**Input**: Design documents from `/specs/019-galust-ai-layer-chart-sync/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/render-contract.md`, `quickstart.md`

**Tests**: Helm lint/template plus focused string assertions on rendered YAML.

**Organization**: Tasks grouped by user story. Implementation on this branch is complete; items are checked off.

## Phase 1: Setup

- [x] T001 Capture current `ai-layer/*/helm` values and ingress as the sync source in `specs/019-galust-ai-layer-chart-sync/research.md`
- [x] T002 Confirm `charts/base/templates/service.yaml` has no `sessionAffinity` fields before the change

---

## Phase 2: Foundational

- [x] T003 Bump `charts/galust-ai-layer` to `0.2.0` and replace `mcpUseCase` dependency with `orchestratorScheduler` in `charts/galust-ai-layer/Chart.yaml`
- [x] T004 Update `charts/galust-ai-layer/templates/NOTES.txt` component list
- [x] T005 Refresh `charts/galust-ai-layer/Chart.lock` via `helm dependency update`

**Checkpoint**: Chart.yaml no longer references mcpUseCase.

---

## Phase 3: User Story 1 - Current component set (P1)

- [x] T006 [US1] Remove `mcpUseCase` values block from `charts/galust-ai-layer/values.yaml`
- [x] T007 [US1] Add `orchestratorScheduler` values from `ai-layer/orchestrator/helm/values-scheduler.yaml`
- [x] T008 [US1] `helm template` defaults: no mcp-use-case; scheduler present

**Checkpoint**: Component set matches prod core.

---

## Phase 4: User Story 2 - Production env/ingress/HPA (P1)

- [x] T009 [US2] Sync mcp config and `$http_mcp_session_id` ingress in `charts/galust-ai-layer/values.yaml`
- [x] T010 [US2] Sync mcp-products probes, resources, HPA, session cap, `$remote_addr` ingress
- [x] T011 [US2] Sync orchestrator in-cluster MCP URLs, evaluation env, CORS headers, backend MCP URLs
- [x] T012 [US2] Render and assert contract strings in `contracts/render-contract.md`

**Checkpoint**: Render matches current ai-layer helm (non-secret).

---

## Phase 5: User Story 3 - Native sessionAffinity (P1)

- [x] T013 [US3] Add `sessionAffinity` / `sessionAffinityConfig` to `charts/base/templates/service.yaml` and `charts/base/values.yaml`
- [x] T014 [US3] Bump `charts/base` to `0.3.33` in `charts/base/Chart.yaml`
- [x] T015 [US3] Add `examples/base/with-session-affinity.yaml` and document keys in `charts/base/README.md`
- [x] T016 [US3] Set mcp-products `service.sessionAffinity` in umbrella values; vendor `base-0.3.33.tgz`
- [x] T017 [US3] Remove umbrella patch Job template, helpers, and `mcpProductsSessionAffinity` values

**Checkpoint**: Affinity is on the Service spec; no hook Job.

---

## Phase 6: User Story 4 - Docs (P2)

- [x] T018 [US4] Update `charts/galust-ai-layer/README.md` component table, secrets, hosts, session-affinity section
- [x] T019 [US4] Refresh `examples/galust-ai-layer/values.test.yaml`
- [x] T020 [US4] Move Speckit artifacts to `specs/019-galust-ai-layer-chart-sync/` (replace `docs/superpowers/` copies)

**Checkpoint**: Operators can install from README; specs live in Speckit layout.

---

## Phase 7: Polish

- [x] T021 `helm lint ./charts/base` and `helm lint ./charts/galust-ai-layer`
- [x] T022 `helm template` per `quickstart.md` (defaults, disable toggles, examples)
- [x] T023 Confirm `charts/galust-ai-layer` version `0.2.1` and `charts/base` version `0.3.33`

## Dependencies & Execution Order

- Setup → Foundational (blocks stories) → US1 → US2 → US3 (needs US2 mcp-products values) → US4 → Polish
- US3 can conceptually ship as its own chart change (`base` 0.3.33) before umbrella consumes it
