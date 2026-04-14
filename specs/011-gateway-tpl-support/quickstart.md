# Quickstart: Gateway API tpl Support

## 1) Validate chart syntax

Run from repository root:

`helm lint ./charts/gateway-api`

## 2) Render updated tpl example

Run from repository root:

`helm template gateway ./charts/gateway-api -f ./examples/gateway-api/with-istio-envoyfilter-direct-response.yaml`

Expected:

- Render succeeds without template errors.
- HTTPRoute hostnames are resolved in output.
- AuthorizationPolicy rules are resolved in output (including user-provided templated `istio.authorizationPolicies[].rules`).
- EnvoyFilter config patches are resolved in output (generated from route rules and resolved hostnames).
- Output contains the resolved hostname string (for example, `dev.http-echo-gw.localhost` when `global.environment=dev`).

## 3) Run regression example renders

Run from repository root:

`helm template base ./charts/base -f ./examples/base/with-istio-gateway-api-http-route-only.yaml`

Expected:

- Existing static-value example still renders successfully.
- No regressions in unaffected resources.

## 4) Verify docs/examples updates

- Ensure updated examples include runnable command comment at the top.
- Ensure chart documentation describes tpl support for target fields.
- Confirm README guidance explicitly calls out:
  - `httpRoutes[].hostnames`
  - `istio.authorizationPolicies[].rules`
  - generated EnvoyFilter `configPatches`

## 5) Final release hygiene

- Bump chart version(s) for modified chart(s) in `Chart.yaml`.
- Re-run lint and template commands after version bump.
