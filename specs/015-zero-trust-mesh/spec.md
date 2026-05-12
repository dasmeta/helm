# Feature Specification: Zero Trust Mesh Empty Default Allow Rules

**Feature Branch**: `015-zero-trust-mesh`  
**Created**: 2026-05-12  
**Status**: Draft  
**Input**: User description: "update zero-trust-mesh default allowTo config to be empty list; when deploying from base it creates stuff by default"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Default zero-trust-mesh renders no sample allow rules (Priority: P1)

As a zero-trust-mesh chart consumer, I can render the chart with default values without creating sample service, host, or IP allow resources.

**Why this priority**: Sample defaults can create unintended policies or external egress permissions when consumers expect an opt-in allow list.

**Independent Test**: Render `charts/zero-trust-mesh` with default values and verify the output does not contain sample resources for `backend`, `api.stripe.com`, or `192.0.2.10`.

**Acceptance Scenarios**:

1. **Given** default zero-trust-mesh values, **When** the chart is rendered, **Then** no `allow-*-to-backend` NetworkPolicy or AuthorizationPolicy is emitted.
2. **Given** default zero-trust-mesh values, **When** the chart is rendered, **Then** no sample `ServiceEntry` for `api.stripe.com` is emitted.
3. **Given** default zero-trust-mesh values, **When** the chart is rendered, **Then** no sample IP egress policy or ServiceEntry for `192.0.2.10` is emitted.

---

### User Story 2 - Base chart enabling zeroTrustMesh does not inherit sample allow rules (Priority: P1)

As a base chart consumer, I can set `zeroTrustMesh.enabled=true` without also getting the zero-trust-mesh chart's sample `allowTo` entries.

**Why this priority**: The base chart vendors a packaged zero-trust-mesh dependency, so the parent values must explicitly suppress sample defaults until the dependency package is updated.

**Independent Test**: Render `charts/base` with `--set zeroTrustMesh.enabled=true` and verify no sample backend or Stripe allow resources are emitted.

**Acceptance Scenarios**:

1. **Given** default base values with only `zeroTrustMesh.enabled=true`, **When** the chart is rendered, **Then** base resources still render normally.
2. **Given** the same render, **When** zero-trust-mesh subchart output is inspected, **Then** no sample `backend` or `api.stripe.com` allow resources are emitted.
3. **Given** a base values file provides its own `zeroTrustMesh.allowTo`, **When** the chart is rendered, **Then** those explicit allow rules still render.

---

### User Story 3 - Consumers can still discover the allowTo shape (Priority: P2)

As a chart consumer, I can see that `allowTo` defaults to an empty list while still finding example service, host, and IP rule shapes in documentation.

**Why this priority**: Empty defaults are safer, but consumers still need clear examples for explicit configuration.

**Independent Test**: Review `charts/zero-trust-mesh/values.yaml` and README to confirm `allowTo: []` is documented and examples remain available as comments or examples.

**Acceptance Scenarios**:

1. **Given** a user opens `values.yaml`, **When** they inspect `allowTo`, **Then** the active value is `[]`.
2. **Given** the same file, **When** they need an example, **Then** commented service, host, and IP examples are still present.
3. **Given** a user opens the README values table, **When** they scan defaults, **Then** `allowTo` is listed as `[]`.

### Edge Cases

- Enabling namespace baseline resources with `namespaceResourcesEnabled=true` and `allowTo=[]` may still render namespace-scoped default deny, DNS, egress gateway, mTLS, and default deny AuthorizationPolicy resources.
- Explicit service, host, or IP entries under `allowTo` must continue to render as before.
- The base chart's packaged dependency currently references `zero-trust-mesh` `0.1.0`; parent values must override `allowTo` to avoid inherited sample defaults.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `charts/zero-trust-mesh/values.yaml` MUST set the active default `allowTo` value to an empty list.
- **FR-002**: Default zero-trust-mesh rendering MUST NOT emit sample service allow resources.
- **FR-003**: Default zero-trust-mesh rendering MUST NOT emit sample host ServiceEntry resources.
- **FR-004**: Default zero-trust-mesh rendering MUST NOT emit sample IP egress resources.
- **FR-005**: `charts/base/values.yaml` MUST set `zeroTrustMesh.allowTo` to an empty list so base overrides packaged subchart sample defaults.
- **FR-006**: Rendering base with only `zeroTrustMesh.enabled=true` MUST NOT emit sample zero-trust-mesh allow resources.
- **FR-007**: Explicit `zeroTrustMesh.allowTo` values in base consumers MUST continue to render.
- **FR-008**: Documentation MUST state that `allowTo` defaults to `[]` while preserving example rule shapes.
- **FR-009**: The change MUST include focused render assertions for both the standalone chart and base chart behavior.
- **FR-010**: Affected chart versions MUST be bumped according to repository chart versioning practice.

### Key Entities *(include if feature involves data)*

- **Allow rule list**: The top-level zero-trust-mesh `allowTo` list containing service, host, and IP entries.
- **Base subchart override**: The `zeroTrustMesh.allowTo` value in `charts/base/values.yaml` passed to the aliased dependency.
- **Sample allow resource**: Any rendered policy or ServiceEntry derived from documentation examples instead of explicit consumer values.

### Assumptions

- Consumers that need allow rules already provide them in values files, examples, or release-specific overrides.
- Empty `allowTo` means no service-level allow rules, not disabling namespace baseline resources.
- Base chart dependency packaging will be handled separately if the vendored `.tgz` is updated in a future release.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `charts/zero-trust-mesh/tests/render-default-empty.sh ./charts/zero-trust-mesh` exits with status `0`.
- **SC-002**: `charts/base/tests/render-zero-trust-default-empty.sh ./charts/base` exits with status `0`.
- **SC-003**: `helm lint ./charts/zero-trust-mesh` completes with 0 failed charts.
- **SC-004**: `helm lint ./charts/base` completes with 0 failed charts.
- **SC-005**: Explicit zero-trust-mesh examples still render successfully with configured `allowTo` entries.
