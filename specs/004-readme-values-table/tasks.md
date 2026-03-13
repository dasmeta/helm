# Tasks: README values table (004)

**Input**: [spec.md](./spec.md), [plan.md](./plan.md)  
**Goal**: Each top-level chart README has a table (Key, Description, Default/Example) for key values from values.yaml; constitution sync rule already added.

**Charts**: 19 (base, base-cronjob, cloudwatch-agent-prometheus, flagger-metrics-and-alerts, gateway-api, helm-chart-test, kafka-connect, karpenter-nodes, kubernetes-event-exporter-enriched, mongodb-bi-connector, namespaces-and-docker-auth, nfs-provisioner, pgcat, proxysql, resource, sentry-relay, spqr-router, weave-scope).

## Phase 1: Add or update README values table (one per chart; all [P])

- [x] T001 [P] **base**: Add or update `charts/base/README.md` with a table (Key, Description, Default/Example) for key values from `charts/base/values.yaml` (e.g. image, containerPort, service, ingress, configs). Link to values.yaml for full list.
- [x] T002 [P] **base-cronjob**: Add or update `charts/base-cronjob/README.md` with values table from `charts/base-cronjob/values.yaml`.
- [x] T003 [P] **cloudwatch-agent-prometheus**: Add or update `charts/cloudwatch-agent-prometheus/README.md` with values table from its values.yaml.
- [x] T004 [P] **flagger-metrics-and-alerts**: Add or update `charts/flagger-metrics-and-alerts/README.md` with values table from its values.yaml.
- [x] T005 [P] **gateway-api**: Add or update `charts/gateway-api/README.md` with values table from its values.yaml.
- [x] T006 [P] **helm-chart-test**: Add or update `charts/helm-chart-test/README.md` with values table from its values.yaml.
- [x] T007 [P] **kafka-connect**: Add or update `charts/kafka-connect/README.md` with values table from its values.yaml.
- [x] T008 [P] **karpenter-nodes**: Add or update `charts/karpenter-nodes/README.md` with values table from its values.yaml.
- [x] T009 [P] **kubernetes-event-exporter-enriched**: Add or update `charts/kubernetes-event-exporter-enriched/README.md` with values table from its values.yaml.
- [x] T010 [P] **mongodb-bi-connector**: Add or update `charts/mongodb-bi-connector/README.md` with values table from its values.yaml.
- [x] T011 [P] **namespaces-and-docker-auth**: Add or update `charts/namespaces-and-docker-auth/README.md` with values table from its values.yaml.
- [x] T012 [P] **nfs-provisioner**: Add or update `charts/nfs-provisioner/README.md` with values table from its values.yaml.
- [x] T013 [P] **pgcat**: Add or update `charts/pgcat/README.md` with values table (audit existing if any) from its values.yaml.
- [x] T014 [P] **proxysql**: Add or update `charts/proxysql/README.md` with values table from its values.yaml.
- [x] T015 [P] **resource**: Add or update `charts/resource/README.md` with values table from its values.yaml.
- [x] T016 [P] **sentry-relay**: Add or update `charts/sentry-relay/README.md` with values table from its values.yaml.
- [x] T017 [P] **spqr-router**: Audit `charts/spqr-router/README.md` table for sync with values.yaml; fix if stale (already has table).
- [x] T018 [P] **weave-scope**: Add or update `charts/weave-scope/README.md` with values table from its values.yaml (may reference nested subchart values).

## Phase 2: Validate and version bump

- [x] T019 Verify each README table: keys listed exist in values.yaml (or are documented as optional); no obviously stale rows.
- [ ] T020 [FR-005] Version bump: for every chart whose README was modified, increment `version` in `charts/<name>/Chart.yaml` (at least PATCH).

## Reference

- Table format: [charts/spqr-router/README.md](../../charts/spqr-router/README.md) (lines 57–62).
- Contract: [contracts/readme-values-table.md](./contracts/readme-values-table.md).
