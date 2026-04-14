# Data Model: Gateway API tpl Support

## Entity: Route Hostname Configuration

- **Source**: Chart values under HTTPRoute configuration.
- **Type**: Ordered list of hostname entries.
- **Allowed content**:
  - Static hostnames.
  - Template expressions resolving to hostnames.
- **Validation rules**:
  - Must resolve into YAML list format accepted by HTTPRoute hostnames.
  - Rendered output must remain valid YAML.

## Entity: Authorization Rule Configuration

- **Source**: Chart values under Istio AuthorizationPolicy configuration.
- **Type**: List/object structure matching policy rules schema.
- **Allowed content**:
  - Static rule objects.
  - Template expressions resolving to rule objects or lists.
- **Validation rules**:
  - Must resolve into valid policy rules structure.
  - Missing referenced template values cause render-time failure.

## Entity: Envoy Filter Patch Configuration

- **Source**: Chart values under Istio EnvoyFilter configuration.
- **Type**: List of filter patch objects.
- **Allowed content**:
  - Static patch objects.
  - Template expressions resolving to one or more patch objects.
- **Validation rules**:
  - Must resolve into valid `configPatches` array content.
  - Rendered output must preserve indentation and structure.

## Entity: Rendered Manifest Output

- **Produced by**: `helm template` over chart + values.
- **Consumers**: Operators applying manifests to Kubernetes.
- **Quality constraints**:
  - Valid YAML document structure.
  - Correct field placement in HTTPRoute, AuthorizationPolicy, EnvoyFilter objects.
  - No behavior regression for static-only values.
