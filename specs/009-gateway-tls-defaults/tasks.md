# Tasks: Gateway TLS Defaults for HTTPS Listeners

**Feature**: 009-gateway-tls-defaults  
**Input**: [spec.md](./spec.md), [plan.md](./plan.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/)

**Path Conventions**: Charts under `charts/gateway-api/`; examples under `examples/gateway-api/`. All work from repository root.

**Organization**: Tasks are grouped by user story. Implementation is largely in one template (gateway.yaml); validation tasks per story ensure each acceptance scenario is met.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (no dependencies)
- **[Story]**: US1, US2, US3 for traceability to spec

---

## Phase 1: Setup

**Purpose**: Confirm environment and paths

- [x] **T001** Ensure working from repo root; feature spec at `specs/009-gateway-tls-defaults/spec.md`; chart at `charts/gateway-api/`; examples at `examples/gateway-api/`.

---

## Phase 2: Foundational (TLS defaulting in template)

**Purpose**: Implement TLS defaulting and passthrough in `gateway.yaml` so HTTPS listeners get default TLS when `tls` is empty, and explicit `tls` is preserved. Blocks all user-story validation.

- [x] **T002** In `charts/gateway-api/templates/gateway.yaml`, at the start of the gateway range (after the `$useParams` block), define `$gatewayName` as the effective Gateway name: `default (include "gateway-api.fullname" $outer) $gateway.name` concatenated with `coalesce $gateway.nameSuffix ""`. Use `$gatewayName` for `metadata.name` (refactor existing expression to use this variable).

- [x] **T003** In the same file, in the listener range, replace the current `{{- with .tls }}` block with conditional TLS logic:
  - If `protocol` is HTTPS (case-insensitive, e.g. `eq (lower $protocol) "https"`) and `tls` is effectively empty (absent, `null`, or empty map—use `or (not .tls) (empty .tls)` or equivalent), render a fixed `tls` block: `mode: Terminate`, `certificateRefs`: one entry with `name: "<$gatewayName>-tls"`, `kind: Secret`, `group: ""`.
  - Else if `tls` is present and non-empty: keep current behavior `{{- toYaml . | nindent 8 }}` under `tls:`.
  - Else (e.g. HTTP): do not emit a `tls` block.

- [x] **T004** [P] (Optional) Add a named template in `charts/gateway-api/templates/_helpers.tpl` for the effective gateway name (e.g. `gateway-api.gatewayEffectiveName`) taking `($outer, $gateway)` and use it in `gateway.yaml` for `$gatewayName` and default TLS secret name. Skip if inlining in gateway.yaml is preferred.

**Checkpoint**: Template renders default TLS for HTTPS when `tls` is empty and passes through non-empty `tls`; non-HTTPS listeners have no `tls`. Proceed to per-story validation.

---

## Phase 3: User Story 1 – Simplified HTTPS gateway configuration (P1)

**Goal**: HTTPS listener without `tls` in values gets defaulted TLS with Secret `{gateway-name}-tls`.

**Independent Test**: `helm template` with an HTTPS listener that omits `tls`; output has `listeners[].tls` with `mode: Terminate` and `certificateRefs[0].name` = `<gateway-name>-tls`.

- [x] **T005** [US1] Add `examples/gateway-api/https-default-tls.yaml` with one Gateway (e.g. `name: main-internal`) and one listener: `port: 443`, `protocol: HTTPS`, no `tls` key. Include top-of-file comment with runnable `helm template` command per constitution.

- [x] **T006** [US1] Run `helm template test charts/gateway-api -f examples/gateway-api/https-default-tls.yaml` and verify the rendered Gateway has a listener with `tls.mode: Terminate` and `tls.certificateRefs[0].name: main-internal-tls` (and `kind: Secret`, `group: ""`).

**Checkpoint**: US1 acceptance scenarios pass.

---

## Phase 4: User Story 2 – Preserve explicit TLS configuration (P2)

**Goal**: HTTPS listener with non-empty `tls` in values is rendered exactly as provided.

**Independent Test**: `helm template` with explicit `tls`; output `tls` block matches values.

- [x] **T007** [US2] Add or update an example (e.g. `examples/gateway-api/https-explicit-tls.yaml`) with one Gateway and one HTTPS listener that has an explicit `tls` block (e.g. custom `certificateRefs` or `mode`). Include runnable-command comment.

- [x] **T008** [US2] Run `helm template` with that example and verify the listener’s `tls` in the manifest matches the values (no default injection).

**Checkpoint**: US2 acceptance scenario passes.

---

## Phase 5: User Story 3 – Safe handling of empty or null TLS (P3)

**Goal**: HTTPS listener with `tls: {}` or `tls` null still receives default TLS.

**Independent Test**: `helm template` with HTTPS listener and `tls: {}` (or equivalent); output has defaulted TLS.

- [x] **T009** [US3] Add or extend an example to include an HTTPS listener with `tls: {}` (empty map). If Helm/values do not support explicit `null`, document that “absent” and `{}` are the tested cases.

- [x] **T010** [US3] Run `helm template` with that example and verify the listener gets the same defaulted TLS as US1 (Terminate + `{gateway-name}-tls`).

**Checkpoint**: US3 acceptance scenario passes.

---

## Phase 6: Polish & validation

**Purpose**: Lint, regression, docs, version bump (mandatory).

- [x] **T011** Run `helm lint charts/gateway-api` from repo root; fix any issues.

- [x] **T012** Run `helm template test charts/gateway-api -f examples/gateway-api/<file>.yaml` for every file in `examples/gateway-api/` (including new ones); confirm no regression and all examples render successfully.

- [x] **T013** [P] Update `charts/gateway-api/README.md` (and values table if applicable) to document that HTTPS listeners get default TLS when `tls` is omitted or empty (Secret name `{gateway-name}-tls`); provisioning of the Secret remains the caller’s responsibility. Optional but recommended.

- [x] **T014** Bump `version` in `charts/gateway-api/Chart.yaml` (PATCH). **Mandatory** per constitution; implement is not complete until this is done.

---

## Dependencies & execution order

- **Phase 1**: No dependencies.
- **Phase 2**: Depends on Phase 1. Must complete before Phase 3–5 (validation requires template changes).
- **Phases 3–5**: Can be done in order (US1 → US2 → US3) or US2/US3 in parallel after T005–T006; each story’s validation is independent.
- **Phase 6**: After all of Phase 2–5; T014 (version bump) is required for completion.

---

## Implementation strategy

1. Complete Phase 1 and Phase 2 (T001–T003; optionally T004).
2. Run `helm template` with minimal values (one Gateway, one HTTPS listener, no `tls`) to confirm default TLS in output.
3. Complete Phase 3 (T005–T006) → US1 done.
4. Complete Phase 4 (T007–T008) → US2 done.
5. Complete Phase 5 (T009–T010) → US3 done.
6. Complete Phase 6 (T011–T014); do not skip T014.

---

## Notes

- No separate test suite; validation is via `helm template` and manual/grep checks per task.
- Mark each task `[x]` when done; T014 must be marked before considering the feature implementation complete.
