# Implementation Summary: 009-gateway-tls-defaults

**Completed**: 2026-03-16

## Changes

### Chart (charts/gateway-api)

- **templates/gateway.yaml**
  - Introduced `$baseName` and `$gatewayName` (effective Gateway name) after the `$useParams` block; `metadata.name` now uses `$gatewayName`.
  - For each listener: if `protocol` is HTTPS and `tls` is absent or effectively empty (`empty .tls`), the template renders a default `tls` block: `mode: Terminate`, `certificateRefs`: one entry `name: {{ $gatewayName }}-tls`, `kind: Secret`, `group: ""`. If `tls` is non-empty, it is rendered as-is. Non-HTTPS listeners do not get a `tls` block.
- **README.md**: Added table row for `gateways[].listeners[].tls` describing defaulting and Secret naming.
- **Chart.yaml**: Version bumped 0.1.3 → 0.1.4 (PATCH).

### Examples (examples/gateway-api)

- **https-default-tls.yaml**: One Gateway `main-internal`, one HTTPS listener (port 443) without `tls`; validates default TLS and `main-internal-tls` Secret name.
- **https-explicit-tls.yaml**: One Gateway with HTTPS listener and explicit `tls` (custom Secret name); validates no default injection.
- **https-empty-tls.yaml**: One Gateway with HTTPS listener and `tls: {}`; validates default TLS is still applied.

## Validation

- `helm lint charts/gateway-api`: passed.
- `helm template test charts/gateway-api -f examples/gateway-api/<file>.yaml` for all 7 example files: passed (no regression).

## Optional

- T004 (helper in _helpers.tpl): skipped; effective gateway name is inlined in gateway.yaml.
