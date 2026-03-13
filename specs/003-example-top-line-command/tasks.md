# Tasks: Example top-line helm diff command

**Input**: [spec.md](./spec.md), [plan.md](./plan.md)  
**Goal**: Add `# helm diff upgrade --install -n localhost <release> ./charts/<chart>/ -f ./examples/<chart>/<file>.yaml` as first line to each listed file. From repo root.

## Phase 1: Add top line to each example (all [P])

- [x] T001 [P] Add top line to `examples/base-cronjob/minimal.yaml`: `# helm diff upgrade --install -n localhost base-cronjob-minimal ./charts/base-cronjob/ -f ./examples/base-cronjob/minimal.yaml`
- [x] T002 [P] Add top line to `examples/base/with-only-job.yaml`: `# helm diff upgrade --install -n localhost with-only-job ./charts/base/ -f ./examples/base/with-only-job.yaml`
- [x] T003 [P] Add top line to `examples/cloudwatch-agent-prometheus/minimal.yaml`: `# helm diff upgrade --install -n localhost cloudwatch-minimal ./charts/cloudwatch-agent-prometheus/ -f ./examples/cloudwatch-agent-prometheus/minimal.yaml`
- [x] T004 [P] Add top line to `examples/flagger-metrics-and-alerts/minimal.yaml`: `# helm diff upgrade --install -n localhost flagger-minimal ./charts/flagger-metrics-and-alerts/ -f ./examples/flagger-metrics-and-alerts/minimal.yaml`
- [x] T005 [P] Add top line to `examples/helm-chart-test/minimal.yaml`: `# helm diff upgrade --install -n localhost helm-chart-test-minimal ./charts/helm-chart-test/ -f ./examples/helm-chart-test/minimal.yaml`
- [x] T006 [P] Add top line to `examples/kafka-connect/minimal.yaml`: `# helm diff upgrade --install -n localhost kafka-connect-minimal ./charts/kafka-connect/ -f ./examples/kafka-connect/minimal.yaml`
- [x] T007 [P] Add top line to `examples/karpenter-nodes/minimal.yaml`: `# helm diff upgrade --install -n localhost karpenter-nodes-minimal ./charts/karpenter-nodes/ -f ./examples/karpenter-nodes/minimal.yaml`
- [x] T008 [P] Add top line to `examples/kubernetes-event-exporter-enriched/minimal.yaml`: `# helm diff upgrade --install -n localhost event-exporter-minimal ./charts/kubernetes-event-exporter-enriched/ -f ./examples/kubernetes-event-exporter-enriched/minimal.yaml`
- [x] T009 [P] Add top line to `examples/mongodb-bi-connector/minimal.yaml`: `# helm diff upgrade --install -n localhost mongodb-bi-minimal ./charts/mongodb-bi-connector/ -f ./examples/mongodb-bi-connector/minimal.yaml`
- [x] T010 [P] Add top line to `examples/namespaces-and-docker-auth/minimal.yaml`: `# helm diff upgrade --install -n localhost namespaces-minimal ./charts/namespaces-and-docker-auth/ -f ./examples/namespaces-and-docker-auth/minimal.yaml`
- [x] T011 [P] Add top line to `examples/nfs-provisioner/minimal.yaml`: `# helm diff upgrade --install -n localhost nfs-provisioner-minimal ./charts/nfs-provisioner/ -f ./examples/nfs-provisioner/minimal.yaml`
- [x] T012 [P] Add top line to `examples/pgcat/minimal.yaml`: `# helm diff upgrade --install -n localhost pgcat-minimal ./charts/pgcat/ -f ./examples/pgcat/minimal.yaml`
- [x] T013 [P] Add top line to `examples/sentry-relay/minimal.yaml`: `# helm diff upgrade --install -n localhost sentry-relay-minimal ./charts/sentry-relay/ -f ./examples/sentry-relay/minimal.yaml`
- [x] T014 [P] Add top line to `examples/spqr-router/minimal.yaml`: `# helm diff upgrade --install -n localhost spqr-router-minimal ./charts/spqr-router/ -f ./examples/spqr-router/minimal.yaml`
- [x] T015 [P] Add top line to `examples/weave-scope/minimal.yaml`: `# helm diff upgrade --install -n localhost weave-scope-minimal ./charts/weave-scope/ -f ./examples/weave-scope/minimal.yaml`

## Phase 2: Validate

- [x] T016 Run `helm template` for each modified file (e.g. `helm template <release> charts/<name> -f examples/<name>/<file>.yaml`) from repo root; fix any breakage.
