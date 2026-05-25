# Research: Service-Level Deny All

## Decision: Add a dedicated `serviceDenyAll` values block

- **Decision**: Use `serviceDenyAll.enabled` with optional `serviceDenyAll.podLabels`.
- **Rationale**: The chart already has `namespaceResourcesEnabled` for namespace-wide controls and `allowTo` for explicit service/host/IP allows. A dedicated block keeps the new safety switch separate from both concepts.
- **Alternatives considered**:
  - Reuse `namespaceResourcesEnabled`: rejected because the requested behavior must not affect the entire namespace.
  - Add a special `allowTo` entry: rejected because deny-all is a baseline isolation state, not an allow rule.

## Decision: Render service-level deny-all with Kubernetes NetworkPolicy

- **Decision**: Render a NetworkPolicy that selects only the service workload pods and lists both `Ingress` and `Egress` policy types with no rules.
- **Rationale**: Kubernetes NetworkPolicy deny behavior is driven by selecting pods and omitting allow rules. NetworkPolicy is additive, so later allow policies can open explicit paths for the selected pods.
- **Existing repo evidence**: `charts/zero-trust-mesh/templates/networkpolicy-default-deny.yaml` already uses no allow rules for namespace baseline deny-all.

## Decision: Render service-level Istio default deny with AuthorizationPolicy selector

- **Decision**: Render an Istio AuthorizationPolicy with a workload selector and no allow rules when `istio.enabled` is not false.
- **Rationale**: Existing chart baseline uses an empty AuthorizationPolicy to establish default-deny behavior. Adding a selector scopes that behavior to one workload. Avoiding action `DENY` keeps later explicit ALLOW policies usable.
- **Boundary**: Istio AuthorizationPolicy covers inbound authorization. Outbound denial is handled by Kubernetes NetworkPolicy for this feature.

## Decision: Selector override is required

- **Decision**: Default selector is `app.kubernetes.io/name: <workload>`, with `serviceDenyAll.podLabels` override.
- **Rationale**: Existing chart service allow rules support target selector override because real workloads may not use the default label. Service-level deny-all has the same risk and needs an explicit override path.

## Compatibility Notes

- `serviceDenyAll.enabled` defaults to false and renders no resources unless explicitly enabled.
- `namespaceResourcesEnabled` templates are left unchanged.
- Existing `allowTo` service, host, and IP templates are left unchanged.
- `networkPolicy.enabled: false` suppresses the service-level NetworkPolicy.
- `istio.enabled: false` suppresses the service-level AuthorizationPolicy.
