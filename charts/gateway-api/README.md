# Gateway API

Helm chart to create Gateway API resources (standardized, next-generation replacement for Kubernetes Ingress) for managing network traffic in Kubernetes.

## Supported versions

The chart renders the API versions below. It is tested against the Gateway API **v1.6.x standard channel** CRDs (v1.6.1) with **Istio 1.30.x** (1.30.3) as the Gateway implementation; other Gateway API implementations can use the non-Istio resources.

| Resource | apiVersion | Values key |
| --- | --- | --- |
| Gateway | `gateway.networking.k8s.io/v1` | `gateways` |
| HTTPRoute | `gateway.networking.k8s.io/v1` | `httpRoutes` |
| GRPCRoute | `gateway.networking.k8s.io/v1` | `grpcRoutes` |
| TCPRoute | `gateway.networking.k8s.io/v1` | `tcpRoutes` |
| TLSRoute | `gateway.networking.k8s.io/v1` | `tlsRoutes` |
| UDPRoute | `gateway.networking.k8s.io/v1` | `udpRoutes` |
| ListenerSet | `gateway.networking.k8s.io/v1` | `listenerSets` |
| BackendTLSPolicy | `gateway.networking.k8s.io/v1` | `backendTLSPolicies` |
| ReferenceGrant | `gateway.networking.k8s.io/v1` | `referenceGrants` |
| AuthorizationPolicy, PeerAuthentication, RequestAuthentication | `security.istio.io/v1` | `istio.authorizationPolicies`, `istio.peerAuthentications`, `istio.requestAuthentications` |
| DestinationRule, ServiceEntry, Sidecar, VirtualService, Gateway, WorkloadEntry, WorkloadGroup | `networking.istio.io/v1` | `istio.destinationRules`, `istio.serviceEntries`, `istio.sidecars`, `istio.virtualServices`, `istio.gateways`, `istio.workloadEntries`, `istio.workloadGroups` |
| EnvoyFilter | `networking.istio.io/v1alpha3` | `istio.envoyFilters` (plus generated ones, see below) |
| ProxyConfig | `networking.istio.io/v1beta1` | `istio.proxyConfigs` |
| Telemetry | `telemetry.istio.io/v1` | `istio.telemetries` |
| WasmPlugin, TrafficExtension | `extensions.istio.io/v1alpha1` | `istio.wasmPlugins`, `istio.trafficExtensions` (TrafficExtension needs Istio 1.30+) |

TCPRoute, TLSRoute, UDPRoute, ListenerSet and BackendTLSPolicy need the v1.6 standard channel CRDs (older releases ship them only in the experimental channel or at alpha versions). Their v1 rules have only `name` and `backendRefs`; `matches` on TCP/TLS/UDP rules are not rendered.

## Install

```bash
helm repo add dasmeta https://dasmeta.github.io/helm
helm upgrade --install my-gateway dasmeta/gateway-api -f values.yaml
```

Public values and options: [values.yaml](./values.yaml). Example values: [examples/gateway-api/](../../examples/gateway-api/). From repo root: `helm template test charts/gateway-api -f examples/gateway-api/minimal.yaml`.

You can either set `gateways[].infrastructure.parametersRef` to reference an existing ConfigMap, or set `gateways[].infrastructure.parameters` with the five keys (service, deployment, serviceAccount, horizontalPodAutoscaler, podDisruptionBudget). When `parameters` is set and non-empty, the chart creates a ConfigMap and sets `parametersRef` automatically; empty string values are omitted.

### Key values

