# Render Contract: Zero Trust IP Egress

## Values Input

```yaml
workload: frontend
namespaceResourcesEnabled: false
allowTo:
  - ips:
      - 192.0.2.10
      - 198.51.100.0/24
    ports:
      - number: 443
        protocol: TCP
      - number: 8080
        protocol: HTTP
```

## Required Rendered ServiceEntry

The chart MUST render a `networking.istio.io/v1` `ServiceEntry` with:

- `metadata.namespace: default` when rendered with `-n default`
- `spec.addresses` containing `"192.0.2.10/32"` and `"198.51.100.0/24"`
- `spec.location: MESH_EXTERNAL`
- `spec.resolution: NONE`
- `spec.ports` containing port `443` protocol `TCP`
- `spec.ports` containing port `8080` protocol `HTTP`

The ServiceEntry host name may be synthetic, but it MUST be deterministic for the same values.

## Required Rendered NetworkPolicy

The chart MUST render a `networking.k8s.io/v1` `NetworkPolicy` with:

- `metadata.namespace: default` when rendered with `-n default`
- `spec.podSelector.matchLabels.app.kubernetes.io/name: frontend`
- `spec.policyTypes` containing `Egress`
- `spec.egress[].to[].ipBlock.cidr` containing `"192.0.2.10/32"` and `"198.51.100.0/24"`
- `spec.egress[].ports` containing port `443` protocol `TCP`
- `spec.egress[].ports` containing port `8080` protocol `TCP`, because Kubernetes NetworkPolicy does not accept `HTTP` as a protocol

## Default Port Contract

When an IP egress rule omits `ports`, the rendered ServiceEntry and NetworkPolicy MUST allow `443/TCP`.

## Regression Contract

Adding IP egress support MUST NOT change:

- `allowTo[].service` NetworkPolicy ingress rendering
- `allowTo[].service` AuthorizationPolicy rendering
- `allowTo[].hosts` DNS ServiceEntry rendering
- namespace baseline resources
