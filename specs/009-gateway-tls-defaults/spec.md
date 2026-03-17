# Feature Specification: Gateway TLS Defaults for HTTPS Listeners

**Feature Branch**: `[009-gateway-tls-defaults]`  
**Created**: 2026-03-16  
**Status**: Draft  
**Input**: User description: "for dasmeta/helm have simplfification for gateway-api helm chart gatways https listeneers to get  tls automaticaly set if it is not passed, something like this; behavior B, but only if the tls object passed is completely empty/null"

## Clarifications

### Session 2026-03-16

- Q: Which listener protocols should support TLS configuration and defaulting? → A: Both `HTTPS` and `TLS`. Gateway API allows `protocol: TLS` to have a `tls` block (e.g. for passthrough); the chart must apply the same defaulting and passthrough behavior for HTTPS and TLS protocols, not only HTTPS.
- Q: Must there be a way to have an HTTPS (or TLS) listener with no `tls` block in the rendered manifest (e.g. TLS handled in the pod)? → A: Yes. Use `tls: {}` (empty object) as the explicit opt-out: when the user sets `tls: {}`, the chart MUST NOT render a `tls` block for that listener. No separate field (e.g. `tlsOmit: true`); absent `tls` means apply default, `tls: {}` means omit.

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Simplified HTTPS gateway configuration (Priority: P1)

Platform engineers defining `gateway-api` resources for EKS want HTTPS listeners to automatically receive a sensible TLS configuration so that they do not need to manually specify `tls` for common cases.

**Why this priority**: This removes repetitive, error‑prone manual TLS configuration for each HTTPS listener and standardizes how TLS secrets are named and referenced across environments.

**Independent Test**: Can be fully tested by configuring a Gateway with an HTTPS listener that omits `tls`, applying the rendered manifest to a cluster, and verifying that it terminates TLS using a Secret named `{gateway-name}-tls`.

**Acceptance Scenarios**:

1. **Given** a Gateway in Helm values with `protocol = "HTTPS"` and no `tls` field, **When** the chart is rendered, **Then** the resulting `Gateway.spec.listeners[].tls` is present with `mode: Terminate` and a single `certificateRefs` entry referencing Secret `{gateway-name}-tls` with `kind: Secret` and `group: ""`.
2. **Given** a Gateway with `name = "main-internal"` and an HTTPS listener without `tls`, **When** the chart is rendered, **Then** the corresponding listener uses `certificateRefs[0].name = "main-internal-tls"`.

---

### User Story 2 - Preserve explicit TLS configuration (Priority: P2)

Platform engineers sometimes need full control over TLS settings for specific listeners and want the chart to respect explicit `tls` configuration when they provide it.

**Why this priority**: Overriding user‑provided TLS configuration would be surprising and could break advanced setups, so the defaulting behavior must never interfere when `tls` is intentionally configured.

**Independent Test**: Can be fully tested by defining an HTTPS listener with a non‑empty `tls` block and verifying that the rendered manifest matches the provided TLS configuration exactly.

**Acceptance Scenarios**:

1. **Given** an HTTPS listener with a `tls` block that includes at least one non‑empty field (for example, a `certificateRefs` entry or a custom `mode`), **When** the chart is rendered, **Then** the `tls` block in the manifest is identical (semantically) to what was provided in values with no additional defaults injected.

---

### User Story 3 - Default when tls is absent (Priority: P3)

When `tls` is omitted (key not set) for an HTTPS or TLS listener, the chart applies the default TLS configuration.

**Why this priority**: Ensures the common case—no `tls` key—gets a valid default without requiring users to set `tls: {}` for opt-out.

**Independent Test**: Define an HTTPS listener with no `tls` field; rendered manifest has defaulted `tls` (e.g. Terminate + `{gateway-name}-tls` for HTTPS).

**Acceptance Scenarios**:

1. **Given** an HTTPS listener with the `tls` key absent, **When** the chart is rendered, **Then** the listener’s `tls` block is defaulted (Terminate mode with `{gateway-name}-tls` Secret reference for HTTPS).

---

### User Story 4 - Explicit opt-out with tls: {} (Priority: P4)

When TLS/SSL is handled in the pod (or elsewhere), platform engineers set `tls: {}` on an HTTPS or TLS listener so that no gateway-level `tls` block is rendered.

**Why this priority**: Default TLS is a convenience only; the chart must not force gateway-terminated TLS for every HTTPS/TLS listener. Using `tls: {}` (empty object) is the documented opt-out—no separate field.

**Independent Test**: Set `tls: {}` on an HTTPS listener and render; the listener in the manifest has no `tls` field.

**Acceptance Scenarios**:

