# Research: Gateway TLS Defaults (009)

## Gateway API TLS listener spec

- **Source**: [Gateway API - TLS](https://gateway-api.sigs.k8s.io/references/spec/#gateway.networking.k8s.io/v1.GatewayListener) (Gateway API v1).
- **Relevant fields**: `listeners[].protocol` (HTTP, HTTPS, TCP, TLS, UDP); `listeners[].tls.mode` (Terminate, Passthrough); `listeners[].tls.certificateRefs[]` with `name`, `kind`, `group` (optional).
- **HTTPS**: For `protocol: HTTPS` the gateway terminates TLS; `tls` with `mode: Terminate` and at least one `certificateRefs` entry (typically a Secret) is required for the manifest to be valid.
- **Convention**: Many setups use a single Secret per Gateway named after the Gateway (e.g. `{gateway-name}-tls`), provisioned by cert-manager or Terraform.

## Current gateway-api chart behavior

- **File**: `charts/gateway-api/templates/gateway.yaml`.
- **Listeners**: Each listener can set `name`, `hostname`, `port`, `protocol`, `tls`, `allowedRoutes`. Listener name is defaulted from `protocol-port-hostname` when omitted.
- **TLS**: Currently `{{- with .tls }}` only renders a `tls` block when `.tls` is present and non-empty; there is no defaulting for HTTPS.
- **Gateway name**: `metadata.name` is `{{ default (include "gateway-api.fullname" $outer) $gateway.name }}{{ coalesce $gateway.nameSuffix "" }}`. The same “effective gateway name” must be used for the default TLS Secret name.

## “Effectively empty” definition (from spec)

- **Empty**: `tls` absent, or `null`, or `{}` (no properties). → Apply defaults.
- **Non-empty**: Any `tls` object with at least one non-empty property (e.g. `mode`, or non-empty `certificateRefs`). → Use as-is, no defaulting.

## Helm template approach

- In the listener range: if `protocol` is HTTPS (case-insensitive) and `tls` is effectively empty, emit a fixed structure: `mode: Terminate`, `certificateRefs: [{ name: "<effective-gateway-name>-tls", kind: "Secret", group: "" }]`.
- Reuse the same effective gateway name used for `metadata.name` (e.g. via a named template or variable) so the Secret name is always `{gateway-name}-tls`.
- No changes to other templates or to Gateway API CRD versions; no new dependencies.
