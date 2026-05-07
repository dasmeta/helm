# Render Contract: targetPodLabels

## Input Contract

The chart accepts optional `targetPodLabels` on `allowTo` entries that also set `service`.

```yaml
allowTo:
  - service: backend
    namespace: default
    targetPodLabels:
      app: backend
      component: api
    port: 8080
```

Host-only entries do not use this contract:

```yaml
allowTo:
  - hosts: ["api.example.com"]
```

## Output Contract

When `targetPodLabels` is non-empty, both generated policy resources for that service rule must use the custom labels.

NetworkPolicy:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
spec:
  podSelector:
    matchLabels:
      app: backend
      component: api
```

AuthorizationPolicy:

```yaml
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
spec:
  selector:
    matchLabels:
      app: backend
      component: api
```

When `targetPodLabels` is omitted, empty, or null, both resources must keep the fallback selector:

```yaml
matchLabels:
  app.kubernetes.io/name: backend
```

## Non-Goals

- Do not change Kubernetes Service selectors.
- Do not change source workload selection.
- Do not add `matchExpressions`.
- Do not change AuthorizationPolicy principals, methods, paths, or generated names except where existing values already control them.

## Failure Semantics

Helm rendering should fail normally if `targetPodLabels` is not a YAML map that `toYaml` can serialize. The chart does not validate whether those labels exist in the cluster; Kubernetes/Istio apply-time and analysis tooling remain responsible for live workload matching.
