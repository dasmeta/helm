# Render Contract: Gateway API tpl Support

## Contract Type

Helm chart render contract (values input to manifest output).

## Inputs

- Chart: `./charts/gateway-api`
- Values files (including examples) providing:
  - HTTPRoute `hostnames`
  - AuthorizationPolicy `rules`
  - EnvoyFilter `configPatches`
- Template context values referenced by expressions.

## Output Guarantees

When input templates resolve successfully:

1. HTTPRoute manifests include resolved `hostnames`.
2. AuthorizationPolicy manifests include resolved `rules`.
3. EnvoyFilter manifests include resolved `configPatches`.
4. Rendered manifests remain valid YAML and structurally valid for their target fields.
5. Static-value behavior remains unchanged.

## Failure Semantics

When template expressions reference missing or invalid context:

- Rendering fails during `helm template`.
- Failure is explicit and blocks successful output generation.

## Verification Signals

- `helm lint ./charts/gateway-api` passes.
- `helm template` passes for updated tpl example.
- `helm template` passes for at least one existing related example to confirm no regression.
