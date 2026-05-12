# Data Model: Zero Trust Mesh Empty Default Allow Rules

## AllowToDefault

Represents the active default value for zero-trust-mesh service-level allow rules.

```yaml
allowTo: []
```

Validation:

- Empty list renders no service, host, or IP allow resources.
- Non-empty list keeps existing rule semantics.

## BaseZeroTrustMeshOverride

Represents the base chart parent values passed to the aliased zero-trust-mesh dependency.

```yaml
zeroTrustMesh:
  enabled: false
  allowTo: []
```

Validation:

- `enabled=false` keeps the subchart disabled.
- `enabled=true` with no other values still passes an empty `allowTo` list to the subchart.
- Consumer-provided `zeroTrustMesh.allowTo` replaces the empty default and renders explicit rules.

## SampleAllowResource

Any rendered manifest derived from example-only defaults, such as:

- `allow-*-to-backend-*` NetworkPolicy
- `allow-*-to-backend` AuthorizationPolicy
- `external-api-stripe-com` ServiceEntry
- `external-ip-*` resources for `192.0.2.10`

Validation:

- Sample resources must not appear in default standalone or default base zeroTrustMesh renders.
