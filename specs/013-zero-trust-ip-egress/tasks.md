# Tasks: Zero Trust IP Egress

**Input**: Design documents from `/specs/013-zero-trust-ip-egress/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/render-contract.md`, `quickstart.md`

**Tests**: This feature requires Helm lint/template checks plus a focused render assertion.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm API contracts and capture the missing IP egress behavior.

- [x] T001 Review Istio ServiceEntry and Kubernetes NetworkPolicy IP block field shapes; document findings in `specs/013-zero-trust-ip-egress/research.md`
- [x] T002 Add `charts/zero-trust-mesh/tests/ip-egress-values.yaml` with an `allowTo` IP rule containing one single IP and one CIDR
- [x] T003 Add `charts/zero-trust-mesh/tests/render-ip-egress.sh` to assert ServiceEntry, `resolution: NONE`, normalized IPs, NetworkPolicy, `ipBlock`, and configured ports render
- [x] T004 Run `./charts/zero-trust-mesh/tests/render-ip-egress.sh ./charts/zero-trust-mesh` before implementation and confirm it fails because IP egress resources are absent

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add shared helpers required by the IP ServiceEntry and NetworkPolicy templates.

- [x] T005 Add `ztm.ipCidr` helper in `charts/zero-trust-mesh/templates/_helpers.tpl`
- [x] T006 Add `ztm.networkPolicyProtocol` helper in `charts/zero-trust-mesh/templates/_helpers.tpl`
- [x] T007 Ensure `ztm.ipCidr` preserves CIDRs, converts IPv4 host addresses to `/32`, and converts IPv6 host addresses to `/128`

**Checkpoint**: Shared IP normalization and NetworkPolicy protocol helpers are available.

---

## Phase 3: User Story 1 - Allow direct destination IP egress (Priority: P1) 🎯 MVP

**Goal**: Render IP rules into both Istio and Kubernetes policy resources.

**Independent Test**: `./charts/zero-trust-mesh/tests/render-ip-egress.sh ./charts/zero-trust-mesh`

- [x] T008 [US1] Update `charts/zero-trust-mesh/templates/istio-serviceentries.yaml` to render `allowTo[].ips` as a ServiceEntry with `addresses` and `resolution: NONE`
- [x] T009 [US1] Add `charts/zero-trust-mesh/templates/networkpolicy-ip-egress.yaml` to render source-workload egress NetworkPolicy rules with `ipBlock`
- [x] T010 [US1] Re-run the focused render assertion and confirm it exits `0`

**Checkpoint**: Direct IP egress is rendered and independently verifiable.

---

## Phase 4: User Story 2 - Preserve existing service and host behavior (Priority: P2)

**Goal**: Keep old service and host rule outputs valid.

**Independent Test**: Default rendering and existing target-pod-label render assertion complete successfully.

- [x] T011 [US2] Render default chart values and confirm service and host outputs remain valid
- [x] T012 [US2] Run `./charts/zero-trust-mesh/tests/render-target-pod-labels.sh ./charts/zero-trust-mesh`
- [x] T013 [US2] Confirm host-only `allowTo` entries still render DNS ServiceEntry resources with `resolution: DNS`

**Checkpoint**: Existing service and host consumers are not regressed.

---

## Phase 5: User Story 3 - Discover and validate the IP egress values shape (Priority: P3)

**Goal**: Document and demonstrate `allowTo[].ips`.

**Independent Test**: A user can render the repo-level example command successfully.

- [x] T014 [US3] Document `allowTo[].ips` in `charts/zero-trust-mesh/values.yaml`
- [x] T015 [US3] Document `allowTo[].ips` in `charts/zero-trust-mesh/README.md`
- [x] T016 [US3] Add `examples/zero-trust-mesh/ip-egress.yaml` with a top-line runnable Helm command
- [x] T017 [US3] Render the new example with `helm template ztm-ip-egress ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/ip-egress.yaml`

**Checkpoint**: Documentation and example values show the new IP egress option.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final compliance, versioning, and release readiness.

- [x] T018 Add Speckit artifacts under `specs/013-zero-trust-ip-egress/`
- [x] T019 Bump `charts/zero-trust-mesh/Chart.yaml` patch version
- [x] T020 Run `helm lint ./charts/zero-trust-mesh`
- [x] T021 Run `helm template ztm-default ./charts/zero-trust-mesh -n default`
- [x] T022 Run focused render assertion `./charts/zero-trust-mesh/tests/render-ip-egress.sh ./charts/zero-trust-mesh`
- [x] T023 Run existing example regressions from `specs/013-zero-trust-ip-egress/quickstart.md`
- [x] T024 Run `git diff --check`

## Dependencies & Execution Order

- Phase 1 precedes implementation because the render assertion must fail first.
- Phase 2 precedes US1 because both IP rendering paths use shared helpers.
- US2 depends on final template output to validate regression behavior.
- US3 depends on finalized values shape and render output.
- Phase 6 depends on all stories.

## Parallel Opportunities

- Documentation updates (`T014`, `T015`) can run after values shape is final.
- Example rendering and default rendering can run in parallel during verification.
- Speckit documentation can be reviewed independently of template code after behavior is finalized.

## Implementation Strategy

1. Prove current behavior fails the new IP egress assertion.
2. Add IP normalization and protocol helpers.
3. Render IP ServiceEntry and IP egress NetworkPolicy.
4. Confirm focused IP egress rendering.
5. Confirm service and host behavior still renders.
6. Add docs/example/version bump and run Helm validation.
