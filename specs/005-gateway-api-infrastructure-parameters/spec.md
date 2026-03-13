# Feature Specification: Gateway API — Infrastructure Parameters (ConfigMap from values)

**Feature Branch**: `005-gateway-api-infrastructure-parameters`  
**Created**: 2026-03-13  
**Status**: Draft  
**Input**: User description: "for dasmeta/helm repo for gateway-api helm chart gateway objects want to create ability to pass infrastructure.parameters option which will automatically create config-map based on passed configs of service, deployment, serviceAccount, horizontalPodAutoscaler, podDisruptionBudget and auto-attach it to gateway by infrastructure.parametersRef attribute, so that no need to create the config map in separate and attach via gateway standard infrastructure.parametersRef attribute. We still should preserve the default infrastructure.parametersRef ability also in case we want to manually create config-map and attach it via that option. We should be able to pass both object and string in each of infrastructure.parameters following items service, deployment, serviceAccount, horizontalPodAutoscaler, podDisruptionBudget but preferred way will be object which will be translated to yaml string in background to correspond specification."

## Clarifications

### Session 2026-03-13

- Q: ConfigMap naming formula — deterministic name (release vs gateway-only vs chart fullname helper + suffix)? → A: Option C — Chart fullname helper + suffix (e.g. `include "gateway-api.fullname"` + `-infra-` + gateway name).
- Q: If a parameter key is set to an empty string (e.g. `service: ""`), include key with empty value or treat as omitted? → A: Option B — Treat empty string as omitted; do not add the key to ConfigMap data.
- Q: How to handle non-object, non-string types (e.g. number, boolean) in parameter values? → A: Option A — Treat any non-string value (object, number, boolean, list) as serialize-to-YAML (same as object; use toYaml).
- Q: Should the spec explicitly call out out-of-scope items? → A: Option A — Yes, add a short "Out of scope" subsection.
- Q: On upgrade when parameters change, how should the generated ConfigMap be updated? → A: Option A — Standard Helm replace: ConfigMap is re-rendered from current values on upgrade; Helm replaces the resource (no special merge).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Declarative infrastructure config via parameters (Priority: P1)

As a chart consumer, I want to set `gateways[].infrastructure.parameters` with per-resource configs (service, deployment, serviceAccount, horizontalPodAutoscaler, podDisruptionBudget) so that the chart creates a ConfigMap from those configs and attaches it to the Gateway via `infrastructure.parametersRef`, without creating or referencing a ConfigMap manually.

**Why this priority**: Core value: single place (values) to define infrastructure parameters and automatic wiring.

**Independent Test**: Set `infrastructure.parameters` with at least one key (e.g. `service`), install/upgrade the chart, then verify a ConfigMap exists in the gateway namespace with the expected data keys and that the rendered Gateway manifest has `spec.infrastructure.parametersRef` pointing to that ConfigMap.

**Acceptance Scenarios**:

1. **Given** a gateway with `infrastructure.parameters.service` (object or string), **When** the chart is rendered, **Then** a ConfigMap is emitted with a `service` key whose value is the YAML string for that config, and the Gateway has `spec.infrastructure.parametersRef` referencing that ConfigMap (name/namespace).
2. **Given** `infrastructure.parameters` with multiple keys (e.g. service, deployment, serviceAccount), **When** the chart is rendered, **Then** the generated ConfigMap has all corresponding data keys and the Gateway’s `parametersRef` points to it.
3. **Given** a value is provided as an object (e.g. `service: { type: LoadBalancer }`), **When** the chart is rendered, **Then** the ConfigMap data entry for that key is the YAML string representation of that object.

---

### User Story 2 - Object vs string input for each parameter (Priority: P1)

As a chart consumer, I want to supply each of service, deployment, serviceAccount, horizontalPodAutoscaler, podDisruptionBudget either as an object (preferred) or as a string (raw YAML), so that I can choose the most convenient form; objects are converted to YAML strings internally to match the Gateway API / implementation expectation.

**Why this priority**: Flexibility and ergonomics are part of the feature promise.

