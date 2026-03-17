# Data Model: Gateway TLS Defaults (009)

## Values (input)

- **gateways[]**: List (or single object normalized to list) of Gateway definitions.
  - **name**: Optional. Overrides release-based default for the Gateway resource name.
  - **nameSuffix**: Optional. Appended to the effective Gateway name.
  - **listeners[]**: List of listener definitions.
    - **name**: Optional. Defaulted from protocol-port-hostname when omitted.
    - **protocol**: String. Default `"HTTP"`. When `"HTTPS"`, TLS defaulting may apply.
    - **port**, **hostname**, **allowedRoutes**: Unchanged.
    - **tls**: Optional. If present and non-empty, rendered as-is. If absent or effectively empty (`{}`/null) and protocol is HTTPS, chart supplies default TLS.

## Rendered Gateway (output)

- **metadata.name**: Effective gateway name = `default(fullname, gateway.name) + gateway.nameSuffix`.
- **spec.listeners[]**:
  - **protocol**: From values.
  - **tls**: Either user-provided (when non-empty) or defaulted for HTTPS when empty/null:
    - **mode**: `Terminate`
    - **certificateRefs**: `[{ name: "<effective-gateway-name>-tls", kind: "Secret", group: "" }]`

## Effective gateway name

- Single source of truth: same string used for `Gateway.metadata.name` and for default TLS Secret name.
- Formula: `default(include "gateway-api.fullname" $outer, $gateway.name) + coalesce($gateway.nameSuffix, "")`.
- Implemented once in template (variable or helper) and reused.

## No new entities

- No new CRDs or resources. TLS Secret `{gateway-name}-tls` is assumed to be provisioned by the consumer (e.g. cert-manager, Terraform); chart only references it by name.
