# Data Model: Zero Trust Target Pod Labels

## ServiceAllowRule

Represents a service entry in `allowTo`.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `service` | string | yes | Destination service/workload identity used for generated names and default service account fallback |
| `namespace` | string | no | Destination namespace; defaults to source/release namespace |
| `targetPodLabels` | map<string,string> | no | Target pod/workload selector override for generated policies |
| `serviceAccount` | string | no | Target service account override for policy name generation |
| `port` | integer | no | NetworkPolicy destination port; defaults to `8080` |
| `protocol` | string | no | NetworkPolicy protocol; defaults to `TCP` |
| `methods` | list<string> | no | AuthorizationPolicy HTTP method filters |
| `paths` | list<string> | no | AuthorizationPolicy HTTP path filters |

## TargetPodLabels

Label map used to select destination pods/workloads.

Rules:

- When non-empty, render all key/value pairs under NetworkPolicy `spec.podSelector.matchLabels`.
- When non-empty, render all key/value pairs under AuthorizationPolicy `spec.selector.matchLabels`.
- When omitted, empty, or null, use fallback label `app.kubernetes.io/name: <service>`.
- The map must contain labels that exist on the destination pods in the destination namespace.

Example:

```yaml
allowTo:
  - service: backend
    targetPodLabels:
      app: backend
      component: api
```

## RenderedPolicyTargetSelector

The output selector block generated for each service allow rule.

Custom selector output:

```yaml
matchLabels:
  app: backend
  component: api
```

Fallback selector output:

```yaml
matchLabels:
  app.kubernetes.io/name: backend
```
