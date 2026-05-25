# Data Model: Service-Level Deny All

## ServiceDenyAllConfig

Values object that controls workload-scoped deny-all behavior.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `enabled` | boolean | no | Enables service/workload-level deny-all resources. Defaults to `false`. |
| `podLabels` | map[string]string | no | Selector labels for the workload pods. Defaults to `app.kubernetes.io/name: <workload>`. |

## WorkloadSelector

The pod labels used by generated policies.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `matchLabels` | map[string]string | yes | Kubernetes and Istio workload selector labels. |

## ServiceDenyAllNetworkPolicy

One Kubernetes NetworkPolicy rendered when `serviceDenyAll.enabled` is true and `networkPolicy.enabled` is not false.

Key fields:

- `metadata.namespace`: workload namespace
- `spec.podSelector.matchLabels`: service-level workload selector
- `spec.policyTypes`: `Ingress` and `Egress`
- no `spec.ingress` or `spec.egress` allow rules

## ServiceDenyAllAuthorizationPolicy

One Istio AuthorizationPolicy rendered when `serviceDenyAll.enabled` is true and `istio.enabled` is not false.

Key fields:

- `metadata.namespace`: workload namespace
- `spec.selector.matchLabels`: service-level workload selector
- no allow rules, establishing default-deny inbound behavior for selected workload
