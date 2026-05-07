# Feature Specification: Zero Trust Target Pod Labels

**Feature Branch**: `012-zero-trust-target-pod-labels`  
**Created**: 2026-05-07  
**Status**: Draft  
**Input**: User description: "support targetpodlabels because sometimes AuthorizationPolicy doesn't find match with app.kubernetes.io/name: {{ .service }} labels"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Select target workloads by custom pod labels (Priority: P1)

As a zero-trust-mesh chart consumer, I can configure a service allow rule with the labels that are actually present on the target pods, so the generated Istio AuthorizationPolicy and Kubernetes NetworkPolicy apply to the intended workload.

**Why this priority**: The existing hardcoded `app.kubernetes.io/name: <service>` target selector can miss workloads that use a different label convention, leaving intended allow rules ineffective.

**Independent Test**: Render `charts/zero-trust-mesh` with an `allowTo` service entry that includes `targetPodLabels`, then verify both the NetworkPolicy `spec.podSelector.matchLabels` and AuthorizationPolicy `spec.selector.matchLabels` contain those labels.

**Acceptance Scenarios**:

1. **Given** an `allowTo` service rule with `targetPodLabels.app: backend`, **When** the chart is rendered, **Then** the generated NetworkPolicy selects target pods with `app: backend`.
2. **Given** the same `allowTo` service rule, **When** the chart is rendered, **Then** the generated AuthorizationPolicy selects target workloads with `app: backend`.

---

### User Story 2 - Preserve default selector behavior (Priority: P2)

As an existing chart consumer, I can omit `targetPodLabels` and continue receiving the previous target selector based on `app.kubernetes.io/name: <service>`.

**Why this priority**: Existing values files and releases must keep rendering the same selector unless they opt into the new override.

**Independent Test**: Render the chart with existing/default values and confirm service allow rules still render target selectors using `app.kubernetes.io/name: <service>`.

**Acceptance Scenarios**:

1. **Given** an `allowTo` service rule without `targetPodLabels`, **When** the chart is rendered, **Then** both generated policies continue to select `app.kubernetes.io/name: <service>`.

---

### User Story 3 - Discover the new selector option (Priority: P3)

As a chart consumer, I can find a documented values example for `targetPodLabels` and run a Helm render command that demonstrates the resulting selectors.

**Why this priority**: The value is only useful if users can discover the shape and verify the rendered output without reading templates.

**Independent Test**: Follow the example under `examples/zero-trust-mesh/` and render it successfully with Helm.

**Acceptance Scenarios**:

1. **Given** the documented example values file, **When** a user runs its top-line Helm command, **Then** the chart renders successfully and includes the custom target labels.

### Edge Cases

- `targetPodLabels` is omitted: the chart must use the existing `app.kubernetes.io/name: <service>` fallback.
- `targetPodLabels` contains multiple labels: all labels must be rendered, and Kubernetes/Istio will treat them as an AND selector.
- `targetPodLabels` is provided only on one service rule: only that rule uses the override; other service rules keep the fallback.
- Host-only `allowTo` entries do not have target pods and must ignore `targetPodLabels`.
- Empty or null `targetPodLabels` must not render an empty selector override; the chart should fall back to the default service label selector.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The chart MUST support optional `allowTo[].targetPodLabels` as a map of string label keys to string label values on service allow rules.
- **FR-002**: When `targetPodLabels` is set, generated Kubernetes NetworkPolicy resources MUST use it in `spec.podSelector.matchLabels`.
- **FR-003**: When `targetPodLabels` is set, generated Istio AuthorizationPolicy resources MUST use it in `spec.selector.matchLabels`.
- **FR-004**: When `targetPodLabels` is omitted, empty, or null, generated policies MUST keep the existing fallback selector `app.kubernetes.io/name: <service>`.
- **FR-005**: The new selector option MUST NOT change source workload selectors, source service account principals, destination namespace handling, ports, methods, or paths.
- **FR-006**: The chart MUST document `targetPodLabels` in `charts/zero-trust-mesh/values.yaml` and `charts/zero-trust-mesh/README.md`.
- **FR-007**: The repository MUST include a runnable example under `examples/zero-trust-mesh/` that demonstrates custom target pod labels.
- **FR-008**: The change MUST include a render check that fails against the previous hardcoded selector behavior and passes after implementation.
- **FR-009**: The affected chart version MUST be bumped according to repository constitution requirements.

### Key Entities *(include if feature involves data)*

- **Service allow rule**: An `allowTo` entry containing `service`, optional routing/security filters, and optional `targetPodLabels`.
- **Target pod labels**: A user-provided label map that identifies destination pods/workloads for the generated NetworkPolicy and AuthorizationPolicy.
- **Rendered policy target selector**: The final `matchLabels` block emitted into Kubernetes and Istio policy manifests.

### Assumptions

- Target pods already carry the labels provided in `targetPodLabels`.
- `targetPodLabels` is intended only for target workload selection, not Kubernetes Service selection.
- Existing `service` remains required for service rules and is still used for generated names and target service account fallback.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Rendering the target-pod-labels example produces both NetworkPolicy and AuthorizationPolicy target selectors with the configured custom labels.
- **SC-002**: Rendering default values still produces `app.kubernetes.io/name: backend` for the existing sample service rule.
- **SC-003**: `helm lint ./charts/zero-trust-mesh` completes with 0 failed charts.
- **SC-004**: A reviewer can locate the new value shape in README and values comments in under 5 minutes.