**Independent Test**: Render the chart with one parameter as object and another as string; confirm ConfigMap data values are correct YAML strings in both cases.

**Acceptance Scenarios**:

1. **Given** `infrastructure.parameters.deployment` is an object (e.g. `replicas: 2`), **When** the chart is rendered, **Then** the ConfigMap’s `deployment` key contains the YAML-serialized string of that object.
2. **Given** `infrastructure.parameters.service` is a string (e.g. `"type: ClusterIP\nports: []"`), **When** the chart is rendered, **Then** the ConfigMap’s `service` key contains that string as-is (no double-serialization).
3. **Given** a key is omitted from `infrastructure.parameters`, **When** the chart is rendered, **Then** that key does not appear in the ConfigMap data.

---

### User Story 3 - Preserve manual parametersRef (Priority: P1)

As a chart consumer, I want to keep using `gateways[].infrastructure.parametersRef` to reference a manually created ConfigMap when I do not use `infrastructure.parameters`, so that existing workflows and external ConfigMaps remain supported.

**Why this priority**: Backward compatibility and manual control are required.

**Independent Test**: Configure a gateway with only `infrastructure.parametersRef` (no `parameters`); no ConfigMap should be created for that gateway, and the rendered Gateway must have the given `parametersRef`.

**Acceptance Scenarios**:

1. **Given** a gateway with `infrastructure.parametersRef` set and `infrastructure.parameters` not set, **When** the chart is rendered, **Then** no ConfigMap is created for this gateway and the Gateway spec contains exactly the provided `parametersRef`.
2. **Given** a gateway with neither `parametersRef` nor `parameters`, **When** the chart is rendered, **Then** the Gateway has no `parametersRef` (or infrastructure block only has annotations/labels if present).
3. **Given** a gateway with both `parametersRef` and `parameters` set, **When** the chart is rendered, **Then** behavior is well-defined (see Requirements: either parameters win and override parametersRef, or one is forbidden; spec chooses one).

---

### User Story 4 - ConfigMap naming and namespace (Priority: P2)

As a chart consumer, I want the auto-created ConfigMap to live in the same namespace as the Gateway and have a deterministic name (e.g. derived from gateway name/release) so that I can predict and reference it if needed.

**Why this priority**: Operational clarity and debugging.

**Independent Test**: Deploy with `infrastructure.parameters` and verify ConfigMap namespace and name match documentation: same namespace as Gateway, name = chart fullname + `-infra-` + gateway name.

**Acceptance Scenarios**:

1. **Given** a gateway with `infrastructure.parameters` and namespace `istio-system`, **When** the chart is rendered, **Then** the generated ConfigMap is in namespace `istio-system`.
2. **Given** two gateways with `infrastructure.parameters`, **When** the chart is rendered, **Then** each gateway gets a distinct ConfigMap (no name collision).

---

### Edge Cases

- What happens when both `infrastructure.parametersRef` and `infrastructure.parameters` are set? **Requirement**: Chart MUST treat `parameters` as the source of truth when present; generate ConfigMap and set `parametersRef` to it, ignoring any user-supplied `parametersRef` for that gateway (i.e. parameters override).
- What happens when `infrastructure.parameters` is set but all keys are empty/omitted? Option A: Do not create a ConfigMap and do not set parametersRef. Option B: Create an empty ConfigMap. **Recommendation**: Do not create ConfigMap; do not set parametersRef (no-op).
- What if a value is both a valid object and a string that looks like YAML? Treat by type: string → use as-is; non-string (object, number, boolean, list) → toYaml.
- Empty string: a parameter key set to `""` is treated as omitted; the key MUST NOT appear in the generated ConfigMap (so “non-empty” for FR-002 excludes empty strings).
- Namespace for ConfigMap: MUST be the same as the Gateway’s namespace (derived from gateway namespace or defaults).

## Out of scope

