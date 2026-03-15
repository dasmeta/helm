# Feature Specification: Base Chart Gateway-API and ProxySQL Version Updates

**Feature Branch**: `007-gateway-proxysql-versions`  
**Created**: 2025-03-13  
**Status**: Draft  
**Input**: User description: "for dasmeta/helm repo base chart update gateway-api dependency to its new 0.1.3 version, have helm dependency update run in folder dasmeta/helm/charts/base/charts to get the value, also there is new proxysql stable app version available 3.0.6, have app version upgraded in proxysql helm chart"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Base chart uses updated Gateway API dependency (Priority: P1)

As an operator deploying the base chart or charts that depend on it, I need the base chart to depend on the Gateway API chart version 0.1.3 so that deployments use the latest fixes and features from that release. Dependency metadata (e.g. lockfile or packaged charts) must be refreshed so that installing or upgrading the base chart pulls the correct 0.1.3 artifact.

**Why this priority**: The base chart is shared; updating its Gateway API dependency ensures all consumers get the new version consistently.

**Independent Test**: Can be fully tested by inspecting the base chart dependency declaration for gateway-api at version 0.1.3 and verifying that dependency update has been run for the base chart so that packaged/locked artifacts in charts/base/charts and Chart.lock reflect 0.1.3.

**Acceptance Scenarios**:

1. **Given** the base chart in the dasmeta/helm repo, **When** its dependency list is inspected, **Then** the gateway-api dependency is declared at version 0.1.3.
2. **Given** the base chart, **When** dependency update has been run for it (e.g. `helm dependency update charts/base` from repo root), **Then** the resolved gateway-api artifact in charts/base/charts and Chart.lock corresponds to version 0.1.3.
3. **Given** a consumer that installs or upgrades the base chart, **When** the install/upgrade runs, **Then** the Gateway API component is at version 0.1.3.

---

### User Story 2 - ProxySQL chart advertises and supports app version 3.0.6 (Priority: P2)

As an operator deploying ProxySQL via the proxysql Helm chart, I need the chart to declare and use the stable ProxySQL application version 3.0.6 so that deployments run the supported release with known fixes and compatibility.

**Why this priority**: Follows the base chart update; delivers the requested application version for ProxySQL deployments.

**Independent Test**: Can be fully tested by inspecting the proxysql chart’s app version and confirming it is set to 3.0.6; deployments using the chart should be able to run ProxySQL 3.0.6.

**Acceptance Scenarios**:

1. **Given** the proxysql Helm chart in the repo, **When** its metadata is inspected, **Then** the chart’s app version is 3.0.6.
2. **Given** a deployment using the updated proxysql chart, **When** the release is installed or upgraded, **Then** the intended ProxySQL application version is 3.0.6 (as declared by the chart).

---

### Edge Cases

- What happens when dependency update is run for the base chart and the gateway-api 0.1.3 artifact is unavailable? The process should fail clearly so operators know the dependency cannot be resolved.
- How does the system handle existing installations that are on gateway-api 0.1.2 or ProxySQL 3.0.5? Upgrades should be possible without breaking existing workloads; any breaking changes in 0.1.3 or 3.0.6 should be documented or called out.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The base chart MUST declare the gateway-api dependency at version 0.1.3.
- **FR-002**: Dependency update MUST be run for the base chart (e.g. `helm dependency update charts/base` from repo root) so that resolved artifacts in charts/base/charts and Chart.lock reflect gateway-api 0.1.3.
- **FR-003**: The proxysql Helm chart MUST declare app version 3.0.6 so that deployments use the stable ProxySQL 3.0.6 release.
- **FR-004**: After changes, the base chart MUST remain installable and upgradable with the new gateway-api version.
- **FR-005**: After changes, the proxysql chart MUST remain installable and upgradable with app version 3.0.6.

### Key Entities

- **Base chart**: The shared Helm chart that declares the gateway-api dependency; its dependency metadata must be updated in the designated charts folder.
- **ProxySQL chart**: The Helm chart that packages ProxySQL; its app version field must reflect the 3.0.6 release.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Operators can install or upgrade the base chart and receive the Gateway API component at version 0.1.3 (verifiable by chart metadata and resolved dependency).
- **SC-002**: Operators can install or upgrade the proxysql chart and deploy ProxySQL application version 3.0.6 (verifiable by chart app version and deployment).
- **SC-003**: Dependency resolution for the base chart completes successfully when run for the base chart (e.g. from repo root), with gateway-api 0.1.3 reflected in Chart.lock and charts/base/charts.
- **SC-004**: No regressions: existing workflows that install or upgrade the base chart or the proxysql chart continue to succeed after the version updates.

## Assumptions

- Gateway API chart version 0.1.3 is available in the configured repository (https://dasmeta.github.io/helm).
- ProxySQL 3.0.6 is the intended stable release; no additional configuration changes are required beyond updating the chart’s app version unless otherwise specified.
- Running dependency update for the base chart (e.g. `helm dependency update charts/base` from repo root) updates charts/base/charts and Chart.lock and is the correct way to refresh the base chart's dependency artifacts for this repo layout.
