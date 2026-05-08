# Feature Specification: Zero Trust IP Egress

**Feature Branch**: `013-zero-trust-ip-egress`  
**Created**: 2026-05-08  
**Status**: Draft  
**Input**: User description: "support IP addresses in zero-trust-mesh chart because applications call destination IPs directly and existing allowTo host/service rules cannot authorize IP egress"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Allow direct destination IP egress (Priority: P1)

As a zero-trust-mesh chart consumer, I can configure an external destination IP address or CIDR in `allowTo`, so workloads that call IPs directly can pass both Istio registry checks and Kubernetes egress policy.

**Why this priority**: This is the requested production blocker. Existing `service` and `hosts` rule types do not represent direct IP calls.

**Independent Test**: Render `charts/zero-trust-mesh` with an `allowTo` entry containing `ips`, then verify the output includes an Istio `ServiceEntry` with `addresses` and `resolution: NONE` plus a Kubernetes egress `NetworkPolicy` using `ipBlock`.

**Acceptance Scenarios**:

1. **Given** an `allowTo` rule with `ips: ["192.0.2.10"]`, **When** the chart is rendered, **Then** the generated ServiceEntry contains address `192.0.2.10/32` and `resolution: NONE`.
2. **Given** the same rule, **When** the chart is rendered, **Then** the generated NetworkPolicy allows egress to `192.0.2.10/32` through `ipBlock`.
3. **Given** an `allowTo` rule with `ips: ["198.51.100.0/24"]`, **When** the chart is rendered, **Then** the CIDR is preserved in both ServiceEntry addresses and NetworkPolicy ipBlock.

---

### User Story 2 - Preserve existing service and host behavior (Priority: P2)

As an existing chart consumer, I can keep using `allowTo[].service` and `allowTo[].hosts` without behavior or rendered output changes caused by the IP egress addition.

**Why this priority**: The new rule type must be opt-in and must not regress existing service-to-service or DNS host egress flows.

**Independent Test**: Render default values and existing target-pod-label test values, then confirm existing service and host resources still render successfully.

**Acceptance Scenarios**:

1. **Given** an existing service allow rule, **When** the chart is rendered, **Then** NetworkPolicy ingress and AuthorizationPolicy output remains valid.
2. **Given** an existing hosts allow rule, **When** the chart is rendered, **Then** DNS ServiceEntry output remains valid and uses `resolution: DNS`.

---

### User Story 3 - Discover and validate the IP egress values shape (Priority: P3)

As a chart consumer, I can find a documented example for IP egress and run a Helm render command to validate the generated manifests before deployment.

**Why this priority**: Direct IP egress changes the public values contract and must be documented with a runnable example.

**Independent Test**: Follow the example under `examples/zero-trust-mesh/ip-egress.yaml` and render it successfully with Helm.

**Acceptance Scenarios**:

1. **Given** the documented IP egress example, **When** a user runs its top-line Helm command, **Then** the chart renders successfully.
2. **Given** a user reads the chart README, **When** they scan the values table, **Then** they can find `allowTo[].ips` and its default/example behavior.

### Edge Cases

- Single IPv4 address without a CIDR suffix is normalized to `/32`.
- Single IPv6 address without a CIDR suffix is normalized to `/128`.
- CIDR input is preserved as provided.
- If `ports` is omitted on an IP rule, the chart uses `443/TCP`.
- Istio protocol names such as `HTTP` or `HTTPS` are allowed on ServiceEntry ports, but Kubernetes NetworkPolicy renders only L4 protocols and maps unsupported protocol names to `TCP`.
- Host-only `allowTo` entries continue to render DNS ServiceEntry resources and do not render IP egress NetworkPolicies.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The chart MUST support optional `allowTo[].ips` as a list of external destination IP addresses or CIDR blocks.
- **FR-002**: For every IP rule, the chart MUST render an Istio `ServiceEntry` in the workload namespace with `spec.addresses` set to the configured IP/CIDR list.
- **FR-003**: IP-rule ServiceEntries MUST use `location: MESH_EXTERNAL` and `resolution: NONE`.
- **FR-004**: For every IP rule, the chart MUST render a Kubernetes `NetworkPolicy` in the workload namespace that selects the source workload and allows egress to each configured IP/CIDR through `ipBlock`.
- **FR-005**: Single IPv4 addresses MUST be rendered as `/32` CIDRs for Kubernetes NetworkPolicy compatibility.
- **FR-006**: Single IPv6 addresses MUST be rendered as `/128` CIDRs for Kubernetes NetworkPolicy compatibility.
- **FR-007**: IP rule `ports` MUST default to `443/TCP` when omitted.
- **FR-008**: IP egress support MUST NOT change existing service allow rule behavior.
- **FR-009**: IP egress support MUST NOT change existing host ServiceEntry behavior.
- **FR-010**: The chart MUST document `allowTo[].ips` in `charts/zero-trust-mesh/values.yaml` and `charts/zero-trust-mesh/README.md`.
- **FR-011**: The repository MUST include a runnable example under `examples/zero-trust-mesh/` that demonstrates IP egress.
- **FR-012**: The change MUST include a render check that fails against the previous chart and passes after implementation.
- **FR-013**: The affected chart version MUST be bumped according to repository constitution requirements.

### Key Entities *(include if feature involves data)*

- **IP egress rule**: An `allowTo` entry containing `ips` and optional `ports`.
- **Normalized IP block**: The CIDR form rendered into both Istio `ServiceEntry.spec.addresses` and Kubernetes `NetworkPolicy.ipBlock.cidr`.
- **IP ServiceEntry**: The Istio registry object that permits direct IP traffic in `REGISTRY_ONLY` meshes.
- **IP egress NetworkPolicy**: The Kubernetes policy that permits selected source workload pods to connect to configured destination IP blocks.

### Assumptions

- Direct IP egress targets are external to the Kubernetes service-to-service rules managed by `allowTo[].service`.
- Consumers are responsible for providing valid IP addresses or CIDR blocks.
- IP egress does not use the existing DNS/SNI egress gateway routing path.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Rendering the IP egress test fixture produces a ServiceEntry with every configured IP/CIDR in `spec.addresses`.
- **SC-002**: Rendering the IP egress test fixture produces a NetworkPolicy with every configured IP/CIDR in `egress[].to[].ipBlock.cidr`.
- **SC-003**: Rendering default chart values completes successfully and keeps existing service and host outputs valid.
- **SC-004**: `helm lint ./charts/zero-trust-mesh` completes with 0 failed charts.
- **SC-005**: A reviewer can locate the new `allowTo[].ips` values shape in README, `values.yaml`, and a runnable example in under 5 minutes.
