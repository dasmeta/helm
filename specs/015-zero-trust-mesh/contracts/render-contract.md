# Render Contract: Zero Trust Mesh Empty Default Allow Rules

## Standalone zero-trust-mesh default render

Command:

```bash
helm template ztm-default ./charts/zero-trust-mesh -n default
```

Expected:

- Exits with status `0`.
- Does not render a `NetworkPolicy` named like `allow-ztm-default-to-backend-*`.
- Does not render an `AuthorizationPolicy` named `allow-ztm-default-to-backend`.
- Does not render a `ServiceEntry` named `external-api-stripe-com`.
- Does not render IP egress resources for `192.0.2.10`.

## Base render with zeroTrustMesh enabled

Command:

```bash
helm template base-enabled ./charts/base -n default --set zeroTrustMesh.enabled=true
```

Expected:

- Exits with status `0`.
- Renders normal base chart workload resources.
- Does not render sample zero-trust-mesh allow resources for `backend`.
- Does not render sample zero-trust-mesh ServiceEntry resources for `api.stripe.com`.

## Explicit allowTo render

Commands:

```bash
helm template ztm-full ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/values.full.yaml
helm template base-with-ztm ./charts/base -n default -f ./examples/base/with-zero-trust-mesh.yaml
```

Expected:

- Each command exits with status `0`.
- Explicit service and host allow rules render from provided values.
- Empty defaults do not suppress consumer-provided allow rules.
