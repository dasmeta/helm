# Quickstart: Implementing 009 Gateway TLS Defaults

## Scope

- **Chart**: `charts/gateway-api` only.
- **Files**: `templates/gateway.yaml` (required); optionally `templates/_helpers.tpl` for a reusable effective gateway name.

## Steps

1. **Effective gateway name**  
   Define the same name used for `Gateway.metadata.name` in one place (e.g. a variable in the gateway range). Use it for:
   - `metadata.name`
   - Default TLS Secret name when protocol is HTTPS and `tls` is empty/null/`{}`.

2. **Listener TLS logic**  
   In the listener range in `gateway.yaml`:
   - If `protocol` is HTTPS (case-insensitive) and `tls` is effectively empty (absent, null, or empty map), render:
     - `tls.mode: Terminate`
     - `tls.certificateRefs`: one entry with `name: "<effective-gateway-name>-tls"`, `kind: Secret`, `group: ""`.
   - Else if `tls` is present and non-empty: `{{- toYaml .tls | nindent 8 }}` (existing behavior).
   - Else (e.g. HTTP): do not emit `tls`.

3. **“Effectively empty” in Helm**  
   Treat `tls` as empty when: not set, or `empty .tls`, or (if needed) shallow check that no meaningful keys exist. Do not default when any of `mode`, `certificateRefs`, or other TLS fields are set.

4. **Examples**  
   Add or update `examples/gateway-api/` with:
   - An example that has an HTTPS listener **without** `tls` and assert rendered output has defaulted TLS with `{gateway-name}-tls`.
   - Keep an example that has HTTPS with **explicit** `tls` and assert it is unchanged.

5. **Validation**  
   - `helm lint charts/gateway-api`
   - `helm template test charts/gateway-api -f examples/gateway-api/<each>.yaml` for all examples; no regression.

6. **Version**  
   Bump `version` in `charts/gateway-api/Chart.yaml` (PATCH).

## Done when

- All acceptance scenarios in spec pass (HTTPS + no tls → default; HTTPS + tls → passthrough; HTTP → no tls; empty `{}`/null → default).
- Lint and template pass; Constitution Check remains PASS.
