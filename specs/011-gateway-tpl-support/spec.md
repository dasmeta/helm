# Feature Specification: Gateway API tpl Support

**Feature Branch**: `011-gateway-tpl-support`  
**Created**: 2026-04-14  
**Status**: Draft  
**Input**: User description: "in dasmeta/helm repo gateway-api we need to add template tpl ability( right now for hostnames) in httproute and istio authorizationpolicy/envoyfilter objects, did already changes in @dasmeta/helm/charts/gateway-api/templates/httproute.yaml:50-51 @dasmeta/helm/charts/gateway-api/templates/istio/envoyfilter.yaml:101-102 @dasmeta/helm/charts/gateway-api/templates/istio/authorizationpolicy.yaml:106-107 and seems all works as expected, did tests with dasmeta/helm/examples/gateway-api/with-istio-envoyfilter-direct-response.yaml, we need also to add specs and do relevant tests/checks and add docs/examples"

## Clarifications

### Session 2026-04-14

- Q: What should the feature version prefix be for this specification and branch? → A: 011.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Render templated route and policy values (Priority: P1)

As a chart consumer, I can provide templated values for HTTPRoute hostnames and Istio policy/filter blocks so one values file can adapt to different release contexts.

**Why this priority**: This is the core behavior change and delivers immediate value for reusable chart configuration.

**Independent Test**: Render the chart with templated values in the target fields and verify rendered manifests contain resolved values for each object.

**Acceptance Scenarios**:

1. **Given** a release values file with templated HTTPRoute hostnames, **When** the chart is rendered, **Then** hostnames are resolved to concrete values in the output manifest.
2. **Given** a release values file with templated AuthorizationPolicy rules and EnvoyFilter config patches, **When** the chart is rendered, **Then** those blocks are resolved and emitted as valid manifests.

---

### User Story 2 - Preserve existing static behavior (Priority: P2)

As a chart consumer using static values, I can continue rendering manifests without behavioral regression.

**Why this priority**: Backward compatibility is required for existing users and prevents rollout risk.

**Independent Test**: Render existing examples that use static values and verify output remains valid and equivalent for unaffected fields.

**Acceptance Scenarios**:

1. **Given** static values for hostnames, AuthorizationPolicy rules, and EnvoyFilter config patches, **When** the chart is rendered, **Then** output remains valid and consistent with prior behavior.

---

### User Story 3 - Discover and adopt new capability (Priority: P3)

As a chart consumer, I can learn from docs/examples how to supply templated values in the newly supported fields.

**Why this priority**: Documentation and examples make the feature usable without trial-and-error.

**Independent Test**: Follow documented example input and verify the rendered output demonstrates successful templating in each supported field.

**Acceptance Scenarios**:

1. **Given** updated examples and documentation, **When** a user follows the documented pattern, **Then** they can render manifests with templated values in all supported fields on first attempt.

### Edge Cases

- Templated expressions resolve to empty arrays or empty objects; rendering must still produce valid YAML or omit empty sections safely.
- Template expressions reference missing values; rendering must fail clearly rather than producing silently broken manifests.
- Mixed static and templated entries are provided in the same list/object; rendering must resolve templates while preserving static entries.
- Multi-line templated YAML content is used in policy/filter blocks; rendered indentation must remain valid for downstream consumers.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST support templated expressions in HTTPRoute `hostnames` values.
- **FR-002**: The system MUST support templated expressions in Istio AuthorizationPolicy `rules` values.
- **FR-003**: The system MUST support templated expressions in Istio EnvoyFilter `configPatches` values.
- **FR-004**: The system MUST continue to accept and correctly render static (non-templated) values for all existing fields.
- **FR-005**: The system MUST render valid manifests when templated values resolve successfully.
- **FR-006**: The system MUST fail with a clear render-time error when templated expressions cannot be resolved.
- **FR-007**: The project MUST include or update automated checks that validate successful rendering for templated and non-templated cases.
- **FR-008**: The project MUST include updated user-facing examples showing templated usage for HTTPRoute, AuthorizationPolicy, and EnvoyFilter fields.
- **FR-009**: The project MUST include documentation updates that explain where templating is supported and how users can verify output.

### Key Entities *(include if feature involves data)*

- **Route hostname configuration**: User-provided list for HTTPRoute host matching that can include static values or template expressions.
- **Authorization rule configuration**: User-provided policy rules that can include static structures or template expressions.
- **Filter patch configuration**: User-provided Envoy filter patch definitions that can include static structures or template expressions.
- **Rendered manifest output**: Final YAML manifests used for deployment and validation by chart consumers.

### Assumptions

- Consumers already use the chart rendering workflow and have access to release context values referenced by templates.
- Existing example files are the preferred place to demonstrate templating usage for this chart.
- Existing validation commands/checks can be extended to cover the new scenarios without introducing a new tooling stack.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of provided templated examples for the three supported fields render into valid deployment manifests during project checks.
- **SC-002**: 100% of existing static-value examples for these objects continue to render successfully after this change.
- **SC-003**: A chart consumer can configure templated values for all three supported fields and produce expected rendered values in one render attempt.
- **SC-004**: Documentation and examples for this feature are sufficient for a reviewer unfamiliar with the change to reproduce successful templated rendering in under 15 minutes.
