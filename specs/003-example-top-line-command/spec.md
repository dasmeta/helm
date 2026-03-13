# Feature Specification: Example top-line helm diff command

**Feature Branch**: `003-example-top-line-command`  
**Created**: 2026-03-09  
**Status**: Draft  
**Input**: Add the constitution-required top-line comment (`# helm diff upgrade --install -n ...`) to all example files that are missing it.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Every example shows how to run it (Priority: P1)

As a consumer, I want every example YAML file to have at the top a comment line with the exact command to run or diff that example (from repo root) so I can copy-paste without reading the README.

**Why this priority**: Constitution and 002 contract require this; 15 example files currently lack it.

**Independent Test**: Open any file under `examples/<chart-name>/*.yaml`; line 1 MUST be `# helm diff upgrade --install -n <namespace> <release> ./charts/<chart-name>/ -f ./examples/<chart-name>/<file>.yaml` (or equivalent).

**Acceptance Scenarios**:

1. **Given** an example file in `examples/<chart-name>/`, **When** I read line 1, **Then** it is a comment with a runnable `helm diff upgrade --install -n ...` (or `helm template ...`) command from repo root.
2. **Given** the 15 files identified as missing the line, **When** the feature is complete, **Then** all 15 have the top line added and still pass `helm template` with that chart.

## Requirements *(mandatory)*

- **FR-001**: Every new or edited example file MUST have as first line a comment: `# helm diff upgrade --install -n <namespace> <release> ./charts/<chart-name>/ -f ./examples/<chart-name>/<file>.yaml` (from repo root). Already in constitution and 002 contract.
- **FR-002**: Fix existing examples that lack it: 15 files (base-cronjob/minimal, base/with-only-job, cloudwatch-agent-prometheus/minimal, flagger-metrics-and-alerts/minimal, helm-chart-test/minimal, kafka-connect/minimal, karpenter-nodes/minimal, kubernetes-event-exporter-enriched/minimal, mongodb-bi-connector/minimal, namespaces-and-docker-auth/minimal, nfs-provisioner/minimal, pgcat/minimal, sentry-relay/minimal, spqr-router/minimal, weave-scope/minimal).

## Success Criteria

- All 15 listed example files have the top-line command comment; no other content change. Each file still validates with `helm template` for its chart.
