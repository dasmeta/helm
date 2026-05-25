# Feature Specification: Service-Level Deny All

**Feature Branch**: `016-service-deny-all`  
**Created**: 2026-05-21  
**Status**: Draft  
**Input**: Jira `DMVP-10070`: add a service-level deny-all mode so one workload can deny inbound and outbound traffic without enabling namespace-wide deny-all.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Isolate one service first (Priority: P1)

As a zero-trust-mesh chart consumer, I can enable deny-all for one selected workload, so I can safely isolate that service before adding explicit allow rules.

**Why this priority**: This is the requested safety control for Checkpoint rollout. Namespace-level deny-all is too broad for incremental adoption because it can affect every workload in the namespace.

**Independent Test**: Render `charts/zero-trust-mesh` with service-level deny-all enabled, then verify the output includes workload-scoped Kubernetes `NetworkPolicy` deny-all for both ingress and egress plus a workload-scoped Istio `AuthorizationPolicy` default deny.

**Acceptance Scenarios**:

1. **Given** service-level deny-all is enabled for workload `frontend`, **When** the chart is rendered, **Then** the generated NetworkPolicy selects only `frontend` pods and lists both `Ingress` and `Egress` policy types.
2. **Given** the same values, **When** the chart is rendered, **Then** the generated Istio AuthorizationPolicy selects only `frontend` pods and provides default-deny behavior for inbound mesh traffic.
3. **Given** namespace baseline is disabled, **When** service-level deny-all is rendered, **Then** no namespace-wide deny-all NetworkPolicy is created by that setting.

---

### User Story 2 - Preserve existing allow rules (Priority: P2)

As an existing chart consumer, I can keep using service, host, and IP allow rules without behavior changes caused by adding service-level deny-all.

**Why this priority**: The new control must be additive and compatible with follow-up explicit allow rules.

**Independent Test**: Render existing examples and focused render checks after the new option is added.

**Acceptance Scenarios**:

1. **Given** existing `allowTo[].service` rules, **When** the chart is rendered, **Then** existing NetworkPolicy ingress and AuthorizationPolicy allow resources still render.
2. **Given** existing `allowTo[].hosts` and `allowTo[].ips` rules, **When** the chart is rendered, **Then** existing ServiceEntry and IP egress NetworkPolicy behavior remains valid.

---

### User Story 3 - Discover safe rollout values (Priority: P3)

As a service owner, I can find an example for service-level deny-all, so I can start with a safe isolated service and later add explicit allow rules.

**Why this priority**: The option changes the public chart values contract and should be easy to discover.

**Independent Test**: Follow the example under `examples/zero-trust-mesh/service-deny-all.yaml` and render it successfully with Helm.

**Acceptance Scenarios**:

1. **Given** a user reads the chart README, **When** they scan the key values table, **Then** they can find the service-level deny-all option and its intended scope.
2. **Given** the documented example, **When** a user runs its top-line Helm command, **Then** the chart renders successfully.

### Edge Cases

- Service-level deny-all must not create namespace-wide deny resources when `namespaceResourcesEnabled` is false.
- If NetworkPolicy support is disabled with `networkPolicy.enabled: false`, the chart must not render the service-level NetworkPolicy.
- If Istio support is disabled with `istio.enabled: false`, the chart must not render the service-level AuthorizationPolicy.
- Consumers must be able to override the workload pod selector when the default `app.kubernetes.io/name: <workload>` label does not match their deployment labels.
- Existing namespace baseline resources must remain unchanged.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The chart MUST support an optional service/workload-level deny-all values block that defaults to disabled.
- **FR-002**: When service-level deny-all is enabled and NetworkPolicy rendering is enabled, the chart MUST render a Kubernetes `NetworkPolicy` that selects only the configured workload pods.
- **FR-003**: The service-level NetworkPolicy MUST deny both inbound and outbound traffic by including `Ingress` and `Egress` policy types without allow rules.
- **FR-004**: When service-level deny-all is enabled and Istio rendering is enabled, the chart MUST render an Istio `AuthorizationPolicy` that selects only the configured workload pods and denies inbound mesh traffic by default.
- **FR-005**: The service-level deny-all selector MUST default to `app.kubernetes.io/name: <workload>`.
- **FR-006**: The service-level deny-all values MUST allow selector override for services whose pods use different labels.
- **FR-007**: Service-level deny-all MUST NOT enable or alter namespace-wide deny-all resources.
- **FR-008**: Existing `allowTo[].service`, `allowTo[].hosts`, and `allowTo[].ips` behavior MUST remain compatible.
- **FR-009**: The chart MUST document the new values in `charts/zero-trust-mesh/values.yaml` and `charts/zero-trust-mesh/README.md`.
- **FR-010**: The repository MUST include a runnable example under `examples/zero-trust-mesh/`.
- **FR-011**: The change MUST include a render check that fails against the previous chart and passes after implementation.
- **FR-012**: The affected chart version MUST be bumped according to repository constitution requirements.

### Key Entities

- **Service-level deny-all option**: A values block that enables deny-all behavior for the current workload only.
- **Workload selector**: The labels used by generated policies to select the service pods.
- **Service deny-all NetworkPolicy**: A workload-scoped Kubernetes policy with both ingress and egress policy types and no allow rules.
- **Service default-deny AuthorizationPolicy**: A workload-scoped Istio policy that establishes default-deny inbound mesh behavior for the selected workload.

### Assumptions

- Kubernetes NetworkPolicy is additive, so later allow policies can open specific traffic for the same selected pods.
- Istio AuthorizationPolicy default-deny behavior can be established for a selected workload without using a DENY action that would block later ALLOW policies.
- Outbound traffic denial is enforced by Kubernetes NetworkPolicy in this chart; Istio AuthorizationPolicy is used for inbound mesh authorization.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Rendering the service-level deny-all test fixture produces exactly workload-scoped deny resources and no namespace-wide deny-all resource.
- **SC-002**: Rendered service-level NetworkPolicy contains both `Ingress` and `Egress` policy types.
- **SC-003**: Rendered service-level deny resources select the intended workload labels.
- **SC-004**: Existing zero-trust-mesh examples render successfully after the change.
- **SC-005**: `helm lint ./charts/zero-trust-mesh` completes with 0 failed charts.
- **SC-006**: A reviewer can locate the new values shape in README, `values.yaml`, and a runnable example in under 5 minutes.