| Key | Description | Default / Example |
| --- | ----------- | ----------------- |
| `enabled` | Enable chart (when used as subchart) | `false` |
| `gateways` | List of Gateway resources | `[]`; see suboptions below |
| `gateways[].gatewayClassName` | Gateway class for this Gateway | `istio` |
| `gateways[].listeners` | Listeners for this Gateway; `hostname`, `port`, `protocol`; name auto-generated (protocol-port-hostname, ≤63 chars) | port 80, protocol HTTP |
| `gateways[].listeners[].tls` | For HTTPS and TLS listeners. **Absent** → chart defaults to `mode: Terminate` and `certificateRefs` to Secret `{gateway-name}-tls`. **`tls: {}`** → explicit opt-out (no `tls` block in output; e.g. TLS handled in pod). **Non-empty** → rendered as-is. Secret must be provisioned by the caller (e.g. cert-manager or Terraform). | optional |
| `gateways[].infrastructure` | Annotations, parametersRef (manual ConfigMap), or parameters (chart-generated ConfigMap) | optional |
| `gateways[].infrastructure.parameters` | Inline config for service, deployment, serviceAccount, horizontalPodAutoscaler, podDisruptionBudget (object or string per key); chart creates a ConfigMap and sets parametersRef when non-empty; empty string omits key | optional; when set, overrides parametersRef |
| `defaultParentRefs` | Default parentRefs for routes when not set per-route | `[]`; kind=Gateway, group=gateway.networking.k8s.io |
| `httpRoutes` | List of HTTPRoute resources | `[]`; see suboptions below |
| `httpRoutes[].name`, `nameSuffix` | Route name and optional suffix for the resource name | e.g. name: main, nameSuffix: -route |
| `httpRoutes[].parentRefs` | Gateway parent refs (name, sectionName, kind, group); optional if defaultParentRefs set | name: main, sectionName: http |
| `httpRoutes[].hostnames` | Hostnames this route matches. Supports templated expressions via Helm `tpl`. | e.g. `{{ .Values.global.environment }}.example.com` |
| `httpRoutes[].rules` | Route rules: `matches` (path, headers), `backendRefs`, `filters` (e.g. RequestRedirect), `directResponse` | PathPrefix /, backendRefs to service |
| `httpRoutes[].rules[].directResponse.status` | Direct response status. `403` keeps AuthorizationPolicy flow; non-`403` statuses are rendered via Istio EnvoyFilter | `403` or `200-599` |
| `httpRoutes[].rules[].directResponse.body` | Optional response body for non-`403` direct responses | `""` (empty string) |
| `httpRoutes[].rules[].backendRefs` | One backendRef object or a list | `{ name: api, port: 8080 }` |
| `httpRoutes[].rules[].backendRefs[].external` | Backend outside the cluster behind an ExternalName Service (the backendRef `name`/`port`). Renders an Istio ServiceEntry `ext-<route>` (`ext-<route>-<backend>` when a route has several), plus a TLS origination DestinationRule for `protocol: HTTPS`. Must be the only backendRef of its rule. Fields: `host` (external name, defaults to the first route hostname), `endpoint` (DNS target of the ServiceEntry, defaults to `host`), `protocol` (`HTTP`/`HTTPS`), `rewriteHost` (send `host` as the upstream Host header), `create` (also create the ExternalName Service; leave off for an existing one) | optional |
| `httpRoutes[].lua` | Envoy Lua source (`envoy_on_request`/`envoy_on_response`) for logic an HTTPRoute can't express. Renders the EnvoyFilter `<route>-lua` that inserts the filter right before the router of the route's parent Gateways. It runs for every request on those Gateways, so the code must return right away for other hosts. Not rendered with `tpl` | optional |
| `grpcRoutes` | List of GRPCRoute resources | example in values.yaml |
| `tcpRoutes` | List of TCPRoute resources | example in values.yaml |
| `tlsRoutes` | List of TLSRoute resources | example in values.yaml |
| `udpRoutes` | List of UDPRoute resources | example in values.yaml |
| `listenerSets` | List of ListenerSet resources; the parent Gateway needs `allowedListeners` | spec passed as-is |
| `backendTLSPolicies` | List of BackendTLSPolicy resources (TLS from the Gateway to backends) | spec passed as-is |
| `referenceGrants` | List of ReferenceGrant resources (cross-namespace references) | spec passed as-is |
| `gateways[].allowedListeners` | Which namespaces may attach ListenerSets (`from: Same/All/Selector/None`) | optional |
| `gateways[].tls` | Gateway level TLS: `frontend` client certificate validation, `backend.clientCertificateRef` | optional |
| `httpRoutes[].rules[].name`, `timeouts` | Rule name and request/backendRequest timeouts | optional |
| `httpRoutes[].rules[].matches[].method`, `queryParams` | Method and query parameter matches (routing rules only; directResponse rules accept path matches only) | optional |
| `*Routes[].rules[].backendRefs[].group`, `kind` | Non-Service backends, e.g. `kind: Hostname`, `group: networking.istio.io` | optional |
| `istio` | Istio-specific CRDs (when using Istio as Gateway implementation) | see suboptions below |
| `istio.defaultTargetRefs` | Default targetRefs for AuthorizationPolicy | `[]` |
| `istio.gateways` | List of Istio Gateway resources (networking.istio.io; for VirtualService) | selector, servers |
| `istio.authorizationPolicies` | List of AuthorizationPolicy (allow/deny by path, host, IP). `rules` supports templated expressions via Helm `tpl`. | action DENY/ALLOW, rules |
| `istio.peerAuthentications` | List of PeerAuthentication (mTLS) | mode STRICT/PERMISSIVE |
| `istio.virtualServices` | List of VirtualService resources | hosts, http match/route |
| `istio.sidecars` | List of Sidecar resources | `[]` |
| `istio.envoyFilters` | List of EnvoyFilter resources passed in full (targetRefs/workloadSelector, configPatches, priority); default namespace `istio-system` | `[]` |
| `istio.trafficExtensions` | List of TrafficExtension resources (Lua or Wasm, Istio 1.30+); default namespace `istio-system` | `[]` |
| `istio.wasmPlugins` | List of WasmPlugin resources; default namespace `istio-system` | `[]` |
| `istio.proxyConfigs` | List of ProxyConfig resources | `[]` |

The passthrough lists (`listenerSets`, `backendTLSPolicies`, `referenceGrants`, `istio.envoyFilters`, `istio.trafficExtensions`, `istio.wasmPlugins`, `istio.proxyConfigs`) take `name`, `namespace`, `labels`, `annotations` and the resource's spec fields at the item's top level (or under `spec`).

### Templating support notes

- `httpRoutes[].hostnames` values are rendered with Helm `tpl`.
- `istio.authorizationPolicies[].rules` values are rendered with Helm `tpl`.
- Generated EnvoyFilter `configPatches` are rendered with Helm `tpl`, so templates that resolve through route hostnames and related values propagate correctly.
- `backendRefs[].external.host`/`endpoint` are rendered with Helm `tpl`; `httpRoutes[].lua` is passed as-is.

Example with external backends and a Lua filter: [examples/gateway-api/with-external-backend-and-lua.yaml](../../examples/gateway-api/with-external-backend-and-lua.yaml).
