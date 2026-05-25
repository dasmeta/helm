# zero-trust-mesh

Minimal Helm chart for strict Kubernetes + Istio zero-trust communication.

## Security model

- Default deny ingress/egress via `NetworkPolicy`
- Exact pod-to-pod allow rules only (no broad namespace trust)
- STRICT mTLS via Istio `PeerAuthentication`
- Default deny via Istio `AuthorizationPolicy`
- Service-account based allow rules with optional HTTP methods/paths
- External egress only to approved hosts or IP blocks

## Two deployment modes

Use the same chart in two layers:

1. Namespace baseline (install once per namespace)
2. Service rules (install per workload)

### 1) Namespace baseline

Enable namespace-wide resources:

```yaml
namespace: default
namespaceResourcesEnabled: true
allowPolicies: []
```

This creates namespace-scoped defaults:
- default deny network policy
- DNS allow policy
- egress-gateway-only network policy
- STRICT mTLS
- default deny authorization policy

### 2) Service rules

Enable per-service deny-all first, then add explicit allow entries as traffic is validated:

```yaml
service: frontend
namespaceResourcesEnabled: false
denyAll:
  enabled: true
allowPolicies:
  - type: ingress
    service: gateway
    podLabels:
      app: gateway
    port: 80
  - type: ingress
    service: ingress-nginx
    namespace: ingress-nginx
    podLabels:
      app.kubernetes.io/name: ingress-nginx
      app.kubernetes.io/component: controller
    port: 80
    allowUnauthenticated: true
  - type: egress
    service: backend
    podLabels:
      app: backend
    port: 8080
  - type: egress
    hosts: ["api.stripe.com"]
  - type: egress
    ips: ["192.0.2.10"]
    ports:
      - number: 443
        protocol: TCP
```

## Values design

`denyAll` is a service-scoped deny-all switch:

- `enabled` (optional, default `false`)
- `podLabels` (optional selector override; defaults to `app.kubernetes.io/name: <service>`)

When enabled, it renders:

- a service-scoped NetworkPolicy with both `Ingress` and `Egress` policy types and no allow rules
- a service-scoped Istio AuthorizationPolicy default deny for inbound mesh traffic
- service-scoped DNS and `istiod` egress NetworkPolicy exceptions so injected
  sidecars can keep receiving mesh configuration while application traffic stays denied

`allowPolicies` is the preferred typed allow list owned by the current service.

For `type: ingress` entries:

- `service` (required source service name; `workload` is accepted as a legacy alias)
- `namespace` (optional source namespace, defaults to Helm release namespace)
- `podLabels` (optional source pod selector override; defaults to `app.kubernetes.io/name: <service>`)
- `sourceIpBlocks` (optional source CIDR allow list for non-pod sources such as AWS ALB target-type `ip`)
- `serviceAccount` (optional source service account override; defaults to `service`)
- `port` / `protocol` (optional, defaults to `80` / `TCP`)
- `methods` / `paths` (optional Istio operation filters)
- `allowUnauthenticated` (optional, default `false`): omit the Istio source principal match for non-mesh sources such as `ingress-nginx`; keep `podLabels` set so NetworkPolicy still restricts packet sources

For `type: egress` entries, service destinations use `service` as the peer
service name. For service destinations it renders service-scoped egress
`NetworkPolicy` rules only; the destination service must open inbound traffic
with its own ingress allow policy if it has `denyAll.enabled: true`.

`type: egress` supports three destination forms:

- Service rule:
  - `service` (required; `workload` is accepted as a legacy alias)
  - `namespace` (optional, defaults to Helm release namespace)
  - `podLabels` (optional target pod selector override for generated egress `NetworkPolicy`; defaults to `app.kubernetes.io/name: <service>`)
  - `port` (optional, default `8080`)
  - `protocol` (optional, default `TCP`)
  - `serviceAccount` / `methods` / `paths` are only used by the legacy target-side ingress mode
- Host rule:
  - `hosts` (list of approved external hosts)
  - `ports` (optional list; merged with defaults `80/HTTP` and `443/HTTPS`)
  - `paths` can be provided in values for future/egress-gateway routing use, but are not enforced by `ServiceEntry`-only mode
  - renders Istio `ServiceEntry` resources and, when service deny-all is enabled, a service-scoped public-IP egress `NetworkPolicy` for the selected ports
- IP rule:
  - `ips` (list of approved external destination IPs or CIDR blocks)
  - `ports` (optional list; defaults to `443/TCP`)
  - single IPv4 addresses are rendered as `/32` CIDRs for `NetworkPolicy` `ipBlock`
  - renders both an Istio `ServiceEntry` with `resolution: NONE` and a workload-scoped egress `NetworkPolicy`

Source service account defaults to `service`, or can be set with top-level `serviceAccount`.

If your cluster does not have an `istio-egressgateway` Service name, set:
- `istio.egressGateway.serviceName` to your real gateway Service
- `istio.egressGateway.selector` to labels of that gateway workload
- `networkPolicy.egressGateway.podLabels` to the same labels (so egress NP allows traffic to it)

Most security defaults are now implicit in templates. Advanced overrides can still be set under `networkPolicy` and `istio` in `values.full.yaml`.

### Key values

| Key | Description | Default / Example |
|-----|-------------|-------------------|
| `service` | Current service name used for pod selectors and default source service account | Helm release name |
| `workload` | Deprecated alias for `service` | Helm release name |
| `serviceAccount` | Source service account override | `""` |
| `namespaceResourcesEnabled` | Enables namespace-wide default deny, DNS, egress gateway, mTLS, and default-deny AuthorizationPolicy resources | `false` |
| `denyAll.enabled` | Enables service-scoped deny-all for both inbound and outbound traffic | `false` |
| `denyAll.podLabels` | Optional pod selector override for service-level deny-all resources | Not set; defaults to `app.kubernetes.io/name: <service>` |
| `allowPolicies` | Preferred typed inbound/outbound allow rules owned by the current service | `[]` |
| `allowPolicies[].type` | Policy direction, either `ingress` or `egress` | `ingress` |
| `allowPolicies[].service` | Peer service name for ingress source or egress destination | `backend` |
| `allowPolicies[].workload` | Deprecated alias for `allowPolicies[].service` | `backend` |
| `allowPolicies[].podLabels` | Optional peer pod selector override for generated NetworkPolicy | `{ app: backend }` |
| `allowPolicies[].sourceIpBlocks` | Optional ingress CIDR allow list for non-pod sources such as AWS ALB target-type `ip` | `["172.31.0.0/16"]` |
| `allowPolicies[].serviceAccount` | Optional peer service account override for AuthorizationPolicy principals | `allowPolicies[].service` |
| `allowPolicies[].allowUnauthenticated` | Allow non-mesh inbound sources; NetworkPolicy should still restrict source pods or CIDRs | `false` |
| `allowPolicies[].hosts` | Approved external hosts for ServiceEntry-based egress | `["api.stripe.com"]` |
| `allowPolicies[].ips` | Approved external destination IPs or CIDR blocks for direct IP egress | `["192.0.2.10"]` |

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
