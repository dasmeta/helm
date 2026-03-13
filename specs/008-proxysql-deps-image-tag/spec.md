# Feature Specification: ProxySQL Chart — Dependencies and Image Tag Update

**Feature Branch**: `008-proxysql-deps-image-tag`  
**Created**: 2025-03-13  
**Status**: Draft  
**Input**: User description: "in dasmeta/helm repo proxysql update also proxysql chart base and base-cronjob dependencies also fix/update proxysql image tag to 3.0.6"

## Clarifications

### Session 2025-03-13

- Q: How should target versions for base and base-cronjob be defined? → A: Leave to plan — use latest from Helm repo at implementation time (no versions pinned in spec).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - ProxySQL chart uses updated base and base-cronjob dependencies (Priority: P1)

As an operator deploying ProxySQL via the proxysql Helm chart, I need the chart to declare up-to-date versions of its base and base-cronjob dependencies so that deployments benefit from the latest shared chart fixes and behavior. The chart’s dependency list must be updated accordingly.

**Why this priority**: Dependencies drive rendered manifests and behavior; updating them ensures consistency with the rest of the repo.

**Independent Test**: Inspect the proxysql chart’s dependency declarations for base and base-cronjob; confirm versions are updated per repo policy; run lint and template to verify the chart still renders.

**Acceptance Scenarios**:

1. **Given** the proxysql Helm chart in the repo, **When** its dependency list is inspected, **Then** the base and base-cronjob dependencies are set to the intended updated versions.
2. **Given** the updated proxysql chart, **When** `helm dependency update` and `helm template` are run, **Then** the chart resolves and renders without errors.
3. **Given** a consumer that installs or upgrades the proxysql chart, **When** the install/upgrade runs, **Then** the chart deploys using the updated dependency versions.

---

### User Story 2 - ProxySQL default image tag matches app version 3.0.6 (Priority: P2)

As an operator deploying ProxySQL via the proxysql Helm chart, I need the default image tag in values to match the chart’s declared app version (3.0.6) so that a default install runs the same ProxySQL release as advertised. The default image tag in the chart’s values must be 3.0.6.

**Why this priority**: Aligns default behavior with Chart.yaml appVersion and avoids version mismatch (constitution: app version and image tag sync).

**Independent Test**: Inspect the proxysql chart’s default values for the image tag; confirm it is 3.0.6; run helm template with default values and verify the rendered image tag is 3.0.6.

**Acceptance Scenarios**:

1. **Given** the proxysql Helm chart, **When** default values are inspected, **Then** the image tag (e.g. proxysql.image.tag) is 3.0.6.
2. **Given** a default install of the proxysql chart, **When** manifests are rendered, **Then** the container image tag is 3.0.6 (matching appVersion).

---

### Edge Cases

- What happens when the chosen base or base-cronjob version is not yet published in the Helm repo? Dependency update will fail; the implementer must use versions that exist in the configured repository.
- If existing installations override the image tag via values, their behavior is unchanged; only the default is updated to 3.0.6.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The proxysql chart MUST declare updated versions for the base and base-cronjob dependencies. Target versions are not pinned in this spec; the plan MUST use the latest versions available from the configured Helm repository (https://dasmeta.github.io/helm) at implementation time.
- **FR-002**: The proxysql chart MUST remain installable and upgradable after the dependency version updates; lint and template MUST pass.
- **FR-003**: The proxysql chart’s default image tag in values MUST be set to 3.0.6 so that it matches the chart’s appVersion (3.0.6).
- **FR-004**: After changes, the chart version in Chart.yaml MUST be bumped (at least PATCH) per versioning policy.

### Key Entities

- **ProxySQL chart**: The Helm chart that packages ProxySQL; its dependencies (base, base-cronjob) and default image tag must be updated.
- **Base / base-cronjob**: Upstream chart dependencies of the proxysql chart; their declared versions in Chart.yaml must be updated.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Operators can install or upgrade the proxysql chart with the updated base and base-cronjob dependency versions (verifiable by Chart.yaml and successful dependency update + template).
- **SC-002**: The default image tag in the proxysql chart values is 3.0.6 and matches the chart’s appVersion (verifiable by inspection and rendered manifests).
- **SC-003**: Lint and template pass for the proxysql chart with default values after all changes.
- **SC-004**: No regressions; existing workflows that install or upgrade the proxysql chart continue to succeed.

## Assumptions

- Target versions for base and base-cronjob are not pinned in the spec; the plan and implementation use the latest versions available from the configured Helm repository (https://dasmeta.github.io/helm) at implementation time.
- The chart’s appVersion is already 3.0.6; this feature fixes the default image tag in values to match.
- Chart version bump (PATCH) is applied after dependency and values changes.