- **Validation of parameter content**: The chart does not validate that the YAML (string or serialized) conforms to Service, Deployment, or other Kubernetes resource schemas; consumption is implementation-specific (e.g. Gateway controller).
- **Additional parameter keys**: Only the five keys (`service`, `deployment`, `serviceAccount`, `horizontalPodAutoscaler`, `podDisruptionBudget`) are supported; no custom or extra keys in this feature.
- **Versioned backward compatibility**: No separate versioning or migration for existing `parametersRef`-only usage; existing behavior is preserved by FR-006.
- **Upgrade behavior**: On release upgrade, the generated ConfigMap is re-rendered from current `infrastructure.parameters` and Helm replaces the resource (standard Helm replace; no special merge or retention).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The chart MUST support a new optional key `gateways[].infrastructure.parameters` whose value is an object with optional keys: `service`, `deployment`, `serviceAccount`, `horizontalPodAutoscaler`, `podDisruptionBudget`.
- **FR-002**: When `infrastructure.parameters` is present and non-empty (at least one key with a non-empty value), the chart MUST emit a ConfigMap resource whose `data` keys are the same as the keys present in `parameters` with non-empty values; keys whose value is an empty string MUST be treated as omitted and MUST NOT appear in ConfigMap `data`. Each `data` value MUST be a YAML string (see FR-003/FR-004).
- **FR-003**: For each key in `parameters`, if the value is a string, the chart MUST use that string as-is as the ConfigMap `data` value for that key (no extra toYaml). For any other type (object/dict, number, boolean, list), the chart MUST serialize it to a YAML string (e.g. via `toYaml`) and use that as the ConfigMap `data` value.
- **FR-004**: (Consolidated with FR-003.) String → as-is; non-string (object, number, boolean, list) → serialize to YAML string.
- **FR-005**: When a ConfigMap is generated from `parameters`, the chart MUST set the Gateway’s `spec.infrastructure.parametersRef` to reference that ConfigMap (group `""`, kind `ConfigMap`, name and namespace set appropriately).
- **FR-006**: The chart MUST preserve support for `gateways[].infrastructure.parametersRef`. When `parameters` is not set, the rendered Gateway MUST use the user-provided `parametersRef` unchanged (if provided).
- **FR-007**: When both `parametersRef` and `parameters` are set for a gateway, the chart MUST ignore the user-supplied `parametersRef` and MUST generate the ConfigMap from `parameters` and set `parametersRef` to the generated ConfigMap (parameters take precedence).
- **FR-008**: The generated ConfigMap MUST be in the same namespace as the Gateway.
- **FR-009**: The generated ConfigMap MUST have a deterministic name: the chart’s fullname helper plus suffix `-infra-` plus the gateway name (e.g. `{{ include "gateway-api.fullname" . }}-infra-{{ gateway.name }}`), so that multiple gateways with parameters get distinct ConfigMaps and naming aligns with the rest of the chart.
- **FR-010**: When `infrastructure.parameters` is set but all keys are empty or omitted, the chart MUST NOT create a ConfigMap and MUST NOT set `parametersRef` from this feature (existing `parametersRef` from user, if any, remains).

### Key Entities

- **infrastructure.parameters**: User-facing object under `gateways[].infrastructure` with optional keys `service`, `deployment`, `serviceAccount`, `horizontalPodAutoscaler`, `podDisruptionBudget`. Each value is a string (used as-is) or any other type (object, number, boolean, list), which is serialized to a YAML string; all ConfigMap `data` values are YAML strings.
- **Generated ConfigMap**: A ConfigMap created by the chart when `parameters` is non-empty; name is `{fullname}-infra-{gateway.name}`; `data` keys match parameter keys; values are YAML strings. Referenced by the Gateway’s `infrastructure.parametersRef`.
- **infrastructure.parametersRef**: Standard Gateway API field; either user-supplied (manual ConfigMap) or chart-set (when using `parameters`).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can configure infrastructure parameters entirely via `values.yaml` using `infrastructure.parameters` (object or string per key) and get a working Gateway with parametersRef pointing to a chart-generated ConfigMap, without creating any ConfigMap by hand.
- **SC-002**: Existing values that use only `infrastructure.parametersRef` continue to render and behave the same after the change.
- **SC-003**: Helm template validation and `helm lint` pass for the gateway-api chart with the new logic; no duplicate ConfigMap names across gateways in the same release.
