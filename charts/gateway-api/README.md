# Gateway API

Helm chart to create Gateway API resources (standardized, next-generation replacement for Kubernetes Ingress) for managing network traffic in Kubernetes.

## Install

```bash
helm repo add dasmeta https://dasmeta.github.io/helm
helm upgrade --install my-gateway dasmeta/gateway-api -f values.yaml
```

Public values and options: [values.yaml](./values.yaml). Example values: [examples/gateway-api/](../../examples/gateway-api/). From repo root: `helm template test charts/gateway-api -f examples/gateway-api/minimal.yaml`.

### Key values

| Key | Description | Default / Example |
| --- | ----------- | ----------------- |
| `enabled` | Enable chart (when used as subchart) | `false` |
| `gateways` | List of Gateway resources | `[]`; see suboptions below |
| `gateways[].gatewayClassName` | Gateway class for this Gateway | `istio` |
| `gateways[].listeners` | Listeners for this Gateway; `hostname`, `port`, `protocol`; name auto-generated (protocol-port-hostname, ≤63 chars) | port 80, protocol HTTP |
| `gateways[].infrastructure` | Service annotations, parametersRef (e.g. AWS NLB, ConfigMap) | optional |
| `defaultParentRefs` | Default parentRefs for routes when not set per-route | `[]`; kind=Gateway, group=gateway.networking.k8s.io |
| `httpRoutes` | List of HTTPRoute resources | `[]`; see suboptions below |
| `httpRoutes[].name`, `nameSuffix` | Route name and optional suffix for the resource name | e.g. name: main, nameSuffix: -route |
| `httpRoutes[].parentRefs` | Gateway parent refs (name, sectionName, kind, group); optional if defaultParentRefs set | name: main, sectionName: http |
| `httpRoutes[].hostnames` | Hostnames this route matches | e.g. example.com |
| `httpRoutes[].rules` | Route rules: `matches` (path, headers), `backendRefs`, `filters` (e.g. RequestRedirect), `directResponse` | PathPrefix /, backendRefs to service |
| `grpcRoutes` | List of GRPCRoute resources | example in values.yaml |
| `tcpRoutes` | List of TCPRoute resources (experimental) | example in values.yaml |
| `tlsRoutes` | List of TLSRoute resources | example in values.yaml |
| `udpRoutes` | List of UDPRoute resources | example in values.yaml |
| `istio` | Istio-specific CRDs (when using Istio as Gateway implementation) | see suboptions below |
| `istio.defaultTargetRefs` | Default targetRefs for AuthorizationPolicy | `[]` |
| `istio.gateways` | List of Istio Gateway resources (networking.istio.io; for VirtualService) | selector, servers |
| `istio.authorizationPolicies` | List of AuthorizationPolicy (allow/deny by path, host, IP) | action DENY/ALLOW, rules |
| `istio.peerAuthentications` | List of PeerAuthentication (mTLS) | mode STRICT/PERMISSIVE |
| `istio.virtualServices` | List of VirtualService resources | hosts, http match/route |
| `istio.sidecars` | List of Sidecar resources | `[]` |
