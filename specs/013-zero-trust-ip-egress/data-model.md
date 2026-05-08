# Data Model: Zero Trust IP Egress

## IpEgressRule

An `allowTo` entry that allows a source workload to egress to literal destination IP addresses or CIDR ranges.

```yaml
allowTo:
  - ips:
      - 192.0.2.10
      - 198.51.100.0/24
    ports:
      - number: 443
        protocol: TCP
```

Fields:

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `ips` | list(string) | yes | Destination IP addresses or CIDR blocks. |
| `ports` | list(IpPort) | no | Defaults to one entry: `443/TCP`. |

## IpPort

A port allowed for a direct IP egress rule.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `number` | integer | yes | Destination port rendered in ServiceEntry and NetworkPolicy. |
| `protocol` | string | no | Defaults to `TCP`; ServiceEntry uses the configured protocol, NetworkPolicy renders only Kubernetes-compatible L4 protocols. |
| `name` | string | no | Optional ServiceEntry port name override. |

## NormalizedIpBlock

The CIDR-form address rendered into manifests.

Rules:

- Input containing `/` is treated as already normalized and rendered unchanged.
- Input containing `:` and no `/` is treated as IPv6 and rendered with `/128`.
- Any other input without `/` is treated as IPv4 and rendered with `/32`.

## Rendered Resources

### IP ServiceEntry

One `networking.istio.io/v1` ServiceEntry per IP egress rule.

Key fields:

- `metadata.namespace`: workload namespace
- `spec.hosts`: synthetic internal host name for the ServiceEntry object
- `spec.addresses`: normalized IP blocks
- `spec.location`: `MESH_EXTERNAL`
- `spec.resolution`: `NONE`
- `spec.ports`: configured IP rule ports or default `443/TCP`

### IP Egress NetworkPolicy

One `networking.k8s.io/v1` NetworkPolicy per IP egress rule.

Key fields:

- `metadata.namespace`: workload namespace
- `spec.podSelector.matchLabels.app.kubernetes.io/name`: source workload
- `spec.policyTypes`: `Egress`
- `spec.egress[].to[].ipBlock.cidr`: normalized IP blocks
- `spec.egress[].ports`: configured IP rule ports with Kubernetes-compatible protocols
