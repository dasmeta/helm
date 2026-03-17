# Contract: Gateway listener TLS (009)

## Input (values)

- `gateways[].listeners[].protocol`: string (e.g. `"HTTP"`, `"HTTPS"`).
- `gateways[].listeners[].tls`: optional; may be absent, null, or an object.

## Output (rendered Gateway.spec.listeners[].tls)

| protocol | tls in values        | Rendered tls |
|----------|----------------------|--------------|
| HTTPS    | absent / null / {}  | `mode: Terminate`, `certificateRefs: [{ name: "<gateway-name>-tls", kind: Secret, group: "" }]` |
| HTTPS    | non-empty object     | Exactly the provided `tls` object (no merge, no default) |
| HTTP     | any                  | No `tls` block |
| other    | any                  | No `tls` block |

## Gateway name

- `<gateway-name>` = effective Gateway metadata name = `default(release fullname, gateway.name) + gateway.nameSuffix`.
- Same value is used for `Gateway.metadata.name` and for default TLS Secret name.
