# Research: Gateway API tpl Support

## Decision 1: Apply templating at serialized block level for target fields

- **Decision**: Use `tpl (toYaml <value>) $outer | nindent <N>` for `hostnames`, `rules`, and `configPatches`.
- **Rationale**: This keeps behavior consistent across list/object payloads, preserves existing values structure expectations, and supports mixed static/template content.
- **Alternatives considered**:
  - Per-item templating loops for each field: rejected due to duplicated template logic and higher indentation risk.
  - No templating for policy/filter blocks: rejected because it fails feature parity and user request.

## Decision 2: Keep rendering failures explicit for unresolved template references

- **Decision**: Preserve Helm default behavior where unresolved template expressions fail during render.
- **Rationale**: Explicit render failure is safer than silently producing malformed or unexpected manifests.
- **Alternatives considered**:
  - Swallow errors and render empty output: rejected because it masks configuration issues.
  - Custom fallback defaults in templates: rejected due to ambiguous behavior and hidden coupling to values.

## Decision 3: Validate with lint + targeted and regression example templates

- **Decision**: Require `helm lint` on affected chart(s), `helm template` on updated example(s), and `helm template` on additional existing examples for regression.
- **Rationale**: Aligns with repository constitution and catches YAML/templating regressions before release.
- **Alternatives considered**:
  - Validate only updated example: rejected because regressions can affect unchanged examples.
  - Validate only chart defaults: rejected because the feature specifically targets advanced values paths.

## Decision 4: Document as consumer-facing configuration capability

- **Decision**: Update example files and chart docs to explicitly state templating support in the three target fields.
- **Rationale**: The change introduces a new consumer-visible behavior and must be discoverable.
- **Alternatives considered**:
  - Rely on implicit behavior from templates: rejected because it increases adoption friction and support load.

## Baseline and verification notes

- **Baseline render captured**: `helm template gateway ./charts/gateway-api -f ./examples/gateway-api/with-istio-envoyfilter-direct-response.yaml`
- **Observation**: Templated `httpRoutes[].hostnames` resolve correctly and propagate into generated AuthorizationPolicy and EnvoyFilter resources.
- **Static regression target**: `helm template base ./charts/base -f ./examples/base/with-istio-gateway-api-http-route-only.yaml`

## Upstream field references checked

- **HTTPRoute hostnames**: [Gateway API HTTPRouteSpec](https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.HTTPRouteSpec)
- **AuthorizationPolicy rules**: [Istio AuthorizationPolicy](https://istio.io/latest/docs/reference/config/security/authorization-policy/)
- **EnvoyFilter configPatches**: [Istio EnvoyFilter](https://istio.io/latest/docs/reference/config/networking/envoy-filter/)
