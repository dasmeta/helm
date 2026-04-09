# Feature Specification: Gateway Direct Response Configuration

**Feature Branch**: `010-gateway-direct-response`  
**Created**: 2026-04-08  
**Status**: Draft  
**Input**: User description: "in dasmeta/helm for gateway-api helm chart implement ability for directResponse of any status code and body, the existing 403 status code based on istio authorizationpolicy object remains as it is, but we extend this ability to eny status code and custom body based on istio EnvoyFilter native resource, like we have in this example that I tested works ok @envoy-filter.yaml (1-28) default body will be \"\" empty string, we should not change something in 403 implementation based on authorizationpolicy, we just extend with all other status codes+body ability"

## Clarifications

### Session 2026-04-08

- Q: If both mechanisms could match a request, what should happen? → A: Keep existing AuthorizationPolicy-based 403 behavior and do not allow direct-response override for that case.
- Q: Which HTTP status code range is valid for direct responses? → A: Allow only 200-599 for direct responses.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Configure Custom Direct Responses (Priority: P1)

As a platform engineer, I can configure direct responses for gateway traffic using a chosen HTTP status code and optional body text, so I can enforce custom gateway behavior for blocked or special-case routes without changing upstream services.

**Why this priority**: This is the core business value of the feature and the requested extension beyond the existing 403 behavior.

**Independent Test**: Can be fully tested by applying chart values that define a non-403 response and validating that matching requests return the configured status and body.

**Acceptance Scenarios**:

1. **Given** a gateway route targeted by direct-response settings, **When** the request matches the configured criteria with status `200` and body `"Hello, World!"`, **Then** the response returns status `200` and body `"Hello, World!"`.
2. **Given** a gateway route targeted by direct-response settings, **When** the request matches the configured criteria with status `429` and no body configured, **Then** the response returns status `429` with an empty response body.

---

### User Story 2 - Preserve Existing 403 Authorization Behavior (Priority: P2)

As a platform engineer, I can continue using the existing 403 behavior based on authorization policy exactly as before, so current deployments and security controls are not altered by this feature.

**Why this priority**: Backward compatibility is critical to prevent regressions in production environments.

**Independent Test**: Can be fully tested by deploying existing 403 configuration only and verifying that behavior and outputs remain unchanged from current baseline.

**Acceptance Scenarios**:

1. **Given** a deployment that uses only existing 403 authorization-policy configuration, **When** the chart is upgraded with this feature, **Then** 403 behavior remains unchanged.
2. **Given** both existing 403 authorization-policy settings and new direct-response settings for other status codes, **When** requests trigger the 403 authorization flow, **Then** the existing 403 behavior is preserved.

---

### User Story 3 - Apply Feature Selectively (Priority: P3)

As a platform engineer, I can choose not to configure new direct-response settings and keep current behavior unchanged, so adoption can be incremental across environments.

**Why this priority**: Optional adoption reduces rollout risk and supports phased migration.

**Independent Test**: Can be fully tested by deploying without new settings and confirming no additional direct-response behavior appears.

**Acceptance Scenarios**:

1. **Given** a deployment with no new direct-response configuration, **When** the chart is deployed or upgraded, **Then** no new direct-response rules are introduced.

---

### Edge Cases

- What happens when status code is outside the allowed direct-response range (200-599)? The configuration is rejected before deployment or reported as invalid to prevent ambiguous runtime behavior.
- How does system handle an explicitly empty string body? The response body is empty and valid.
- How does system handle very large response body values? The behavior is documented and validated against accepted limits, with invalid values rejected.
- What happens when new direct-response conditions overlap with existing routing conditions? Precedence is deterministic and documented so outcomes are predictable.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The chart MUST allow users to define direct-response rules that return a configurable HTTP status code.
- **FR-002**: The chart MUST allow users to define an optional direct-response body for each direct-response rule.
- **FR-003**: When the direct-response body is not provided, the system MUST use an empty string as the default response body.
- **FR-004**: The existing 403 behavior based on authorization policy MUST remain unchanged in behavior and output.
- **FR-005**: The feature MUST support status codes other than 403 without requiring changes to existing 403 authorization-policy configuration.
- **FR-006**: If a request could match both existing 403 authorization-policy behavior and a direct-response rule, the existing 403 authorization-policy behavior MUST take precedence.
- **FR-007**: Users MUST be able to enable, disable, or omit the new direct-response configuration independently of existing 403 configuration.
- **FR-008**: Invalid direct-response status code values MUST be detected and surfaced as configuration validation errors.
- **FR-009**: The specification for matching conditions used by direct-response rules MUST be configurable and documented for operators.
- **FR-010**: The valid status code range for direct-response rules MUST be 200-599.

### Key Entities *(include if feature involves data)*

- **Direct Response Rule**: A user-defined gateway response behavior containing matching criteria, HTTP status code, and optional response body.
- **Authorization 403 Policy Behavior**: The pre-existing 403 response path controlled by authorization policy, preserved as a separate and unchanged behavior.
- **Gateway Match Condition**: Criteria used to determine when a direct-response rule applies to an incoming request.

### Assumptions

- Existing 403 authorization-policy workflows are already in production use and are treated as a protected compatibility boundary.
- Direct-response rules are primarily managed by platform engineers through chart values.
- Empty body means a literal empty response payload rather than an omitted field with undefined behavior.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of configured non-403 direct-response scenarios return the exact configured status code in validation tests.
- **SC-002**: 100% of configured direct-response scenarios with an omitted body return an empty response body.
- **SC-003**: 0 regressions are observed in existing 403 authorization-policy behavior across baseline compatibility tests.
- **SC-004**: Platform engineers can configure and validate at least three distinct status-code-and-body combinations in a single release cycle without requiring service code changes.
