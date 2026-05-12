# Quickstart: Zero Trust Mesh Empty Default Allow Rules

Run all commands from the repository root.

## Focused Standalone Default Test

```bash
charts/zero-trust-mesh/tests/render-default-empty.sh ./charts/zero-trust-mesh
```

Expected: command exits with status `0`; no sample `backend`, `api.stripe.com`, or `192.0.2.10` resources are rendered.

## Focused Base Default Test

```bash
charts/base/tests/render-zero-trust-default-empty.sh ./charts/base
```

Expected: command exits with status `0`; enabling `zeroTrustMesh` from base does not render sample allow resources.

## Chart Lint

```bash
helm lint ./charts/zero-trust-mesh
helm lint ./charts/base
```

Expected: each command reports `0 chart(s) failed`.

## Default Renders

```bash
helm template ztm-default ./charts/zero-trust-mesh -n default
helm template base-enabled ./charts/base -n default --set zeroTrustMesh.enabled=true
```

Expected: each command exits with status `0`; standalone zero-trust-mesh default output is empty, and base renders only its normal base resources.

## Explicit AllowTo Regression

```bash
helm template ztm-full ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/values.full.yaml
helm template base-with-ztm ./charts/base -n default -f ./examples/base/with-zero-trust-mesh.yaml
```

Expected: each command exits with status `0` and renders the explicitly configured allow rules.