1. **Given** an HTTPS (or TLS) listener with `tls: {}`, **When** the chart is rendered, **Then** that listener has no `tls` block in the output.

### Edge Cases

- What happens when a Gateway has multiple HTTPS listeners with different `name` values?  
  - Each listener must compute its TLS Secret name independently based on the effective Gateway name (e.g., `{gateway-name}-tls`), and the defaulting must not conflict across listeners.
- How does the system handle non‑HTTPS/non‑TLS protocols (e.g., HTTP, TCP)?  
  - Listeners with protocols other than `HTTPS` and `TLS` MUST NOT receive any automatic TLS configuration. Listeners with `protocol: TLS` MUST be supported for TLS configuration (defaulting when empty, passthrough when non-empty, opt-out when explicitly requested) in the same way as HTTPS.
- What happens if the generated `{gateway-name}-tls` Secret does not exist in the target namespace?  
  - The chart still renders successfully, and it is the caller’s responsibility (e.g., via cert‑manager or Terraform) to provision the Secret; this behavior should be documented but not validated by the chart.
- How are “absent”, “opt-out”, and “non-empty” distinguished for `tls`?  
  - **Absent** (key not set): apply default TLS. **Opt-out**: `tls: {}` (empty object) means “do not render a `tls` block” (e.g. TLS handled in the pod). **Non-empty**: `tls` with any properties (e.g. `mode`, `certificateRefs`) is rendered as provided. No separate field; `tls: {}` is the only opt-out.
- Explicit opt-out: When the user sets `tls: {}` on an HTTPS or TLS listener, the chart MUST NOT render a `tls` block for that listener.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The specification MUST define that for any Gateway listener with `protocol = \"HTTPS\"` or `protocol = \"TLS\"` and no explicit opt-out, when `tls` is absent or effectively empty, the chart will render a `tls` block (for HTTPS: `mode = \"Terminate\"` and a single `certificateRefs` entry referencing a Secret named `{gateway-name}-tls` with `kind = \"Secret\"` and `group = \"\"`; for TLS protocol the default structure follows Gateway API and implementation).
- **FR-002**: The specification MUST define that `{gateway-name}` used in the generated TLS Secret name is derived from the effective Gateway metadata name (including any name overrides or suffixes applied by the chart).
- **FR-003**: The specification MUST define that when an HTTPS or TLS listener’s `tls` key is absent, the chart applies the defaulted TLS configuration. When `tls: {}` is set, the chart treats it as explicit opt-out and does not render a `tls` block.
- **FR-004**: The specification MUST define that when an HTTPS or TLS listener’s `tls` field is non‑empty (contains any non‑default data such as a custom `mode` or `certificateRefs`), the chart MUST render the TLS configuration exactly as provided without injecting or overriding values.
- **FR-005**: The specification MUST define that listeners with protocols other than `HTTPS` and `TLS` (e.g., `HTTP`, `TCP`) MUST NOT receive any automatic TLS configuration regardless of whether `tls` is omitted or empty.
- **FR-006**: The specification MUST define that when the user sets `tls: {}` (empty object) on an HTTPS or TLS listener, the chart MUST NOT render a `tls` block for that listener (explicit opt-out; e.g. TLS handled in the pod). No separate opt-out field; `tls: {}` is the documented way to omit gateway-level TLS.

### Key Entities *(include if feature involves data)*

- **Gateway definition (values.gateways)**: Represents the configuration object used to render `Gateway` resources, including gateway name, listeners, and any annotations that might drive certificate provisioning.
- **HTTPS/TLS listener configuration**: Represents individual listener entries under a Gateway (name, port, protocol, hostname, optional `tls`). Protocol `HTTPS` or `TLS` determines when TLS applies. Absent `tls` → default; `tls: {}` → opt-out (no block); non-empty `tls` → rendered as-is.
- **TLS Secret name pattern**: Conceptual entity describing the naming convention `{gateway-name}-tls` that ties Gateways to their corresponding TLS Secrets, regardless of how the Secret is provisioned (e.g., via cert‑manager or Terraform).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 80% of new HTTPS listeners defined in `gateway-api` Helm values in typical environments are configured without explicitly setting `tls` while still resulting in valid terminating TLS at runtime.
- **SC-002**: In internal platform usage, configuration errors related to missing or misnamed TLS Secrets for Gateways decrease by at least 50% over one quarter after adoption.
- **SC-003**: Platform engineers can configure a new HTTPS Gateway listener (from Helm values to working TLS in the cluster) in under 5 minutes for the default case where `{gateway-name}-tls` is acceptable.
- **SC-004**: No regressions are reported where existing gateways that specify custom `tls` behavior have their TLS configuration altered by the new defaulting logic after upgrade.
