# Research: Zero Trust IP Egress

## Decisions

### Add `allowTo[].ips` as the third allow rule type

**Decision**: Extend the existing single `allowTo` list with an `ips` rule type.

**Rationale**: The chart already models destination allows as a single list with separate service and host rule shapes. Adding `ips` preserves that values style and avoids creating a parallel top-level egress configuration.

**Alternatives considered**:

- Reuse `hosts` for IPs: rejected because direct IP calls are not DNS host/SNI-based and require different Istio and NetworkPolicy fields.
- Add top-level `allowIpEgress`: rejected because it splits allow rules across multiple lists and makes the chart harder to scan.

### Render ServiceEntry with `addresses` and `resolution: NONE`

**Decision**: For IP rules, render one Istio `ServiceEntry` containing normalized IP/CIDR values under `spec.addresses`, with `location: MESH_EXTERNAL` and `resolution: NONE`.

**Rationale**: Direct IP traffic needs an Istio registry entry when outbound traffic policy is `REGISTRY_ONLY`. `resolution: NONE` represents already-resolved direct destination addresses.

**Alternatives considered**:

- DNS ServiceEntry: rejected because direct IP traffic has no DNS host to resolve.
- Egress-gateway VirtualService routing: rejected for this change because the existing gateway flow is host/SNI-oriented, while direct IP traffic may not have useful SNI.

### Render a source-workload egress NetworkPolicy

**Decision**: Add `templates/networkpolicy-ip-egress.yaml` that selects source workload pods and allows egress to configured IP/CIDR blocks.

**Rationale**: Namespace default-deny egress blocks direct IP traffic unless a NetworkPolicy egress rule allows the destination. The existing service flow template is ingress-oriented and selects destination pods, so a separate source egress template is clearer.

### Normalize single IP values to host CIDRs

**Decision**: Render single IPv4 addresses as `/32` and single IPv6 addresses as `/128`; preserve values that already contain `/`.

**Rationale**: Kubernetes `NetworkPolicyPeer.ipBlock.cidr` expects CIDR notation. Host CIDRs make single-address input convenient while rendering valid policy blocks.

## Official Documentation Notes

- Istio ServiceEntry supports `addresses` as VIPs or CIDR prefixes associated with hosts and supports `resolution: NONE` for cases where the proxy does not resolve the endpoint.
- Kubernetes NetworkPolicy supports `ipBlock.cidr` on ingress or egress peers for IP CIDR selection.
- Kubernetes NetworkPolicy port protocols are L4 protocols (`TCP`, `UDP`, `SCTP`), so Istio protocol labels such as `HTTP` or `HTTPS` cannot be copied directly into NetworkPolicy protocol fields.

Sources checked:

- Istio ServiceEntry reference: https://istio.io/latest/docs/reference/config/networking/service-entry/
- Kubernetes NetworkPolicy concept docs: https://kubernetes.io/docs/concepts/services-networking/network-policies/
- Kubernetes NetworkPolicy API reference: https://kubernetes.io/docs/reference/kubernetes-api/policy-resources/network-policy-v1/

## Validation Notes

The focused render assertion should verify:

- an IP rule renders a ServiceEntry
- the ServiceEntry uses `resolution: NONE`
- a single IP renders as `/32`
- a CIDR input is preserved
- an IP rule renders a NetworkPolicy
- the NetworkPolicy uses `ipBlock`
- configured ports appear in both outputs
