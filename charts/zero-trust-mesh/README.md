# zero-trust-mesh

Minimal Helm chart for strict Kubernetes + Istio zero-trust communication.

## Security model

- Default deny ingress/egress via `NetworkPolicy`
- Exact pod-to-pod allow rules only (no broad namespace trust)
- STRICT mTLS via Istio `PeerAuthentication`
- Default deny via Istio `AuthorizationPolicy`
- Service-account based allow rules with optional HTTP methods/paths
- External egress only to approved hosts via Istio egress gateway

## Two deployment modes

Use the same chart in two layers:

1. Namespace baseline (install once per namespace)
2. Service rules (install per workload)

### 1) Namespace baseline

Enable namespace-wide resources:

```yaml
namespace: default
namespaceResourcesEnabled: true
allowTo: []
```

This creates namespace-scoped defaults:
- default deny network policy
- DNS allow policy
- egress-gateway-only network policy
- STRICT mTLS
- default deny authorization policy

### 2) Service rules

Enable only per-service allow entries (minimal values):

```yaml
workload: frontend
namespaceResourcesEnabled: false
allowTo:
  - service: backend
    port: 8080
    methods: ["GET", "POST"]
    paths: ["/api/*"]
  - hosts: ["api.stripe.com"]
```

## Values design

`allowTo` is a single list with two entry types:

- Service rule:
  - `service` (required)
  - `namespace` (optional, defaults to Helm release namespace)
  - `port` (optional, default `8080`)
  - `protocol` (optional, default `TCP`)
  - `serviceAccount` (optional target service account override)
  - `methods` / `paths` (optional Istio operation filters)
- Host rule:
  - `hosts` (list of approved external hosts)
  - `ports` (optional list; merged with defaults `80/HTTP` and `443/HTTPS`)
  - `paths` can be provided in values for future/egress-gateway routing use, but are not enforced by `ServiceEntry`-only mode

Source service account defaults to `workload`, or can be set with top-level `serviceAccount`.

If your cluster does not have an `istio-egressgateway` Service name, set:
- `istio.egressGateway.serviceName` to your real gateway Service
- `istio.egressGateway.selector` to labels of that gateway workload
- `networkPolicy.egressGateway.podLabels` to the same labels (so egress NP allows traffic to it)

Most security defaults are now implicit in templates. Advanced overrides can still be set under `networkPolicy` and `istio` in `values.full.yaml`.

## Install

```bash
helm upgrade --install ztm-baseline ./zero-trust-mesh -n default -f values.full.yaml
```

## Istio prerequisite

Set mesh outbound mode in IstioOperator/istiod:

```yaml
meshConfig:
  outboundTrafficPolicy:
    mode: REGISTRY_ONLY
```

This chart assumes namespaces have the standard label `kubernetes.io/metadata.name`.
