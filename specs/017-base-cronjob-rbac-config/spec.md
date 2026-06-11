# Feature Specification: Base CronJob RBAC And File Config Support

**Feature Branch**: `017-base-cronjob-rbac-config`  
**Created**: 2026-06-11  
**Status**: Draft  
**Input**: Extend `charts/base-cronjob` so Terraform and Helm consumers can deploy CronJobs that need ServiceAccount RBAC, file-mounted ConfigMaps, and common CronJob operational controls.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Render RBAC For A CronJob (Priority: P1)

As a `base-cronjob` consumer, I can enable RBAC for one job so the chart creates the Role or ClusterRole and corresponding binding needed by the job ServiceAccount.

**Why this priority**: Cleanup and maintenance jobs often require permissions beyond the default ServiceAccount. The chart previously created a ServiceAccount but did not provide a matching RBAC surface.

**Independent Test**: Render `charts/base-cronjob` with `jobs[].rbac.create=true` and verify the output includes the requested RBAC resources and binds them to the configured ServiceAccount.

**Acceptance Scenarios**:

1. **Given** `rbac.create=true` and `rbac.clusterWide=true`, **When** the chart is rendered, **Then** it creates a `ClusterRole` and `ClusterRoleBinding`.
2. **Given** `rbac.create=true` and `rbac.clusterWide=false`, **When** the chart is rendered, **Then** it creates a namespace-scoped `Role` and `RoleBinding`.
3. **Given** custom RBAC rules, **When** the chart is rendered, **Then** the generated role contains those rules.

---

### User Story 2 - Mount A ConfigMap As Files Without Env Import (Priority: P1)

As a `base-cronjob` consumer, I can create a ConfigMap and mount it as files without automatically importing that ConfigMap as environment variables.

**Why this priority**: Script-based jobs need ConfigMap file mounts. Importing script filenames as environment variables is invalid and can break rendered workloads.

**Independent Test**: Render `charts/base-cronjob` with `config.enabled=true`, `config.envFrom=false`, and a ConfigMap volume mount, then verify that the ConfigMap and volume mount render while `envFrom` does not.

**Acceptance Scenarios**:

1. **Given** `config.envFrom=false`, **When** the chart is rendered, **Then** the generated CronJob does not include `envFrom` for that ConfigMap.
2. **Given** a ConfigMap volume, **When** the chart is rendered, **Then** the generated CronJob mounts the ConfigMap at the configured mount path.
3. **Given** `config.envFrom` is omitted, **When** the chart is rendered with `config.enabled=true`, **Then** existing env-from behavior remains enabled by default.

---

### User Story 3 - Configure Common CronJob Controls (Priority: P2)

As a `base-cronjob` consumer, I can set common CronJob and Job controls from values so scheduled workloads can be tuned without forking chart templates.

**Why this priority**: Consumers need controls such as history limits, suspend, backoff limit, and finished-job TTL for operational safety.

**Independent Test**: Render `charts/base-cronjob` with the new fields set and verify the generated CronJob contains the expected values.

**Acceptance Scenarios**:

1. **Given** history limits are set, **When** the chart is rendered, **Then** `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` appear in the CronJob spec.
2. **Given** `suspend=true`, **When** the chart is rendered, **Then** the CronJob spec includes `suspend: true`.
3. **Given** job backoff and TTL values are set, **When** the chart is rendered, **Then** the job template spec includes `backoffLimit` and `ttlSecondsAfterFinished`.

### Edge Cases

- RBAC must stay disabled by default.
- RBAC must bind to `jobs[].serviceAccount.name` when it is provided and fall back to the job name otherwise.
- `config.envFrom=false` must be respected as an explicit false value, not replaced by the default true behavior.
- Empty `env`, `envFrom`, and `volumeMounts` blocks must not render when no values require them.
- ServiceAccount labels and annotations must be optional and render valid YAML when omitted.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The chart MUST support `jobs[].rbac.create`.
- **FR-002**: The chart MUST support `jobs[].rbac.clusterWide`.
- **FR-003**: When `jobs[].rbac.clusterWide=true`, the chart MUST render `ClusterRole` and `ClusterRoleBinding`.
- **FR-004**: When `jobs[].rbac.clusterWide=false`, the chart MUST render `Role` and `RoleBinding`.
- **FR-005**: The RBAC binding subject MUST reference the configured job ServiceAccount and release namespace.
- **FR-006**: The chart MUST render `jobs[].rbac.rules` into the generated role resource.
- **FR-007**: The chart MUST support `jobs[].config.envFrom`, defaulting to existing env-from behavior when omitted.
- **FR-008**: When `jobs[].config.envFrom=false`, the chart MUST NOT render the config map under `envFrom`.
- **FR-009**: The chart MUST continue rendering ConfigMap resources when `jobs[].config.enabled=true`.
- **FR-010**: The chart MUST support `successfulJobsHistoryLimit`, `failedJobsHistoryLimit`, `suspend`, `jobBackoffLimit`, and `ttlSecondsAfterFinished`.
- **FR-011**: The chart MUST avoid rendering empty `env`, `envFrom`, or `volumeMounts` keys.
- **FR-012**: The chart README and `values.yaml` MUST document the new public values.
- **FR-013**: The affected chart version MUST be bumped.
- **FR-014**: The change MUST include render specs under `charts/base-cronjob/tests`.

### Key Entities

- **CronJob definition**: An item in `jobs[]` that describes one rendered Kubernetes CronJob.
- **RBAC settings**: Optional `jobs[].rbac` values that create permissions for the job ServiceAccount.
- **ConfigMap file mount**: A `config.enabled=true` ConfigMap mounted through `jobs[].volumes` rather than imported through `envFrom`.
- **CronJob controls**: Schedule and job lifecycle fields rendered into the Kubernetes CronJob resource.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `helm lint ./charts/base-cronjob` completes with 0 failed charts.
- **SC-002**: `charts/base-cronjob/tests/render-rbac.sh ./charts/base-cronjob` passes.
- **SC-003**: `charts/base-cronjob/tests/render-config-file-mount.sh ./charts/base-cronjob` passes.
- **SC-004**: `charts/base-cronjob/tests/render-cronjob-controls.sh ./charts/base-cronjob` passes.
- **SC-005**: A reviewer can find the new RBAC and config options in `values.yaml`, README, and render specs.
