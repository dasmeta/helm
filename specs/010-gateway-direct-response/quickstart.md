# Quickstart: Gateway Direct Response Feature Validation

## Prerequisites

- Work from repository root: `/Users/tmuradyan/projects/dasmeta/helm`
- Helm 3 available
- Target chart: `charts/gateway-api`

## 1) Validate default behavior is unchanged

```bash
helm lint ./charts/gateway-api
helm template gateway-api ./charts/gateway-api
```

Expected: successful lint/template output with no direct-response regressions in default mode.

## 2) Validate new/updated direct-response example

```bash
helm template gateway-api ./charts/gateway-api -f ./examples/gateway-api/<direct-response-example>.yaml
```

Expected:

- Rendered manifests include direct-response resource output for configured non-403 statuses.
- Omitted body resolves to empty string behavior.
- Configured out-of-range status (outside 200-599) is rejected.

## 3) Validate existing example regression safety

Run template commands for existing gateway-api examples after feature changes:

```bash
helm template gateway-api ./charts/gateway-api -f ./examples/gateway-api/gateway-api-all-routes.values.yaml
helm template gateway-api ./charts/gateway-api -f ./examples/gateway-api/infrastructure-parameters.yaml
helm template gateway-api ./charts/gateway-api -f ./examples/gateway-api/minimal.yaml
helm template gateway-api ./charts/gateway-api -f ./examples/gateway-api/multiple-httproutes.values.yaml
```

Expected: all examples continue rendering successfully with no 403 behavior regressions.

## 4) Precedence verification checklist

- Existing AuthorizationPolicy-based 403 behavior remains unchanged.
- Direct-response behavior applies for configured non-403 status use cases.
- Overlap conditions do not override existing 403 behavior.
